#!/usr/bin/env bash
# SPDX-License-Identifier: CC-BY-4.0
# Copyright (c) 2026 Bill Athing
#
# Rebuilds the STLs in stl/ and hinged-stls/ from the OpenSCAD sources, as listed in stl_parts.txt.
# Needs an OpenSCAD development snapshot ("nightly", 2024 or later) for the fast Manifold backend --
# the 2021.01 stable release doesn't have it and would take hours, if it finished at all.
#
#   ./build_stls.sh                    build everything
#   ./build_stls.sh hinged-stls        build only one output folder
#   ./build_stls.sh main_top_left ...  build only these output file names (in every folder that has them)
#
# Environment: OPENSCAD=/path/to/openscad picks the binary; JOBS=n sets how many parts render at once
# (default: the number of CPUs).
set -euo pipefail

cd "$(dirname "$0")"

find_openscad() {
    if [ -n "${OPENSCAD:-}" ]; then echo "$OPENSCAD"; return; fi
    for c in openscad-nightly openscad; do
        if command -v "$c" >/dev/null 2>&1; then command -v "$c"; return; fi
    done
    for c in /Applications/OpenSCAD.app/Contents/MacOS/OpenSCAD \
             "/c/Program Files/OpenSCAD (Nightly)/openscad.com" \
             "/c/Program Files/OpenSCAD/openscad.com"; do
        if [ -x "$c" ]; then echo "$c"; return; fi
    done
    echo "error: OpenSCAD not found -- install a nightly build or set OPENSCAD=/path/to/openscad" >&2
    exit 1
}
OPENSCAD=$(find_openscad)
if ! "$OPENSCAD" --help 2>&1 | grep -q -- '--backend'; then
    echo "error: $OPENSCAD has no Manifold backend -- this needs an OpenSCAD nightly / development snapshot" >&2
    exit 1
fi
export OPENSCAD
echo "Using $("$OPENSCAD" --version 2>&1) ($OPENSCAD)"

# One part: render to a temp file, then move it into place, so a failed render never leaves a broken STL behind.
build_one() {
    local dir=$1 name=$2 scad=$3 part=$4; shift 4
    local args=(-D "part=\"$part\"")
    for d in "$@"; do args+=(-D "$d"); done
    mkdir -p "$dir"
    local tmp="$dir/.$name.tmp.stl" log
    if log=$("$OPENSCAD" --backend=manifold "${args[@]}" -o "$tmp" "$scad" 2>&1); then
        mv -f "$tmp" "$dir/$name.stl"
        echo "  ok    $dir/$name.stl"
    else
        rm -f "$tmp"
        echo "  FAIL  $dir/$name.stl"
        echo "$log" | sed 's/^/        /'
        return 1
    fi
}
export -f build_one

jobs=${JOBS:-$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)}

# Pick the lines to build: drop comments/blank lines, then keep those whose folder or file name was asked for.
grep -v -e '^[[:space:]]*#' -e '^[[:space:]]*$' stl_parts.txt |
awk -v want="$*" 'BEGIN { n = split(want, w, " "); for (i = 1; i <= n; i++) keep[w[i]] = 1 }
                  n == 0 || ($1 in keep) || ($2 in keep)' > .stl_build_list.tmp
trap 'rm -f .stl_build_list.tmp' EXIT

count=$(wc -l < .stl_build_list.tmp)
if [ "$count" -eq 0 ]; then
    echo "error: nothing in stl_parts.txt matches: $*" >&2
    exit 1
fi
echo "Building $count STL(s), $jobs at a time..."

# xargs exits non-zero if any part failed
if xargs -P "$jobs" -L 1 bash -c 'build_one "$@"' _ < .stl_build_list.tmp; then
    echo "Done."
else
    echo "Some parts FAILED -- see above." >&2
    exit 1
fi
