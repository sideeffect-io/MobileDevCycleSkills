#!/usr/bin/env python3
"""Regression tests for literal Gradle project-directory remapping."""

from __future__ import annotations

import tempfile
from pathlib import Path

from inventory_gradle import inventory


def main() -> int:
    with tempfile.TemporaryDirectory(prefix="kotlin-inventory-regression.") as temporary:
        root = Path(temporary).resolve()
        (root / "settings.gradle.kts").write_text(
            '\n'.join(
                (
                    'rootProject.name = "InventoryRegression"',
                    'include(":domain", ":profile-feature")',
                    'project(":profile-feature").projectDir = file("profile")',
                )
            ),
            encoding="utf-8",
        )
        (root / "domain").mkdir()
        (root / "domain/build.gradle.kts").write_text("", encoding="utf-8")
        (root / "profile/src/main").mkdir(parents=True)
        (root / "profile/build.gradle.kts").write_text(
            'dependencies { implementation(project(":domain")) }\n',
            encoding="utf-8",
        )

        document = inventory(root)
        modules = {item["path"]: item for item in document["modules"]}
        profile = modules[":profile-feature"]
        assert profile["directory"] == "profile"
        assert profile["build_file"] == "profile/build.gradle.kts"
        assert profile["missing_build_file"] is False
        assert profile["project_dependencies"] == [":domain"]
        assert profile["source_sets"] == ["main"]

    print("Gradle inventory resolves literal projectDir remaps.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
