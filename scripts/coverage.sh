#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Coverage helpers that need nothing beyond awk, so neither a laptop nor a
# runner has to install lcov.
#
#   scripts/coverage.sh filter IN OUT   drop generated code from an lcov file
#   scripts/coverage.sh check FILE MIN  print the total and fail under MIN
#
# Generated code is excluded because counting it measures build_runner, not
# the tests: a freezed class adds hundreds of lines of copyWith and equality
# that nothing calls directly, and either inflates or sinks the number
# depending on the day.

set -euo pipefail

# Kept in step with codecov.yml's ignore list, so Codecov and the local floor
# agree about what counts.
generated='(\.g\.dart|\.freezed\.dart|\.gr\.dart|\.mocks\.dart|\.config\.dart)$|^lib/l10n/.*\.dart$|^lib/generated/'

filter() {
  local in=$1 out=$2
  [ -s "$in" ] || { echo "no coverage data at $in: run the tests with --coverage first" >&2; exit 1; }
  awk -v gen="$generated" '
    /^SF:/ { path = substr($0, 4); sub("^" ENVIRON["PWD"] "/", "", path); skip = (path ~ gen) }
    !skip { print }
    /^end_of_record/ { skip = 0 }
  ' "$in" > "$out"
}

check() {
  local file=$1 min=$2
  [ -s "$file" ] || { echo "no coverage data at $file" >&2; exit 1; }
  awk -v min="$min" '
    /^SF:/ { path = substr($0, 4); sub("^" ENVIRON["PWD"] "/", "", path); seen[path] = 1 }
    /^LF:/ { f = substr($0, 4); lf += f; flf[path] = f }
    /^LH:/ { h = substr($0, 4); lh += h; flh[path] = h }
    END {
      if (lf == 0) { print "coverage: no instrumented lines"; exit 1 }
      total = 100 * lh / lf
      printf "coverage: %.1f%% (%d of %d lines)\n", total, lh, lf
      print "lowest files:"
      for (p in flf) if (flf[p] > 0) printf "  %5.1f%%  %s\n", 100 * flh[p] / flf[p], p | "sort -n | head -5"
      close("sort -n | head -5")
      headroom = total - min
      printf "floor: %s%%, headroom: %.1f points\n", min, headroom
      if (total < min) { printf "FAIL: below the %s%% floor\n", min; exit 1 }
      if (headroom < 1.5) print "WARNING: under 1.5 points of headroom, add tests before it turns CI red"
    }
  ' "$file"

  # flutter test only instruments files some test imported, so a file no test
  # touches is missing from the report rather than counted at zero, and the
  # total looks better than it is. Name them, so the gap is visible.
  local untested
  untested=$(comm -23 \
    <(git ls-files -co --exclude-standard 'lib/*.dart' | grep -vE "$generated" | sort) \
    <(sed -n 's#^SF:##p' "$file" | sed "s#^$PWD/##" | sort))
  if [ -n "$untested" ]; then
    echo "not loaded by any test, so not in the total above:"
    while IFS= read -r f; do echo "  $f"; done <<<"$untested"
  fi
}

case "${1:-}" in
  filter) filter "$2" "$3" ;;
  check)  check "$2" "$3" ;;
  *) echo "usage: $0 filter IN OUT | check FILE MIN" >&2; exit 2 ;;
esac
