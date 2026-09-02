#!/usr/bin/env python3
"""Create a read-only, best-effort inventory of a Gradle Kotlin/Android project.

This script intentionally does not execute Gradle. It extracts literal declarations from
settings/build/version-catalog files and reports dynamic constructs as limitations. Treat the
result as navigation evidence, never as a complete resolved dependency graph.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any


INCLUDE_PATTERN = re.compile(r"\binclude\s*\((.*?)\)", re.DOTALL)
QUOTED_PATTERN = re.compile(r"['\"](:[^'\"]+)['\"]")
PROJECT_DIR_PATTERN = re.compile(
    r"\bproject\s*\(\s*['\"](:[^'\"]+)['\"]\s*\)\s*\.projectDir\s*=\s*"
    r"file\s*\(\s*['\"]([^'\"]+)['\"]\s*\)",
    re.DOTALL,
)
PROJECT_CALL_PATTERN = re.compile(
    r"\b(?:api|implementation|compileOnly|runtimeOnly|ksp|kapt|testImplementation|"
    r"androidTestImplementation|debugImplementation)\s*\(\s*project\s*\(\s*"
    r"(?:path\s*=\s*)?['\"](:[^'\"]*)['\"]",
    re.DOTALL,
)
PROJECT_ACCESSOR_PATTERN = re.compile(
    r"\b(?:api|implementation|compileOnly|runtimeOnly|ksp|kapt|testImplementation|"
    r"androidTestImplementation|debugImplementation)\s*\(\s*projects\.([A-Za-z0-9_.]+)"
)
PLUGIN_PATTERN = re.compile(
    r"\bid\s*\(\s*['\"]([^'\"]+)['\"]\s*\)|\balias\s*\(\s*libs\.plugins\.([A-Za-z0-9_.]+)"
)
EXTERNAL_DEPENDENCY_PATTERN = re.compile(
    r"\b(api|implementation|compileOnly|runtimeOnly|ksp|kapt|testImplementation|"
    r"androidTestImplementation|debugImplementation)\s*\(\s*['\"]"
    r"([^:'\"]+:[^:'\"]+)(?::[^'\"]+)?['\"]"
)
CATALOG_DEPENDENCY_PATTERN = re.compile(
    r"\b(api|implementation|compileOnly|runtimeOnly|ksp|kapt|testImplementation|"
    r"androidTestImplementation|debugImplementation)\s*\(\s*libs\.([A-Za-z0-9_.]+)"
)
ANDROID_VALUE_PATTERNS = {
    "namespace": re.compile(r"\bnamespace\s*=\s*['\"]([^'\"]+)['\"]"),
    "compileSdk": re.compile(r"\bcompileSdk\s*=\s*([^\n]+)"),
    "minSdk": re.compile(r"\bminSdk\s*=\s*([^\n]+)"),
    "targetSdk": re.compile(r"\btargetSdk\s*=\s*([^\n]+)"),
    "jvmTarget": re.compile(r"\bjvmTarget\s*=\s*([^\n]+)"),
}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".", help="Gradle project root")
    parser.add_argument("--format", choices=("json", "markdown"), default="markdown")
    return parser.parse_args()


def read(path: Path) -> str:
    return path.read_text(encoding="utf-8", errors="replace")


def module_path_to_directory(root: Path, module: str) -> Path:
    return root.joinpath(*module.removeprefix(":").split(":"))


def accessor_to_module(accessor: str) -> str:
    return ":" + accessor.replace(".", ":")


def literal_modules(settings_text: str) -> list[str]:
    modules: set[str] = set()
    for include_body in INCLUDE_PATTERN.findall(settings_text):
        modules.update(QUOTED_PATTERN.findall(include_body))
    return sorted(modules)


def literal_project_directories(root: Path, settings_text: str) -> dict[str, Path]:
    directories: dict[str, Path] = {}
    for module, relative_directory in PROJECT_DIR_PATTERN.findall(settings_text):
        directories[module] = (root / relative_directory).resolve()
    return directories


def find_build_file(directory: Path) -> Path | None:
    for name in ("build.gradle.kts", "build.gradle"):
        candidate = directory / name
        if candidate.is_file():
            return candidate
    return None


def relative(path: Path, root: Path) -> str:
    try:
        return path.relative_to(root).as_posix()
    except ValueError:
        return str(path)


def source_sets(directory: Path) -> list[str]:
    source_root = directory / "src"
    if not source_root.is_dir():
        return []
    return sorted(path.name for path in source_root.iterdir() if path.is_dir())


def inspect_module(
    root: Path,
    module: str,
    project_directories: dict[str, Path] | None = None,
) -> dict[str, Any]:
    directory = (project_directories or {}).get(module, module_path_to_directory(root, module))
    build_file = find_build_file(directory)
    if build_file is None:
        return {
            "path": module,
            "directory": relative(directory, root),
            "build_file": None,
            "missing_build_file": True,
            "project_dependencies": [],
            "external_dependencies": [],
            "plugins": [],
            "source_sets": source_sets(directory),
            "android": {},
        }

    text = read(build_file)
    project_dependencies = set(PROJECT_CALL_PATTERN.findall(text))
    project_dependencies.update(
        accessor_to_module(accessor) for accessor in PROJECT_ACCESSOR_PATTERN.findall(text)
    )
    plugins = {
        direct or f"libs.plugins.{alias}"
        for direct, alias in PLUGIN_PATTERN.findall(text)
    }
    external_dependencies = {
        f"{configuration}:{coordinate}"
        for configuration, coordinate in EXTERNAL_DEPENDENCY_PATTERN.findall(text)
    }
    external_dependencies.update(
        f"{configuration}:libs.{alias}"
        for configuration, alias in CATALOG_DEPENDENCY_PATTERN.findall(text)
    )
    android = {}
    for key, pattern in ANDROID_VALUE_PATTERNS.items():
        match = pattern.search(text)
        if match:
            android[key] = match.group(1).strip().rstrip(",")

    return {
        "path": module,
        "directory": relative(directory, root),
        "build_file": relative(build_file, root),
        "missing_build_file": False,
        "project_dependencies": sorted(project_dependencies),
        "external_dependencies": sorted(external_dependencies),
        "plugins": sorted(plugins),
        "source_sets": source_sets(directory),
        "android": android,
    }


def inventory(root: Path) -> dict[str, Any]:
    settings = next(
        (path for path in (root / "settings.gradle.kts", root / "settings.gradle") if path.is_file()),
        None,
    )
    if settings is None:
        raise ValueError(f"no settings.gradle(.kts) found under {root}")

    settings_text = read(settings)
    modules = literal_modules(settings_text)
    project_directories = literal_project_directories(root, settings_text)
    root_build = find_build_file(root)
    catalogs = sorted(
        relative(path, root)
        for path in (root / "gradle").glob("*.toml")
        if path.is_file()
    )
    wrapper = root / "gradle/wrapper/gradle-wrapper.properties"
    locks = sorted(relative(path, root) for path in root.glob("**/*.lockfile") if path.is_file())
    verification = root / "gradle/verification-metadata.xml"

    limitations = [
        "Only literal include(...), project(...).projectDir = file(...), and common dependency call shapes are parsed.",
        "Convention plugins, buildSrc, included builds, variant-aware resolution, aliases, and dynamic Gradle code require live inspection.",
        "Run repository-approved Gradle dependency/model tasks before making an architecture verdict.",
    ]
    if "includeBuild" in settings_text:
        limitations.append("settings declares includeBuild; included-build modules are not expanded.")
    if not modules:
        limitations.append("No literal module include was found; settings may construct modules dynamically.")

    return {
        "root": str(root),
        "settings": relative(settings, root),
        "root_build_file": relative(root_build, root) if root_build else None,
        "gradle_wrapper": relative(wrapper, root) if wrapper.is_file() else None,
        "version_catalogs": catalogs,
        "dependency_locks": locks,
        "verification_metadata": relative(verification, root) if verification.is_file() else None,
        "modules": [
            inspect_module(root, module, project_directories)
            for module in modules
        ],
        "limitations": limitations,
    }


def render_markdown(document: dict[str, Any]) -> str:
    lines = [
        "# Gradle inventory",
        "",
        f"- Root: `{document['root']}`",
        f"- Settings: `{document['settings']}`",
        f"- Literal modules: {len(document['modules'])}",
        "",
        "| Module | Directory | Build file | Project dependencies | Source sets |",
        "| --- | --- | --- | --- | --- |",
    ]
    for module in document["modules"]:
        dependencies = ", ".join(f"`{item}`" for item in module["project_dependencies"]) or "-"
        sets = ", ".join(f"`{item}`" for item in module["source_sets"]) or "-"
        build_file = f"`{module['build_file']}`" if module["build_file"] else "missing"
        lines.append(
            f"| `{module['path']}` | `{module['directory']}` | {build_file} | "
            f"{dependencies} | {sets} |"
        )
    lines.extend(["", "## Limitations", ""])
    lines.extend(f"- {item}" for item in document["limitations"])
    return "\n".join(lines) + "\n"


def main() -> int:
    args = parse_args()
    root = Path(args.root).expanduser().resolve()
    try:
        document = inventory(root)
    except (OSError, ValueError) as error:
        print(f"inventory failed: {error}", file=sys.stderr)
        return 1

    if args.format == "json":
        print(json.dumps(document, indent=2, sort_keys=True))
    else:
        print(render_markdown(document), end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
