#!/usr/bin/env bash
# SPDX-FileCopyrightText: tix-mobile contributors
# SPDX-License-Identifier: AGPL-3.0-or-later
#
# Run a pinned gate tool, or print the version it is pinned to.
#
#   scripts/tool.sh run NAME [ARGS...]
#   scripts/tool.sh version NAME
#
# Versions come from .tool-versions where asdf has a plugin for the tool, and
# from the table below otherwise. Nothing else in the repository names a
# version for these tools: the justfile calls this script and CI's tools
# action installs whatever `version` prints, so a laptop and a runner cannot
# end up running two different linters under one gate name.
#
# How a tool runs, in order:
#   1. the binary on PATH, if it reports exactly the pinned version;
#   2. for the npm tools, npx at the pinned version;
#   3. for the Python tools, uvx or pipx at the pinned version;
#   4. a container image at the pinned version, via CONTAINER_ENGINE (podman).
#
# A fallback is announced on stderr rather than taken silently: running a
# different tool than you think you are running is how a gate stops meaning
# anything. TOOL_MODE=path forbids every fallback and fails instead, which is
# what CI sets, because it installed the exact versions and anything else on
# PATH would be a bug in the tools action.

set -euo pipefail

# Tools without an asdf plugin worth depending on. Bump here, nowhere else.
declare -A PINNED=(
  [markdownlint]="0.50.0"   # npm: markdownlint-cli
  [openspec]="1.16.1"       # npm: @fission-ai/openspec
  [reuse]="6.3.0"           # PyPI: reuse
)

root=$(cd "$(dirname "$0")/.." && pwd)
engine="${CONTAINER_ENGINE:-podman}"
mode="${TOOL_MODE:-auto}"

die() { echo "tool.sh: $*" >&2; exit 1; }
note() { echo "tool.sh: $*" >&2; }

version_of() {
  local name=$1 v
  if [ -n "${PINNED[$name]:-}" ]; then
    printf '%s' "${PINNED[$name]}"
    return
  fi
  v=$(awk -v t="$name" '$1 == t { print $2 }' "$root/.tool-versions")
  [ -n "$v" ] || die "no version for $name in .tool-versions or scripts/tool.sh"
  printf '%s' "$v"
}

# What the installed binary says its version is, reduced to the bare number.
installed_version() {
  local name=$1 out
  command -v "$name" >/dev/null 2>&1 || return 1
  case "$name" in
    actionlint) out=$(actionlint -version 2>/dev/null | head -1) ;;
    shellcheck) out=$(shellcheck --version 2>/dev/null | sed -n 's/^version: //p') ;;
    yamllint)   out=$(yamllint --version 2>/dev/null) ;;
    gitleaks)   out=$(gitleaks version 2>/dev/null) ;;
    reuse)      out=$(reuse --version 2>/dev/null | head -1) ;;
    *)          return 1 ;;
  esac
  grep -oE '[0-9]+\.[0-9]+\.[0-9]+' <<<"$out" | head -1
}

# The repository is mounted at its own absolute path, and so is the git common
# directory. In a linked worktree .git is a file naming that directory by
# absolute path, and a container that cannot follow it sees no repository at
# all: gitleaks then scans zero commits and passes. safe.directory because a
# rootful engine runs git as a different uid than the owner of the bind mount.
container() {
  local image=$1; shift
  command -v "$engine" >/dev/null 2>&1 || die "$engine is not installed; set CONTAINER_ENGINE or install the tool"
  local common
  common=$(git -C "$root" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)
  local mounts=(-v "$root:$root:z")
  if [ -n "$common" ] && [[ "$common" != "$root"/* ]]; then
    mounts+=(-v "$common:$common:z")
  fi
  exec "$engine" run --rm "${mounts[@]}" -w "$PWD" \
    -e GIT_CONFIG_COUNT=1 -e GIT_CONFIG_KEY_0=safe.directory -e GIT_CONFIG_VALUE_0='*' \
    "$image" "$@"
}

run() {
  local name=$1; shift
  local want have
  want=$(version_of "$name")

  case "$name" in
    markdownlint|openspec)
      local pkg=markdownlint-cli bin=markdownlint
      [ "$name" = openspec ] && pkg=@fission-ai/openspec bin=openspec
      export OPENSPEC_TELEMETRY=0
      command -v npx >/dev/null 2>&1 || die "$name needs node (npx) on PATH"
      exec npx --yes --package "$pkg@$want" -- "$bin" "$@"
      ;;
  esac

  if have=$(installed_version "$name") && [ "$have" = "$want" ]; then
    exec "$name" "$@"
  fi

  local why="not on PATH"
  [ -n "${have:-}" ] && why="PATH has $have"
  if [ "$mode" = path ]; then
    die "$name $want is required and $why (TOOL_MODE=path allows no fallback)"
  fi

  case "$name" in
    yamllint|reuse)
      if command -v uvx >/dev/null 2>&1; then
        note "$name $want: $why, running through uvx"
        exec uvx --quiet --from "$name==$want" "$name" "$@"
      fi
      if command -v pipx >/dev/null 2>&1; then
        note "$name $want: $why, running through pipx"
        exec pipx run --spec "$name==$want" "$name" "$@"
      fi
      ;;
  esac

  note "$name $want: $why, running in a container through $engine"
  case "$name" in
    actionlint) container "docker.io/rhysd/actionlint:$want" "$@" ;;
    shellcheck) container "docker.io/koalaman/shellcheck:v$want" "$@" ;;
    gitleaks)   container "ghcr.io/gitleaks/gitleaks:v$want" "$@" ;;
    reuse)      container "docker.io/fsfe/reuse:$want" "$@" ;;
    yamllint)
      # shellcheck disable=SC2016 # expanded by the container's sh, not here
      container docker.io/library/python:3.13-alpine \
        sh -c 'pip install --quiet --disable-pip-version-check --root-user-action=ignore "yamllint==$0" && yamllint "$@"' \
        "$want" "$@" ;;
    *) die "unknown tool: $name" ;;
  esac
}

[ $# -ge 2 ] || die "usage: $0 run NAME [ARGS...] | $0 version NAME"
cmd=$1; shift
case "$cmd" in
  version) version_of "$1"; echo ;;
  run)     run "$@" ;;
  *)       die "unknown command: $cmd" ;;
esac
