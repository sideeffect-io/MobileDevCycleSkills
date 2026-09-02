#!/usr/bin/env bash
set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
example="$skill_dir/assets/ArchitectureExample"
gradle_bin="${GRADLE_BIN:-$example/gradlew}"
state_machine_revision="bae612b9ac8b23e5ac349c463081bac740620206"
state_machine_version="0.1.0-SNAPSHOT"
scratch_path="$(mktemp -d "${TMPDIR:-/tmp}/kotlin-architect-example.XXXXXX")"
mkdir -p "$scratch_path/gradle-home" "$scratch_path/project-cache" "$scratch_path/build"

cleanup() {
  if [[ -d "$scratch_path" ]]; then
    rm -rf -- "$scratch_path"
  fi
  rmdir "$example/.kotlin/sessions" 2>/dev/null || true
  rmdir "$example/.kotlin" 2>/dev/null || true
}
trap cleanup EXIT

if [[ -z "${JAVA_HOME:-}" ]] && ! java -version >/dev/null 2>&1; then
  android_studio_jbr="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
  if [[ -x "$android_studio_jbr/bin/java" ]]; then
    export JAVA_HOME="$android_studio_jbr"
  else
    echo "No JDK found; set JAVA_HOME to a supported JDK." >&2
    exit 1
  fi
fi

if [[ -z "${ANDROID_HOME:-}" && -z "${ANDROID_SDK_ROOT:-}" ]]; then
  default_android_sdk="${HOME}/Library/Android/sdk"
  if [[ -d "$default_android_sdk" ]]; then
    export ANDROID_HOME="$default_android_sdk"
  else
    echo "No Android SDK found; set ANDROID_HOME or ANDROID_SDK_ROOT." >&2
    exit 1
  fi
fi

if [[ -e "$example/.gradle" || -e "$example/.kotlin" || -e "$example/build" ]]; then
  echo "Example contains generated build state; remove .gradle/.kotlin/build before validation." >&2
  exit 1
fi

if [[ -n "${KOTLIN_STATE_MACHINE_CHECKOUT:-}" ]]; then
  state_machine_checkout="$KOTLIN_STATE_MACHINE_CHECKOUT"
  actual_revision="$(git -C "$state_machine_checkout" rev-parse HEAD)"
  if [[ "$actual_revision" != "$state_machine_revision" ]]; then
    echo "Kotlin State Machine checkout is $actual_revision; expected $state_machine_revision." >&2
    exit 1
  fi
else
  state_machine_checkout="$scratch_path/KotlinStateMachine"
  git init --quiet "$state_machine_checkout"
  git -C "$state_machine_checkout" remote add origin https://github.com/sideeffect-io/KotlinStateMachine.git
  git -C "$state_machine_checkout" fetch --quiet --depth 1 origin "$state_machine_revision"
  git -C "$state_machine_checkout" checkout --quiet --detach FETCH_HEAD
fi

actual_state_machine_version="$(sed -n 's/^VERSION_NAME=//p' "$state_machine_checkout/gradle.properties")"
if [[ "$actual_state_machine_version" != "$state_machine_version" ]]; then
  echo "Kotlin State Machine checkout declares $actual_state_machine_version; expected $state_machine_version." >&2
  exit 1
fi

run_gradle() {
  (
    cd "$scratch_path"
    GRADLE_USER_HOME="$scratch_path/gradle-home" "$gradle_bin" \
      --no-daemon \
      --project-dir "$example" \
      --project-cache-dir "$scratch_path/project-cache" \
      "-Dorg.gradle.jvmargs=-Xmx2048m -XX:MaxMetaspaceSize=1024m -Dfile.encoding=UTF-8" \
      -Dkotlin.project.persistent.dir="$scratch_path/kotlin-project" \
      -PkotlinStateMachineCheckout="$state_machine_checkout" \
      -PexampleBuildDir="$scratch_path/build" \
      "$@"
  )
}

python3 "$skill_dir/scripts/test_inventory_gradle.py"

run_gradle \
  :profile-data-impl:testDebugUnitTest \
  :profile-feature:testDebugUnitTest \
  :profile-feature:assembleDebugAndroidTest \
  :app-composition:assembleDebug \
  :consumer-smoke:assembleDebug

run_gradle \
  :profile-feature:lintDebug \
  :profile-navigation:lintDebug \
  :app-composition:lintDebug \
  :consumer-smoke:lintDebug

boundary_compile_log="$scratch_path/boundary-negative-compile.log"
if run_gradle :consumer-smoke:compileBoundaryNegativeFeatureAccess \
  >"$boundary_compile_log" 2>&1; then
  cat "$boundary_compile_log" >&2
  echo "consumer-smoke compiled a forbidden direct profile-feature reference." >&2
  exit 1
fi
if ! grep -q "package example.feature does not exist" "$boundary_compile_log"; then
  cat "$boundary_compile_log" >&2
  echo "negative consumer compilation failed for an unexpected reason." >&2
  exit 1
fi

android_test_summary="compiled Compose UI tests"
if [[ "${RUN_ANDROID_TESTS:-0}" == "1" ]]; then
  run_gradle :profile-feature:connectedDebugAndroidTest
  android_test_summary="ran connected Compose UI tests"
fi

python3 - "$example" <<'PY'
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

root = Path(sys.argv[1])
expected_graph = {
    "domain-model": set(),
    "http-framework": set(),
    "profile-data-api": {("api", "domain-model")},
    "profile-data-impl": {
        ("implementation", "domain-model"),
        ("api", "http-framework"),
        ("api", "profile-data-api"),
    },
    "profile-feature": {("api", "domain-model")},
    "profile-navigation": {("api", "domain-model"), ("implementation", "profile-feature")},
    "app-composition": {
        ("implementation", "http-framework"),
        ("implementation", "profile-data-api"),
        ("implementation", "profile-data-impl"),
        ("implementation", "profile-feature"),
        ("api", "profile-navigation"),
    },
    "consumer-smoke": {("implementation", "app-composition")},
}
for module, expected_dependencies in expected_graph.items():
    build_file = root / module / "build.gradle.kts"
    text = build_file.read_text(encoding="utf-8")
    actual_dependencies = set(
        re.findall(r'\b(api|implementation)\s*\(\s*project\(":([^"]+)"\)\s*\)', text)
    )
    if actual_dependencies != expected_dependencies:
        raise SystemExit(
            f"{module} project dependencies were {sorted(actual_dependencies)}, "
            f"expected {sorted(expected_dependencies)}"
        )
navigation_build_text = (root / "profile-navigation/build.gradle.kts").read_text(encoding="utf-8")
transitive_navigation_mutation = navigation_build_text.replace(
    'implementation(project(":profile-feature"))',
    'api(project(":profile-feature"))',
    1,
)
transitive_edges = set(
    re.findall(
        r'\b(api|implementation)\s*\(\s*project\(":([^"]+)"\)\s*\)',
        transitive_navigation_mutation,
    )
)
if transitive_edges == expected_graph["profile-navigation"]:
    raise SystemExit("transitive Navigation-to-Feature mutation is not rejected")

consumer = (
    root / "consumer-smoke/src/main/kotlin/example/consumer/HiltProfileConsumer.kt"
).read_text(encoding="utf-8")
for exposed_type in (
    "ProfileFlow",
    "ProfileDestination",
    "ProfileId",
    "Modifier",
):
    if exposed_type not in consumer:
        raise SystemExit(f"downstream API consumer does not compile against {exposed_type}")
for forbidden_seam in (
    "AppComposition",
    "HttpDataClient",
    "ProfileViewModel.Factory",
    "ViewModelProvider.Factory",
):
    if forbidden_seam in consumer:
        raise SystemExit(f"downstream API consumer exposes obsolete DI seam {forbidden_seam}")

feature_sources = "\n".join(
    path.read_text(encoding="utf-8")
    for path in sorted((root / "profile-feature/src/main/kotlin").rglob("*.kt"))
)
for forbidden_import in ("import example.data.", "import example.http."):
    if forbidden_import in feature_sources:
        raise SystemExit(f"profile-feature crosses its public port: {forbidden_import}")

machine_root = root / "profile-feature/src/main/kotlin/example/feature/statemachine"
views_root = root / "profile-feature/src/main/kotlin/example/feature/views"
canonical_machine_files = {
    f"Profile{suffix}.kt" for suffix in ("States", "Events", "Outputs", "StateMachine")
}


def has_canonical_machine_files(file_names):
    return canonical_machine_files <= set(file_names)


observed_machine_files = {path.name for path in machine_root.glob("*.kt")}
if not has_canonical_machine_files(observed_machine_files):
    raise SystemExit(
        f"Profile canonical machine files differ: {sorted(observed_machine_files)}"
    )
for negative_fixture in (
    canonical_machine_files - {"ProfileOutputs.kt"},
    {"ProfileStates.kt", "ProfileEvents.kt", "ProfileOutputs.kt", "ProfileMachine.kt"},
):
    if has_canonical_machine_files(negative_fixture):
        raise SystemExit("canonical machine-file negative fixture is accepted")
for file_name in canonical_machine_files:
    source = (machine_root / file_name).read_text(encoding="utf-8")
    if not source.startswith("package example.feature.statemachine\n"):
        raise SystemExit(f"machine source package does not match its path: {file_name}")
state_machine_owners = [
    path.name
    for path in machine_root.glob("*.kt")
    if "StateMachineFlow" in path.read_text(encoding="utf-8")
]
if state_machine_owners != ["ProfileStateMachine.kt"]:
    raise SystemExit(f"StateMachineFlow owner differs: {state_machine_owners}")
machine_sources = "\n".join(
    path.read_text(encoding="utf-8") for path in sorted(machine_root.glob("*.kt"))
)
if "import example.feature.views." in machine_sources:
    raise SystemExit("statemachine imports its sibling views package")
root_screens = sorted(path.name for path in views_root.glob("*RootScreen.kt"))
if root_screens != ["ProfileRootScreen.kt"]:
    raise SystemExit(f"Compose owner RootScreen differs: {root_screens}")
for path in views_root.glob("*.kt"):
    if not path.read_text(encoding="utf-8").startswith("package example.feature.views\n"):
        raise SystemExit(f"view source package does not match its path: {path.name}")
for obsolete_path in (
    root / "profile-feature/src/main/kotlin/example/feature/ProfileWorkflow.kt",
    root / "profile-feature/src/main/kotlin/example/feature/ProfileViewModel.kt",
    root / "profile-feature/src/main/kotlin/example/feature/ProfileScreen.kt",
):
    if obsolete_path.exists():
        raise SystemExit(f"profile feature retains flat owner source: {obsolete_path.name}")

framework_sources = "\n".join(
    path.read_text(encoding="utf-8")
    for path in sorted((root / "http-framework/src/main/kotlin").rglob("*.kt"))
)
for application_vocabulary in ("Profile", "example.domain", "example.data", "example.feature"):
    if application_vocabulary in framework_sources:
        raise SystemExit(
            f"http-framework contains application vocabulary/dependency: {application_vocabulary}"
        )

data_sources = "\n".join(
    path.read_text(encoding="utf-8")
    for path in sorted((root / "profile-data-impl/src/main/kotlin").rglob("*.kt"))
)
for forbidden_import in ("import example.feature.", "import example.navigation.", "import example.app."):
    if forbidden_import in data_sources:
        raise SystemExit(f"profile-data-impl crosses outward: {forbidden_import}")

navigation_sources = "\n".join(
    path.read_text(encoding="utf-8")
    for path in sorted((root / "profile-navigation/src/main/kotlin").rglob("*.kt"))
)
for forbidden_import in ("import example.data.", "import example.http."):
    if forbidden_import in navigation_sources:
        raise SystemExit(f"profile-navigation reaches a concrete data edge: {forbidden_import}")

screen = (views_root / "ProfileRootScreen.kt").read_text(encoding="utf-8")
start = screen.index("fun ProfileScreen(")
header = screen[start : screen.index("{", start)]
if ":" in header.rsplit(")", 1)[-1]:
    raise SystemExit("ProfileScreen must emit Compose UI and return Unit")
for required_call in ("Column(", "Button(", "stringResource("):
    if required_call not in screen:
        raise SystemExit(f"ProfileScreen does not emit representative UI: missing {required_call}")

resource_root = root / "profile-feature/src/main/res"
resource_files = sorted(resource_root.glob("values*/strings.xml"))
if len(resource_files) != 4:
    raise SystemExit(f"expected four locale resources, found {len(resource_files)}")
resource_keys = {
    path.parent.name: {item.attrib["name"] for item in ET.parse(path).getroot().findall("string")}
    for path in resource_files
}
expected_keys = next(iter(resource_keys.values()))
if any(keys != expected_keys for keys in resource_keys.values()):
    raise SystemExit(f"localization keys differ: {resource_keys}")
used_keys = set(re.findall(r"R\.string\.([A-Za-z0-9_]+)", screen))
if used_keys != expected_keys:
    raise SystemExit(
        f"source/resource key parity failed: used={sorted(used_keys)}, resources={sorted(expected_keys)}"
    )

screen_test = (
    root
    / "profile-feature/src/androidTest/kotlin/example/feature/views/ProfileRootScreenTest.kt"
).read_text(encoding="utf-8")
for contract in (
    "assertHasClickAction()",
    "performClick()",
    "ProgressBarRangeInfo.Indeterminate",
    "targetContext.getString",
    "onLoad = { reloadCount += 1 }",
    "assertEquals(1, reloadCount)",
):
    if contract not in screen_test:
        raise SystemExit(f"Compose UI test contract missing {contract}")
if screen_test.count("@Test") != 4:
    raise SystemExit("Compose UI example must cover four representative screen behaviors")

domain = (root / "domain-model/src/main/kotlin/example/domain/Profile.kt").read_text(encoding="utf-8")
workflow = "\n".join(
    (machine_root / file_name).read_text(encoding="utf-8")
    for file_name in (
        "ProfileStates.kt",
        "ProfileEvents.kt",
        "ProfileOutputs.kt",
        "ProfileStateMachine.kt",
    )
)
workflow_test = (
    root
    / "profile-feature/src/test/kotlin/example/feature/statemachine/ProfileStateMachineTest.kt"
).read_text(encoding="utf-8")
composition = (root / "app-composition/src/main/kotlin/example/app/AppComposition.kt").read_text(
    encoding="utf-8"
) if (root / "app-composition/src/main/kotlin/example/app/AppComposition.kt").exists() else ""
integration = (
    root / "app-composition/src/main/kotlin/example/app/ProfileIntegrationBindings.kt"
).read_text(encoding="utf-8")
view_model = (
    views_root / "ProfileViewModel.kt"
).read_text(encoding="utf-8")
data_bindings = (
    root / "profile-data-impl/src/main/kotlin/example/data/ProfileDataBindings.kt"
).read_text(encoding="utf-8")
for contract in (
    "kotlin-suite-example: profile-load/v1",
    "sealed interface ProfileLoadResult",
):
    if contract not in domain:
        raise SystemExit(f"domain contract missing {contract}")
for contract in (
    "LoadProfile",
    "ProfileLoadWasRequested",
    "requestId",
    "lifecycle = replaceableLoad",
):
    if contract not in workflow:
        raise SystemExit(f"workflow contract missing {contract}")
def workflow_semantic_errors(source):
    errors = []
    if re.search(r"\bWhen\s*\(\s*states\s*=", source):
        errors.append("workflow groups concrete current states in one route")
    if re.search(r"\bguard\s*=\s*\{", source):
        errors.append("workflow uses an inline route guard")
    if re.search(r"\bCancel(?:\s*<[^>]+>)?\s*\{", source):
        errors.append("workflow uses an inline cancellation policy")
    declarations = list(
        re.finditer(r"internal\s+data\s+(?:object|class)\s+(\w+)", source)
    )
    state_names = []
    event_names = []
    for index, declaration in enumerate(declarations):
        end = declarations[index + 1].start() if index + 1 < len(declarations) else len(source)
        declaration_source = source[declaration.start():end]
        if re.search(r":\s*ProfileState\s*\(", declaration_source):
            state_names.append(declaration.group(1))
        if re.search(r":\s*ProfileEvent\b", declaration_source):
            event_names.append(declaration.group(1))
    if not state_names or any(not name.startswith("ProfileIs") for name in state_names):
        errors.append(f"workflow concrete states are not flat ProfileIs... types: {state_names}")
    if not event_names or any(
        not name.startswith("Profile") or ("Was" not in name and "Did" not in name)
        for name in event_names
    ):
        errors.append(f"workflow concrete events are not observed Profile facts: {event_names}")
    for state_name in state_names:
        route = f"When(state = {state_name}::class)"
        if source.count(route) != 1:
            errors.append(f"workflow must declare exactly one concrete route block for {state_name}")
    guard_references = re.findall(r"\bguard\s*=\s*([^,\n]+)", source)
    if not guard_references or any(
        re.fullmatch(r"ProfileGuards::[A-Za-z][A-Za-z0-9_]*", guard.strip()) is None
        for guard in guard_references
    ):
        errors.append(f"workflow guards are not capture-free named references: {guard_references}")
    if "predicate = ProfilePolicies::shouldReplaceLoad" not in source:
        errors.append("workflow cancellation is not a capture-free named policy")
    return errors

workflow_errors = workflow_semantic_errors(workflow)
if workflow_errors:
    raise SystemExit("; ".join(workflow_errors))
workflow_mutations = {
    "grouped-route": workflow + "\nWhen(states = { +ProfileIsIdle::class }) {}\n",
    "inline-guard": workflow.replace(
        "guard = ProfileGuards::idleInputChanged",
        "guard = { state, event -> state.input != event.input }",
        1,
    ),
}
for mutation_name, mutation in workflow_mutations.items():
    if not workflow_semantic_errors(mutation):
        raise SystemExit(f"workflow semantic mutation is not rejected: {mutation_name}")
for test_contract in (
    "repeatedEquivalentInputEmitsNothingAndDoesNotRunCapability",
    "assertEquals(emissionCountBeforeRejectedInput, observedStates.size)",
    "assertEquals(capabilityInvocationsBeforeRejectedInput, capabilityInvocations)",
    "staleCompletionEmitsNothingAndDoesNotRunCapabilityAgain",
    "assertEquals(emissionCountBeforeStaleResult, observedStates.size)",
    "assertEquals(capabilityInvocationsBeforeStaleResult, capabilityInvocations)",
):
    if test_contract not in workflow_test:
        raise SystemExit(f"workflow no-route test contract missing {test_contract}")
if composition:
    raise SystemExit("compiled fixture retains obsolete AppComposition")
for contract in (
    "@Module",
    "@InstallIn(SingletonComponent::class)",
    "HttpDataClient",
    "ProfileRepository",
    "LoadProfile(repository::load)",
):
    if contract not in integration:
        raise SystemExit(f"app integration bindings missing {contract}")
for contract in (
    "@Binds",
    "ProfileRepository",
    "RemoteProfileRepository",
):
    if contract not in data_bindings:
        raise SystemExit(f"owner-local Datasource binding missing {contract}")
for contract in (
    "@HiltViewModel(assistedFactory = ProfileViewModelAssistedFactory::class)",
    "@AssistedInject constructor(",
    "@Assisted input: ProfileInput",
    "ProfileMachineFactory",
    "machineFactory.create(viewModelScope, input)",
    "@AssistedFactory",
):
    if contract not in view_model:
        raise SystemExit(f"destination ViewModel ownership contract missing {contract}")
if view_model.count("machineFactory.create(viewModelScope, input)") != 1:
    raise SystemExit("destination ViewModel must create its machine exactly once")
navigation_build = (root / "profile-navigation/build.gradle.kts").read_text(encoding="utf-8")
if 'implementation(project(":profile-feature"))' not in navigation_build:
    raise SystemExit("Navigation must keep its Feature implementation dependency non-transitive")
negative_consumer_build = (root / "consumer-smoke/build.gradle.kts").read_text(encoding="utf-8")
negative_consumer = (
    root
    / "consumer-smoke/src/boundaryNegative/java/example/consumer/ForbiddenFeatureAccess.java"
).read_text(encoding="utf-8")
if "compileBoundaryNegativeFeatureAccess" not in negative_consumer_build:
    raise SystemExit("consumer boundary negative compile task is missing")
if "import example.feature.ProfileInput;" not in negative_consumer:
    raise SystemExit("consumer boundary negative source does not exercise direct Feature access")
for contract in (
    "hiltViewModel<ProfileViewModel, ProfileViewModelAssistedFactory>",
    'key = "ProfileViewModel/${input.profileId.value}"',
    "factory.create(input)",
):
    if contract not in screen:
        raise SystemExit(f"assisted Route ownership contract missing {contract}")

all_production_sources = "\n".join(
    path.read_text(encoding="utf-8")
    for path in sorted(root.glob("*/src/main/**/*.kt"))
)
for obsolete_contract in (
    "ViewModelProvider.Factory",
    "ProfileViewModel.Factory",
    "class AppComposition",
):
    if obsolete_contract in all_production_sources:
        raise SystemExit(f"compiled fixture retains obsolete DI contract {obsolete_contract}")
for forbidden_binding in (
    "@Provides\n    fun provideStateMachineFlow",
    "@Provides\n    fun provideCoroutineScope",
    "@Binds\n    abstract fun bindStateMachineFlow",
    "@Binds\n    abstract fun bindCoroutineScope",
):
    if forbidden_binding in all_production_sources:
        raise SystemExit(f"Hilt must not own a machine or coroutine scope: {forbidden_binding}")

print(
    "Validated Domain, Frameworks, Datasources, Feature, Navigation, and owner-local Hilt "
    "boundaries; canonical Feature statemachine/views packages; an assisted destination-owned "
    "machine; a downstream Navigation consumer; repository and state-machine tests; real "
    "Compose UI; compiled UI tests; lint; assembly; and four-locale source/resource parity."
)
PY

echo "Architect fixture $android_test_summary."
