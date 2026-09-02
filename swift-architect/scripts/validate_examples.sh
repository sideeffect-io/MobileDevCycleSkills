#!/usr/bin/env bash
set -euo pipefail

skill_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
example="$skill_dir/assets/ArchitectureExample"
swift_bin="${SWIFT_BIN:-swift}"

if [[ -e "$example/.build" || -e "$example/.swiftpm" ]]; then
  echo "Example contains generated build state; remove .build/.swiftpm before validation." >&2
  exit 1
fi

scratch_path="$(mktemp -d "${TMPDIR:-/tmp}/swift-architect-package.XXXXXX")"
derived_data=""

cleanup() {
  if [[ -n "$derived_data" && -d "$derived_data" ]]; then
    rm -rf -- "$derived_data"
  fi
  if [[ -d "$scratch_path" ]]; then
    rm -rf -- "$scratch_path"
  fi
  rm -rf -- "$example/.build" "$example/.swiftpm"
}
trap cleanup EXIT

"$swift_bin" package --package-path "$example" dump-package | python3 -c '
import json
import sys

package = json.load(sys.stdin)
targets = {target["name"]: target for target in package["targets"]}

def dependencies(target_name):
    result = set()
    for dependency in targets[target_name]["dependencies"]:
        if "byName" in dependency:
            result.add(dependency["byName"][0])
        elif "product" in dependency:
            result.add(dependency["product"][0])
    return result

expected = {
    "DomainModel": set(),
    "DomainModelTests": {"DomainModel"},
    "HTTPFramework": set(),
    "HTTPFrameworkTests": {"HTTPFramework"},
    "ProfileDataSource": {"DomainModel", "HTTPFramework"},
    "ProfileDataSourceTests": {"DomainModel", "HTTPFramework", "ProfileDataSource"},
    "ProfileFeature": {"DomainModel", "StateMachineCore"},
    "ProfileFeatureTests": {"DomainModel", "ProfileFeature", "StateMachineTest"},
    "ProfileNavigation": {"DomainModel", "ProfileFeature"},
    "ProfileNavigationTests": {"DomainModel", "ProfileNavigation"},
    "AppComposition": {
        "DomainModel",
        "HTTPFramework",
        "ProfileDataSource",
        "ProfileFeature",
        "ProfileNavigation",
        "StateMachineCore",
    },
    "AppCompositionTests": {
        "AppComposition",
        "DomainModel",
        "HTTPFramework",
        "ProfileFeature",
        "StateMachineCore",
    },
}

for target_name, expected_dependencies in expected.items():
    actual = dependencies(target_name)
    if actual != expected_dependencies:
        raise SystemExit(
            f"{target_name} dependencies were {sorted(actual)}, "
            f"expected {sorted(expected_dependencies)}"
        )
'
echo "Validated Frameworks/Datasources dependency graph."

inventory="$scratch_path/inventory.json"
python3 "$skill_dir/scripts/inventory_swiftpm.py" "$example" \
  --format json \
  --output "$inventory"
python3 - "$inventory" <<'PY'
import json
import sys

package = json.load(open(sys.argv[1], encoding="utf-8"))["packages"][0]
targets = {target["name"]: target for target in package["targets"]}
module_names = set(targets) | {"StateMachineCore", "StateMachineTest"}

for target_name, target in targets.items():
    if target["swift_files"] == 0:
        raise SystemExit(f"{target_name} inventory unexpectedly contains no Swift files")

    dependencies = {
        dependency.split(" (product from ", 1)[0]
        for dependency in target["declared_dependencies"]
    }
    imported_modules = set(target["imports"]) & module_names
    missing = imported_modules - dependencies
    unused = (dependencies & module_names) - imported_modules
    if missing or unused:
        raise SystemExit(
            f"{target_name} dependency/import mismatch: "
            f"missing={sorted(missing)}, unused={sorted(unused)}"
        )
PY
echo "Validated source inventory and direct dependency/import parity."

python3 - "$example/Sources/ProfileFeature" <<'PY'
import re
import sys
from pathlib import Path

feature = Path(sys.argv[1])
resources = feature / "Resources"
expected_locales = {"de", "en", "es", "fr"}
locale_files = {
    path.parent.name.removesuffix(".lproj"): path
    for path in resources.glob("*.lproj/Localizable.strings")
}
if set(locale_files) != expected_locales:
    raise SystemExit(
        f"locales were {sorted(locale_files)}, expected {sorted(expected_locales)}"
    )

key_pattern = re.compile(r'^\s*"([^"]+)"\s*=', re.MULTILINE)
localized_keys = {
    locale: set(key_pattern.findall(path.read_text(encoding="utf-8")))
    for locale, path in locale_files.items()
}
reference_keys = localized_keys["en"]
for locale, keys in localized_keys.items():
    if keys != reference_keys:
        raise SystemExit(
            f"{locale} localization keys differ: "
            f"missing={sorted(reference_keys - keys)}, extra={sorted(keys - reference_keys)}"
        )

source_keys = set()
source_pattern = re.compile(r'String\(localized:\s*"([^"]+)"')
for source in feature.rglob("*.swift"):
    source_keys.update(source_pattern.findall(source.read_text(encoding="utf-8")))
if source_keys != reference_keys:
    raise SystemExit(
        "source/localization key mismatch: "
        f"missing={sorted(source_keys - reference_keys)}, "
        f"unused={sorted(reference_keys - source_keys)}"
    )
PY
echo "Validated four-locale source/resource key parity."

"$swift_bin" test --package-path "$example" --scratch-path "$scratch_path/swiftpm"
echo "Validated host Swift tests."
find "$scratch_path/swiftpm" -depth -delete

if [[ "$(uname -s)" == "Darwin" ]] && command -v xcodebuild >/dev/null 2>&1; then
  scheme="$({
    cd "$example"
    xcodebuild \
      -list \
      -json \
      -clonedSourcePackagesDirPath "$scratch_path/xcode-packages" \
      2>/dev/null
  } | python3 -c '
import json, sys
schemes = json.load(sys.stdin)["workspace"]["schemes"]
preferred = "ArchitectureExample-Package"
matches = [item for item in schemes if item == preferred]
if len(matches) != 1:
    raise SystemExit(f"expected one {preferred} scheme, found {matches}")
print(matches[0])
')"
  derived_data="$(mktemp -d "${TMPDIR:-/tmp}/swift-architect-ios.XXXXXX")"
  (
    cd "$example"
    xcodebuild \
      -scheme "$scheme" \
      -destination "generic/platform=iOS Simulator" \
      -derivedDataPath "$derived_data" \
      -clonedSourcePackagesDirPath "$scratch_path/xcode-packages" \
      CODE_SIGNING_ALLOWED=NO \
      build \
      -quiet
  )
  echo "Validated generic iOS Simulator build."
else
  echo "Skipped iOS Simulator build because Xcode is unavailable on this host."
fi
