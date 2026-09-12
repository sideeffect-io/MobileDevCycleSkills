"""Focused tests for Swift import inventory parsing."""

from __future__ import annotations

import importlib.util
import sys
import unittest
from pathlib import Path

SCRIPT = Path(__file__).with_name("inventory_swiftpm.py")
sys.dont_write_bytecode = True
SPEC = importlib.util.spec_from_file_location("inventory_swiftpm", SCRIPT)
if SPEC is None or SPEC.loader is None:
    raise RuntimeError(f"Unable to load {SCRIPT}")
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class ImportPatternTests(unittest.TestCase):
    def test_recognizes_swift_six_import_forms(self) -> None:
        source = """
        import Foundation
        @testable import ProfileFeature
        @_spi(Testing) public import StateMachineCore
        package import DomainModel
        import struct SwiftUI.Color
        """

        self.assertEqual(
            MODULE.IMPORT_PATTERN.findall(source),
            [
                "Foundation",
                "ProfileFeature",
                "StateMachineCore",
                "DomainModel",
                "SwiftUI",
            ],
        )


if __name__ == "__main__":
    unittest.main()
