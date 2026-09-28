#!/usr/bin/env python3
"""Sync gui_template.html into the embedded HTML block of omamigrate.

Run after editing gui_template.html so the packaged single-file app carries
the current dashboard. Idempotent: if the template already matches, the file
is left byte-for-byte identical.
"""
import pathlib
import re
import sys

root = pathlib.Path(__file__).resolve().parent
src = (root / "omamigrate").read_text()
tpl = (root / "gui_template.html").read_text()

pat = re.compile(r'HTML = r""".*?\n"""', re.S)
m = pat.search(src)
if not m:
    sys.exit("could not find HTML block in omamigrate")

new_block = 'HTML = r"""\n' + tpl.rstrip("\n") + '\n"""'
# A function repl inserts the return value verbatim (no backslash handling).
new_src = pat.sub(lambda _m: new_block, src, count=1)

# If nothing changed, don't rewrite (keeps mtime stable).
if new_src == src:
    print("no change (already in sync)")
else:
    (root / "omamigrate").write_text(new_src)
    print("re-embedded", len(tpl), "template bytes into omamigrate")
