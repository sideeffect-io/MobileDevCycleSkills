#!/usr/bin/env bash
set -euo pipefail
export PYTHONDONTWRITEBYTECODE=1

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
example="$skill_dir/assets/ProductionExample"
gradle_bin="${GRADLE_BIN:-$example/gradlew}"
state_machine_revision="bae612b9ac8b23e5ac349c463081bac740620206"
state_machine_version="0.1.0-SNAPSHOT"
scratch_path="$(mktemp -d "${TMPDIR:-/tmp}/kotlin-developer-example.XXXXXX")"
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

run_gradle \
  :profile-feature:testDebugUnitTest \
  :profile-feature:assembleDebug \
  :profile-feature:assembleDebugAndroidTest

run_gradle :profile-feature:lintDebug

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
source_root = root / "profile/src/main/kotlin/example/profile"
screen = (source_root / "ProfileScreen.kt").read_text(encoding="utf-8")
models = (source_root / "ProfileModels.kt").read_text(encoding="utf-8")
workflow = (source_root / "ProfileWorkflow.kt").read_text(encoding="utf-8")
view_model = (source_root / "ProfileViewModel.kt").read_text(encoding="utf-8")

start = screen.index("fun ProfileScreen(")
header = screen[start : screen.index("{", start)]
if ":" in header.rsplit(")", 1)[-1]:
    raise SystemExit("ProfileScreen must emit Compose UI and return Unit")
for required_call in ("Column(", "Button(", "CircularProgressIndicator(", "stringResource("):
    if required_call not in screen:
        raise SystemExit(f"ProfileScreen does not emit representative UI: missing {required_call}")
if "ProfileRenderModel" in "\n".join(path.read_text(encoding="utf-8") for path in source_root.glob("*.kt")):
    raise SystemExit("render-model-returning composables are not a representative Compose screen")

resource_root = root / "profile/src/main/res"
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
    root / "profile/src/androidTest/kotlin/example/profile/ProfileScreenTest.kt"
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

for contract in ("kotlin-suite-example: profile-load/v1", "sealed interface ProfileLoadResult"):
    if contract not in models:
        raise SystemExit(f"model contract missing {contract}")
for contract in ("ProfileLoadRequested", "requestId", "lifecycle = replaceableLoad"):
    if contract not in workflow:
        raise SystemExit(f"workflow contract missing {contract}")
for contract in ("viewModelScope", "StateFlow<ProfileUiState>", "class Factory("):
    if contract not in view_model:
        raise SystemExit(f"ViewModel ownership contract missing {contract}")

root_build = (root / "build.gradle.kts").read_text(encoding="utf-8")
for version in ('version "9.3.0"', 'version "2.4.10"'):
    if version not in root_build:
        raise SystemExit(f"expected aligned toolchain pin {version}")

print(
    "Validated state-machine and repository tests, real Compose UI, compiled UI tests, "
    "warnings-as-errors lint, assembly, aligned toolchain pins, and four-locale "
    "source/resource parity."
)
PY

echo "Developer fixture $android_test_summary."
