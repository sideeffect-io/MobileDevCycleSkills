#!/usr/bin/env python3
"""Inventory SwiftPM targets, declared dependencies, imports, and source size.

This script is deliberately descriptive. It does not guess which imports map to
which package products or declare an architecture pass/fail result.
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
from pathlib import Path
from typing import Any


SKIPPED_DIRECTORIES = {
    ".agents",
    ".build",
    ".codex",
    ".git",
    ".idea",
    ".swiftpm",
    ".vscode",
    "Build",
    "DerivedData",
    "Pods",
    "Carthage",
}
IMPORT_PATTERN = re.compile(
    r"^\s*(?:(?:@testable|@_exported|@_implementationOnly)\s+)?import\s+([A-Za-z_]\w*)",
    re.MULTILINE,
)
PUBLIC_PATTERN = re.compile(
    r"^\s*(?:@[A-Za-z_]\w*(?:\([^\n]*\))?\s+)*(?:public|open)\s+",
    re.MULTILINE,
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Inventory SwiftPM manifests and production/test source evidence."
    )
    parser.add_argument(
        "root",
        nargs="?",
        default=".",
        help="Repository, package directory, or Package.swift path (default: current directory).",
    )
    parser.add_argument(
        "--format",
        choices=("markdown", "json"),
        default="markdown",
        help="Output format.",
    )
    parser.add_argument("--output", help="Optional output path; stdout is the default.")
    return parser.parse_args()


def find_manifests(root: Path) -> list[Path]:
    if root.is_file():
        if root.name != "Package.swift":
            raise ValueError(f"Expected Package.swift, got: {root}")
        return [root.resolve()]

    manifests: list[Path] = []
    for candidate in root.rglob("Package.swift"):
        relative_parts = candidate.relative_to(root).parts
        if any(part in SKIPPED_DIRECTORIES for part in relative_parts[:-1]):
            continue
        manifests.append(candidate.resolve())
    return sorted(set(manifests))


def dump_package(package_path: Path) -> dict[str, Any]:
    result = subprocess.run(
        ["swift", "package", "--package-path", str(package_path), "dump-package"],
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"swift package dump-package failed for {package_path}:\n{result.stderr.strip()}"
        )
    return json.loads(result.stdout)


def dependency_name(raw: dict[str, Any]) -> str:
    for kind in ("target", "product", "byName"):
        value = raw.get(kind)
        if isinstance(value, list) and value:
            name = str(value[0])
            if kind == "product" and len(value) > 1 and value[1]:
                return f"{name} (product from {value[1]})"
            return name
    return json.dumps(raw, sort_keys=True)


def source_directory(package_path: Path, target: dict[str, Any]) -> Path:
    explicit_path = target.get("path")
    if explicit_path:
        return package_path / str(explicit_path)
    group = "Tests" if target.get("type") == "test" else "Sources"
    return package_path / group / str(target["name"])


def swift_files(directory: Path) -> list[Path]:
    if not directory.exists():
        return []
    return sorted(
        path
        for path in directory.rglob("*.swift")
        if not any(
            part in SKIPPED_DIRECTORIES
            for part in path.relative_to(directory).parts[:-1]
        )
    )


def inspect_target(package_path: Path, target: dict[str, Any]) -> dict[str, Any]:
    directory = source_directory(package_path, target)
    files = swift_files(directory)
    imports: set[str] = set()
    nonblank_lines = 0
    public_declarations = 0

    for path in files:
        text = path.read_text(encoding="utf-8")
        imports.update(IMPORT_PATTERN.findall(text))
        nonblank_lines += sum(1 for line in text.splitlines() if line.strip())
        public_declarations += len(PUBLIC_PATTERN.findall(text))

    return {
        "name": target["name"],
        "type": target.get("type", "unknown"),
        "source_path": str(directory),
        "declared_dependencies": sorted(
            dependency_name(item) for item in target.get("dependencies", [])
        ),
        "imports": sorted(imports),
        "swift_files": len(files),
        "nonblank_lines": nonblank_lines,
        "public_declarations": public_declarations,
    }


def inventory(manifest: Path) -> dict[str, Any]:
    package_path = manifest.parent
    dumped = dump_package(package_path)
    return {
        "name": dumped.get("name", package_path.name),
        "path": str(package_path),
        "tools_version": dumped.get("toolsVersion", {}).get("_version"),
        "platforms": [
            f"{item.get('platformName')} {item.get('version')}"
            for item in dumped.get("platforms", [])
        ],
        "targets": [inspect_target(package_path, target) for target in dumped.get("targets", [])],
    }


def render_markdown(packages: list[dict[str, Any]]) -> str:
    lines = ["# SwiftPM Inventory", ""]
    for package in packages:
        lines.extend(
            [
                f"## {package['name']}",
                "",
                f"- Path: `{package['path']}`",
                f"- Tools version: `{package['tools_version'] or 'unspecified'}`",
                f"- Platforms: {', '.join(package['platforms']) or 'unspecified'}",
                "",
                "| Target | Type | Declared dependencies | Imports | Files | Nonblank lines | Public declarations |",
                "| --- | --- | --- | --- | ---: | ---: | ---: |",
            ]
        )
        for target in package["targets"]:
            dependencies = ", ".join(target["declared_dependencies"]) or "-"
            imports = ", ".join(target["imports"]) or "-"
            lines.append(
                f"| `{target['name']}` | {target['type']} | {dependencies} | {imports} | "
                f"{target['swift_files']} | {target['nonblank_lines']} | "
                f"{target['public_declarations']} |"
            )
        lines.append("")
    lines.extend(
        [
            "> This is an evidence inventory. Inspect transitive system modules, conditional imports,",
            "> linker/plugin dependencies, generated sources, and product-to-module mappings before",
            "> declaring dependency/import parity or an architecture violation.",
            "",
        ]
    )
    return "\n".join(lines)


def main() -> int:
    args = parse_args()
    try:
        manifests = find_manifests(Path(args.root).expanduser().resolve())
        if not manifests:
            raise ValueError(f"No Package.swift found under {args.root}")
        packages = [inventory(manifest) for manifest in manifests]
    except (OSError, ValueError, RuntimeError, json.JSONDecodeError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 1

    rendered = (
        json.dumps({"packages": packages}, indent=2, sort_keys=True) + "\n"
        if args.format == "json"
        else render_markdown(packages)
    )
    if args.output:
        Path(args.output).expanduser().write_text(rendered, encoding="utf-8")
    else:
        print(rendered, end="")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
