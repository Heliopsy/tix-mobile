#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Print the App Store "What's New" for a version from CHANGELOG.md, which
# release-please writes. The promote workflow's App Store job fills it in on
# every locale that has none, because App Review refuses an update without it.
#
#   scripts/store-whatsnew.sh VERSION [SINCE]
#   scripts/store-whatsnew.sh --self-test
#
# VERSION's section alone, or with SINCE (the version live on the App Store)
# every section after SINCE up to VERSION, newest first. Only Features, Bug
# Fixes, Performance and Reverts are kept, as "- Text" lines without scopes,
# commit hashes or links, each once, cut on a whole line at 4000 bytes, Apple's
# limit in characters. CHANGELOG overrides the file read.

set -euo pipefail

limit=4000
root=$(cd "$(dirname "$0")/.." && pwd)

notes() {
  local version=${1#v} since=${2#v} changelog=$3 text
  [ -f "$changelog" ] || { echo "store-whatsnew: no $changelog" >&2; return 1; }
  text=$(awk -v want="$version" -v since="$since" '
    function cmp(a, b,   x, y, i) {
      split(a, x, "."); split(b, y, ".")
      for (i = 1; i <= 3; i++) {
        if (x[i] + 0 < y[i] + 0) return -1
        if (x[i] + 0 > y[i] + 0) return 1
      }
      return 0
    }
    /^## / {
      v = ""
      if (match($0, /[0-9]+\.[0-9]+\.[0-9]+/)) v = substr($0, RSTART, RLENGTH)
      if (v == want) found = 1
      keep = v != "" && (v == want || (since != "" && cmp(v, since) > 0 && cmp(v, want) < 0))
      section = ""
      next
    }
    /^### / { section = substr($0, 5); next }
    keep && /^\* / && section ~ /^(Features|Bug Fixes|Performance|Reverts)$/ { print }
    END { if (!found) exit 3 }' "$changelog") || {
    echo "store-whatsnew: no CHANGELOG section for $version in $changelog" >&2
    return 1
  }

  # "* **scope:** text ([abc1234](url))" -> "- Text"
  text=$(sed -E \
    -e 's/ \(\[[0-9a-f]{7,40}\]\([^)]*\)\)//g' \
    -e 's/ \(\[#[0-9]+\]\([^)]*\)\)//g' \
    -e 's/ \(#[0-9]+\)//g' \
    -e 's/\[([^]]*)\]\([^)]*\)/\1/g' \
    -e 's/^\* \*\*[^*]*:\*\* /* /' \
    -e 's/\*\*//g' \
    -e 's/^\* +//' <<<"$text" |
    awk 'NF { $0 = "- " toupper(substr($0, 1, 1)) substr($0, 2) } NF && !seen[$0]++')
  [ -n "$text" ] || text="- Maintenance release."

  local out="" line
  while IFS= read -r line; do
    if [ "$(printf '%s%s\n' "$out" "$line" | wc -c)" -gt "$limit" ]; then break; fi
    out+="$line"$'\n'
  done <<<"$text"
  [ -n "$out" ] || out="${text:0:$((limit - 1))}"$'\n'
  printf '%s' "$out"
}

self_test() {
  local fails=0 got
  dir=$(mktemp -d)
  trap 'rm -rf "$dir"' EXIT
  cat > "$dir/CHANGELOG.md" <<'EOF'
# Changelog

## [0.3.0](https://github.com/Heliopsy/tix-mobile/compare/v0.2.1...v0.3.0) (2026-11-16)


### Features

* **tasks:** drag saved filters into order ([7cddf99](https://github.com/Heliopsy/tix-mobile/commit/7cddf99ff9b40aa626f00413ec8470c2e3c8b665))
* show **bold** [docs](https://tix.red) links ([#12](https://github.com/Heliopsy/tix-mobile/issues/12)) ([ee8b20c](https://github.com/Heliopsy/tix-mobile/commit/ee8b20c))


### Dependencies

* pin tix at v0.61.0 ([42d5379](https://github.com/Heliopsy/tix-mobile/commit/42d5379))

## [0.2.1](https://github.com/Heliopsy/tix-mobile/compare/v0.2.0...v0.2.1) (2026-11-15)


### Bug Fixes

* **ios:** start the widget engine first ([570d166](https://github.com/Heliopsy/tix-mobile/commit/570d166))
* **tasks:** drag saved filters into order ([1234567](https://github.com/Heliopsy/tix-mobile/commit/1234567))

## [0.2.0](https://github.com/Heliopsy/tix-mobile/compare/v0.1.0...v0.2.0) (2026-11-14)


### Dependencies

* pin tix at v0.60.0 ([42d5370](https://github.com/Heliopsy/tix-mobile/commit/42d5370))

## 0.1.0 (2026-11-01)


### Performance

* open the inbox faster ([abcdef0](https://github.com/Heliopsy/tix-mobile/commit/abcdef0))
EOF

  check() {
    local name=$1 want=$2
    shift 2
    if got=$(notes "$@" 2>/dev/null) && [ "$got" = "$want" ]; then
      echo "ok   $name"
    else
      echo "FAIL $name"
      printf '  want: %q\n  got:  %q\n' "$want" "${got:-}"
      fails=$((fails + 1))
    fi
  }

  check "one version, scopes, hashes and links dropped" \
    $'- Drag saved filters into order\n- Show bold docs links' 0.3.0 "" "$dir/CHANGELOG.md"
  check "v prefix accepted" \
    $'- Start the widget engine first\n- Drag saved filters into order' v0.2.1 "" "$dir/CHANGELOG.md"
  check "since the live version, newest first, each line once" \
    $'- Drag saved filters into order\n- Show bold docs links\n- Start the widget engine first' 0.3.0 0.2.0 "$dir/CHANGELOG.md"
  check "since an older version, skipping sections with nothing user-facing" \
    $'- Drag saved filters into order\n- Show bold docs links\n- Start the widget engine first\n- Open the inbox faster' \
    0.3.0 0.0.9 "$dir/CHANGELOG.md"
  check "no user-facing change" "- Maintenance release." 0.2.0 "" "$dir/CHANGELOG.md"
  check "heading without a link" "- Open the inbox faster" 0.1.0 "" "$dir/CHANGELOG.md"

  if notes 9.9.9 "" "$dir/CHANGELOG.md" >/dev/null 2>&1; then
    echo "FAIL a version without a section is an error"
    fails=$((fails + 1))
  else
    echo "ok   a version without a section is an error"
  fi

  {
    echo "## [1.0.0](https://example.com) (2026-11-16)"
    echo "### Features"
    for i in $(seq 1 200); do echo "* **ui:** change number $i that is long enough to add up quickly"; done
  } > "$dir/LONG.md"
  got=$(notes 1.0.0 "" "$dir/LONG.md")
  if [ "$(printf '%s\n' "$got" | wc -c)" -le "$limit" ] && [[ $got == *"quickly" ]] && [[ $got != *"number 200 "* ]]; then
    echo "ok   cut at $limit bytes on a whole line"
  else
    echo "FAIL cut at $limit bytes on a whole line ($(printf '%s\n' "$got" | wc -c) bytes)"
    fails=$((fails + 1))
  fi

  [ "$fails" -eq 0 ] || { echo "store-whatsnew: $fails failed" >&2; return 1; }
}

if [ "${1:-}" = "--self-test" ]; then
  self_test
  exit
fi
version=${1:?usage: $0 VERSION [SINCE] | --self-test}
notes "$version" "${2:-}" "${CHANGELOG:-$root/CHANGELOG.md}"
