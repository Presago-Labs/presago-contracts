"""Exercise the actual CI command's boundary and failure behavior."""

from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from check_wasm_size import BUDGET_BYTES, DEFAULT_ARTIFACT

SCRIPT = Path(__file__).with_name("check_wasm_size.py").resolve()


class WasmSizeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.artifact = Path(self.temp.name) / "contract with spaces.wasm"

    def run_check(self):
        return subprocess.run(
            [sys.executable, str(SCRIPT), str(self.artifact)],
            capture_output=True, text=True, check=False,
        )

    def check_size(self, size, expected):
        with self.artifact.open("wb") as artifact:
            artifact.truncate(size)
        result = self.run_check()
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        self.assertIn(f"{size} bytes / {BUDGET_BYTES}", result.stdout)
        return result

    def test_below_budget(self):
        self.check_size(BUDGET_BYTES - 1, 0)

    def test_exact_budget(self):
        self.check_size(BUDGET_BYTES, 0)

    def test_one_byte_above_budget(self):
        result = self.check_size(BUDGET_BYTES + 1, 1)
        self.assertIn("exceeds budget by 1 bytes", result.stderr)

    def test_empty_artifact(self):
        self.assertIn("empty", self.check_size(0, 1).stderr)

    def test_missing_artifact(self):
        self.assertEqual(self.run_check().returncode, 1)

    def test_directory_is_not_an_artifact(self):
        self.artifact.mkdir()
        self.assertEqual(self.run_check().returncode, 1)

    def test_default_path_fails_when_build_output_is_missing(self):
        result = subprocess.run(
            [sys.executable, str(SCRIPT)], cwd=self.temp.name,
            capture_output=True, text=True, check=False,
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("prediction_market.wasm", result.stderr)

    def test_ci_command_accepts_default_artifact(self):
        artifact = Path(self.temp.name) / DEFAULT_ARTIFACT
        artifact.parent.mkdir(parents=True)
        # Synthetic bytes test path selection and size only, not Rust compilation.
        artifact.write_bytes(b"\x00asm\x01\x00\x00\x00")
        result = subprocess.run(
            [sys.executable, str(SCRIPT)], cwd=self.temp.name,
            capture_output=True, text=True, check=False,
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("8 bytes /", result.stdout)

    def test_ci_command_rejects_oversized_default_artifact(self):
        artifact = Path(self.temp.name) / DEFAULT_ARTIFACT
        artifact.parent.mkdir(parents=True)
        with artifact.open("wb") as output:
            output.truncate(BUDGET_BYTES + 1)
        result = subprocess.run(
            [sys.executable, str(SCRIPT)], cwd=self.temp.name,
            capture_output=True, text=True, check=False,
        )
        self.assertEqual(result.returncode, 1)
        self.assertIn("exceeds budget", result.stderr)


if __name__ == "__main__":
    unittest.main()
