#!/usr/bin/env python3

import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "make_package"


class MakePackageTests(unittest.TestCase):
    def test_archive_layout_exclusions_and_checksums(self):
        with tempfile.TemporaryDirectory() as directory:
            package_dir = Path(directory)
            control_text = (
                '{\n'
                '  "Package": "Fixture",\n'
                '  "Version": "1.2.3",\n'
                '  "Description": "Package fixture"\n'
                '}\n'
            )
            (package_dir / "control.json").write_text(control_text, encoding="utf-8")

            source_dir = package_dir / "files" / "haskell"
            source_dir.mkdir(parents=True)
            (source_dir / "Fixture.hs").write_text("module Fixture where\n", encoding="utf-8")
            (package_dir / "files" / "notes.txt").write_text("included\n", encoding="utf-8")
            (package_dir / "files" / "notes.txt~").write_text("backup\n", encoding="utf-8")
            flymake_dir = package_dir / "files" / "flymake-cache"
            flymake_dir.mkdir()
            (flymake_dir / "generated.hs").write_text("ignored\n", encoding="utf-8")

            result = subprocess.run(
                [sys.executable, str(SCRIPT)],
                cwd=package_dir,
                capture_output=True,
                check=False,
                text=True,
            )
            self.assertEqual(result.returncode, 0, result.stderr)

            archive_filename = package_dir / "Fixture_1.2.3.tar.gz"
            with tarfile.open(archive_filename, "r:gz") as archive:
                self.assertEqual(
                    archive.getnames(),
                    ["control.json", "files/haskell/Fixture.hs", "files/notes.txt"],
                )
                self.assertEqual(archive.extractfile("control.json").read().decode(), control_text)
                self.assertEqual(
                    archive.extractfile("files/haskell/Fixture.hs").read().decode(),
                    "module Fixture where\n",
                )

            archive_data = archive_filename.read_bytes()
            metadata = json.loads(result.stdout)
            self.assertEqual(metadata["Package"], "Fixture")
            self.assertEqual(metadata["Version"], "1.2.3")
            self.assertEqual(metadata["SHA1"], hashlib.sha1(archive_data).hexdigest())
            self.assertEqual(metadata["SHA256"], hashlib.sha256(archive_data).hexdigest())
            self.assertEqual(metadata["MD5sum"], hashlib.md5(archive_data).hexdigest())


if __name__ == "__main__":
    unittest.main()
