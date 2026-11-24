#!/bin/sh
# niji-swap.sh: run INSIDE a build chroot (as root) to swap libniji's system
# flavour in for glibc (design decision 12, stage 1). Used by tools/mkchroot
# --niji-swap. Arguments: NIJI_VERSION YOHANE_REPO_URL [SUITE] (SUITE defaults to "niji".
# libniji was called Liella before snapshot-2026-11-17, and its archive suite "liella")
#
#  1. yohane-glibc-headers: a throwaway package of excalibur libc6-dev's headers
#     minus what linux-libc-dev ships (libniji has no headers yet; decision 10:
#     never shipped). It is built here from the verified excalibur packages.
#  2. libniji's libc6, libc-bin, libc-dev-bin and libc6-dev at NIJI_VERSION, from the Yohane
#     SUITE suite ("niji"), installed over glibc's (a downgrade, so --force-depends).
#  2b. libniji's libc6-dbg at NIJI_VERSION is offered, not installed, from a local repository in
#     the chroot, so a build that needs it (Debian's valgrind depends on libc6-dbg) gets
#     libniji's and never glibc's.
#  3. apt is pinned to keep exactly these versions (libc6-dbg included).
#  4. Installed packages that declare libc6 (>= 2.40) or (>= 2.41) keep that
#     dependency, unless every GLIBC_2.40/GLIBC_2.41 symbol their ELF files
#     need is defined by libniji's libc.so.6; only then is the recorded version
#     relaxed to libniji's. libniji's label stays 2.39 while it implements some
#     2.41 symbols, so this states the truth for those packages and nothing
#     else. Every decision is logged to /var/log/yohane-niji-swap.log.
set -eu
LV=${1:?usage: niji-swap.sh NIJI_VERSION YOHANE_REPO_URL}
REPO=${2:?}
SUITE=${3:-niji}
LOG=/var/log/yohane-niji-swap.log
export DEBIAN_FRONTEND=noninteractive LC_ALL=C.UTF-8
log() { echo "$*" | tee -a "$LOG"; }
: > "$LOG"
W=$(mktemp -d); cd "$W"

echo "deb $REPO $SUITE main" > /etc/apt/sources.list.d/yohane-niji.list
apt-get update -qq

# 1. headers package (glibc's libc6-dev is downloaded into its own directory,
#    so it can never be confused with libniji's libc6-dev below)
mkdir -p hd/x hd/l hd/pkg/DEBIAN hd/src swap
(cd hd/src && apt-get download -qq libc6-dev linux-libc-dev)
gv=$(dpkg-deb -f hd/src/libc6-dev_*.deb Version)
dpkg-deb -x hd/src/libc6-dev_*.deb hd/x; dpkg-deb -x hd/src/linux-libc-dev_*.deb hd/l
(cd hd/x && find usr/include -type f -o -type l) | sort > hd/glibc.list
(cd hd/l && find usr/include -type f -o -type l) | sort > hd/linux.list
comm -23 hd/glibc.list hd/linux.list > hd/keep.list
(cd hd/x && tar -cf - -T ../keep.list) | (cd hd/pkg && tar -xf -)
cat > hd/pkg/DEBIAN/control <<C
Package: yohane-glibc-headers
Version: ${gv}+yohane.stage1
Architecture: amd64
Maintainer: Yohane Linux Maintainers <aqours@koiren.ai>
Depends: linux-libc-dev
Section: libdevel
Priority: optional
Description: glibc ${gv} C headers for Yohane stage 1 (throwaway)
 The C library headers from Devuan excalibur's libc6-dev, minus what
 linux-libc-dev ships, for compiling against libniji before libniji has headers
 of its own. Stage 1 only (Yohane decision 10); never shipped.
C
dpkg-deb -Zxz -b hd/pkg yohane-glibc-headers.deb >/dev/null
log "headers: yohane-glibc-headers ${gv}+yohane.stage1, $(wc -l < hd/keep.list) files"

# 2. swap: libniji's three packages, each named exactly, then verified
(cd swap && apt-get download -qq "libc6=$LV" "libc-bin=$LV" "libc-dev-bin=$LV" "libc6-dev=$LV")
dpkg -i --force-depends --force-overwrite yohane-glibc-headers.deb \
  "swap/libc6_${LV}_amd64.deb" "swap/libc-bin_${LV}_amd64.deb" "swap/libc-dev-bin_${LV}_amd64.deb" "swap/libc6-dev_${LV}_amd64.deb" >/dev/null 2>dpkg.err \
  || { cat dpkg.err; exit 1; }
for pv in "libc6 $LV" "libc-bin $LV" "libc-dev-bin $LV" "libc6-dev $LV" "yohane-glibc-headers ${gv}+yohane.stage1"; do
  set -- $pv
  got=$(dpkg-query -W -f='${Version}' "$1" 2>/dev/null || echo none)
  [ "$got" = "$2" ] || { log "SWAP FAILED: $1 is $got, expected $2"; cat dpkg.err; exit 1; }
  log "installed: $1 $got"
done

# 2b. libniji's optional packages, offered through a local repository and installed only by builds that need them:
#     libc6-dbg (valgrind), locales and libc-l10n (bash and others Build-Depend on locales). The "niji" source is
#     removed below, so without this a build would get Devuan's locales, which needs glibc's libc-bin.
OPT="libc6-dbg locales libc-l10n"
DBG=/var/lib/yohane-niji-dbg
mkdir -p "$DBG"
(cd "$DBG" && for p in $OPT; do apt-get download -qq "$p=$LV" || exit 1; done && dpkg-scanpackages -m . 2>/dev/null > Packages) \
  || { log "SWAP FAILED: could not download $OPT at $LV"; exit 1; }
for p in $OPT; do
  grep -qx "Package: $p" "$DBG/Packages" || { log "SWAP FAILED: no $p $LV"; exit 1; }
done
echo "deb [trusted=yes] file:$DBG ./" > /etc/apt/sources.list.d/yohane-niji-dbg.list
log "offered: $OPT at $LV (local repository $DBG)"

# 3. pin
cat > /etc/apt/preferences.d/yohane-niji-swap <<P
Package: libc6 libc-bin libc-dev-bin libc6-dev libc6-dbg locales libc-l10n
Pin: version $LV
Pin-Priority: 1001

Package: yohane-glibc-headers
Pin: version ${gv}+yohane.stage1
Pin-Priority: 1001
P

# 4. dependencies on libc6 >= 2.40/2.41: relax only where libniji defines every needed symbol
LIBC=$(readlink -f /lib/x86_64-linux-gnu/libc.so.6)
readelf --dyn-syms -W "$LIBC" | awk '$7 != "UND" && $8 ~ /@GLIBC_2\.4[01]$/ { sub(/@@?/, "@", $8); print $8 }' | sort -u > niji241.defs
log "libniji libc.so.6 defines $(wc -l < niji241.defs) GLIBC_2.40/2.41 symbols"
need_relax=""
for p in $(dpkg-query -W -f='${Package}\t${Depends} ${Pre-Depends}\n' | awk -F'\t' '$2 ~ /libc6 \(>= 2\.4[01]/ {print $1}'); do
  missing=""
  for f in $(dpkg -L "$p" 2>/dev/null); do
    [ -f "$f" ] && [ ! -L "$f" ] || continue
    head -c 4 "$f" 2>/dev/null | grep -q 'ELF' || continue
    readelf --dyn-syms -W "$f" 2>/dev/null | awk '$7 == "UND" && $8 ~ /@GLIBC_2\.4[01]/ { sub(/ \(.*/, "", $8); print $8 }'
  done | sort -u > need.$p
  missing=$(comm -23 need.$p niji241.defs | tr '\n' ' ')
  if [ -z "$missing" ]; then
    need_relax="$need_relax $p"
    log "relax: $p (needs $(wc -l < need.$p) GLIBC_2.40/2.41 symbols, all defined by libniji)"
  else
    log "KEEP-BROKEN: $p needs symbols libniji lacks: $missing"
  fi
done
if [ -n "$need_relax" ]; then
  cp /var/lib/dpkg/status /var/lib/dpkg/status.yohane-pre-relax
  awk -v pk=" $need_relax " -v lv="$LV" '
    /^Package: / { cur = $2 }
    /^(Depends|Pre-Depends): / && index(pk, " " cur " ") { gsub(/libc6 \(>= 2\.4[01][^)]*\)/, "libc6 (>= " lv ")") }
    { print }' /var/lib/dpkg/status.yohane-pre-relax > /var/lib/dpkg/status
fi
# apt runs on libniji now (#4), so a broken dependency state is fatal: every build would fail at install time.
apt-get check >apt.err 2>&1 && log "apt-get check: OK" || {
  log "apt-get check: FAILED"; cat apt.err >> /var/log/yohane-niji-swap.log; cat apt.err >&2; exit 1; }
rm -f /etc/apt/sources.list.d/yohane-niji.list
apt-get update -qq || true
# The optional packages must resolve to libniji's, not Devuan's higher-versioned ones.
for p in $OPT; do
  cand=$(apt-cache policy "$p" | awk '/Candidate:/ {print $2}')
  [ "$cand" = "$LV" ] && log "$p candidate: $cand" || { log "SWAP FAILED: $p candidate is $cand, expected $LV"; exit 1; }
done
cd /; rm -rf "$W"
