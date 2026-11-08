#!/usr/bin/env python3
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
"""Rewrite the <releases> block of an AppStream metainfo file from CHANGELOG.md.

    scripts/metainfo-releases.py CHANGELOG.md METAINFO.xml

release-please writes CHANGELOG.md and nothing writes the metainfo, so the
Flatpak build runs this on the tagged source and the release it builds is
always listed. Run it by hand (`just metainfo`) to refresh the committed copy.
Each release gets its version, date and its changelog bullets as a list.
"""

import html
import re
import sys

HEADING = re.compile(r"^## \[?(\d+\.\d+\.\d+)\]?(?:\([^)]*\))? \((\d{4}-\d{2}-\d{2})\)")
LINKS = [
    (re.compile(r" \(\[[0-9a-f]{7,40}\]\([^)]*\)\)"), ""),
    (re.compile(r" \(\[#\d+\]\([^)]*\)\)"), ""),
    (re.compile(r"\[([^\]]*)\]\([^)]*\)"), r"\1"),
    (re.compile(r"\*\*"), ""),
]


def releases(changelog):
    out, current = [], None
    for line in changelog.splitlines():
        m = HEADING.match(line)
        if m:
            current = {"version": m[1], "date": m[2], "items": []}
            out.append(current)
        elif current and line.startswith("* "):
            text = line[2:]
            for pattern, repl in LINKS:
                text = pattern.sub(repl, text)
            current["items"].append(text.strip())
    return out


def render(entries, indent="  "):
    lines = [f"{indent}<releases>"]
    for e in entries:
        lines.append(f'{indent * 2}<release version="{e["version"]}" date="{e["date"]}">')
        lines.append(f"{indent * 3}<url>https://github.com/heliopsy/tix-mobile/releases/tag/v{e['version']}</url>")
        if e["items"]:
            lines.append(f"{indent * 3}<description>")
            lines.append(f"{indent * 4}<ul>")
            lines += [f"{indent * 5}<li>{html.escape(i, quote=False)}</li>" for i in e["items"]]
            lines.append(f"{indent * 4}</ul>")
            lines.append(f"{indent * 3}</description>")
        lines.append(f"{indent * 2}</release>")
    lines.append(f"{indent}</releases>")
    return "\n".join(lines)


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)
    with open(sys.argv[1], encoding="utf-8") as f:
        entries = releases(f.read())
    if not entries:
        sys.exit("metainfo-releases: no releases in " + sys.argv[1])
    with open(sys.argv[2], encoding="utf-8") as f:
        xml = f.read()
    block = re.compile(r"^  <releases>.*?</releases>|^  <releases/>", re.S | re.M)
    if not block.search(xml):
        sys.exit("metainfo-releases: no <releases> block in " + sys.argv[2])
    xml = block.sub(lambda _: render(entries), xml, count=1)
    with open(sys.argv[2], "w", encoding="utf-8") as f:
        f.write(xml)
    print(f"{sys.argv[2]}: {len(entries)} releases, newest {entries[0]['version']}")


if __name__ == "__main__":
    main()
