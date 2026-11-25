#!/bin/sh
# yohane-only-gate.sh REPO-URL: run inside a stage 2+ build root (tools/mkchroot --yohane-only).
# Fails if any installed package's installed version is not available from REPO-URL, i.e. if any
# binary came from somewhere other than Yohane's own archive (design section 4, "no host tools").
# Prints the libc and toolchain versions it found.
set -eu
repo=$1
bad=0
for p in $(dpkg-query -W -f '${Package}\n'); do
  v=$(dpkg-query -W -f '${Version}' "$p")
  # The policy table: the installed version's line is marked "***"; its sources follow, indented further.
  if ! apt-cache policy "$p" | awk -v v="$v" -v repo="$repo" '
      /^ \*\*\* / || /^     [^ ]/ { inv = ($2 == v); next }
      inv && index($0, repo) { ok = 1 }
      END { exit ok ? 0 : 1 }'; then
    echo "yohane-only-gate: $p $v is not from $repo" >&2
    bad=1
  fi
done
[ $bad -eq 0 ] || exit 1
echo "yohane-only-gate: all $(dpkg-query -W -f '${Package}\n' | wc -l) installed packages come from $repo" >&2
dpkg-query -W -f 'installed: ${Package} ${Version}\n' libc6 libc6-dev gcc-14 binutils dpkg-dev >&2
