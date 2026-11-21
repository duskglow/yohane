#!/bin/sh
# Boot check: libniji's coexistence flavour (niji6) beside glibc.
# Runs Devuan's own programs under libniji's loader and compares output and exit
# status with the same programs on glibc. Prints one YOHANE-CHECK line per item.
#
# By design the coexistence loader searches only libniji's own library directory
# (docs/install-packages.md in duskglow/libniji): a program that needs a system
# library must name its directory. These are distribution programs built for
# glibc, so the system directory is given *after* libniji's own; libniji's
# libc.so.6 is then found first and the other libraries come from the system.
L=/usr/lib/niji/usr/lib64/ld-linux-x86-64.so.2
LDIR=/usr/lib/niji/usr/lib/x86_64-linux-gnu
SYSDIR=/usr/lib/x86_64-linux-gnu
n=0; bad=0
check() {   # check NAME COMMAND...: same stdout and status under glibc and libniji
  name=$1; shift
  ref=$("$@" 2>/dev/null); rs=$?
  got=$(LD_LIBRARY_PATH="$LDIR:$SYSDIR" "$L" "$@" 2>/tmp/aq-err); gs=$?
  n=$((n + 1))
  if [ "$ref" = "$got" ] && [ "$rs" = "$gs" ]; then echo "YOHANE-CHECK: niji6 $name OK"
  else bad=$((bad + 1)); echo "YOHANE-CHECK: niji6 $name FAIL (status glibc=$rs niji=$gs; $(head -c 160 /tmp/aq-err | tr '\n' ' '))"; fi
}
if [ ! -x "$L" ]; then echo "YOHANE-CHECK: niji6 loader FAIL (missing $L)"; exit 1; fi
# libniji's libc comes from libniji's directory even though the system directory is on the path.
list=$(LD_LIBRARY_PATH="$LDIR:$SYSDIR" "$L" --list /bin/ls 2>&1)
libc=$(echo "$list" | grep 'libc.so.6' | head -1)
case "$libc" in *"/usr/lib/niji/"*) echo "YOHANE-CHECK: niji6 resolves-own-libc OK";;
  *) echo "YOHANE-CHECK: niji6 resolves-own-libc FAIL ($(echo "$list" | head -c 200 | tr '\n' ' '))"; bad=$((bad + 1));; esac
sel=$(echo "$list" | grep 'libselinux' | head -1)
case "$sel" in *"$SYSDIR/"*) echo "YOHANE-CHECK: niji6 system-libs-from-system OK";;
  *) echo "YOHANE-CHECK: niji6 system-libs-from-system FAIL ($sel)"; bad=$((bad + 1));; esac
printf 'pear\napple\nfig\napple\n' > /tmp/aq-in
check ls        /bin/ls -la /etc/init.d
check sort      /usr/bin/sort /tmp/aq-in
check uniq      /usr/bin/sort -u /tmp/aq-in
check grep      /bin/grep -n app /tmp/aq-in
check sed       /bin/sed 's/p/P/g' /tmp/aq-in
check awk       /usr/bin/awk '{ n[$1]++ } END { for (k in n) s += n[k]; print s }' /tmp/aq-in
check bash      /bin/bash -c 'for i in 1 2 3; do echo $((i * i)); done'
check cat       /bin/cat /etc/os-release
check id        /usr/bin/id -u
check date      /bin/date -u -d @0 +%Y-%m-%dT%H:%M:%S
check false     /bin/false
rm -f /tmp/aq-in /tmp/aq-err
echo "YOHANE-CHECK: niji6 summary $((n + 2 - bad))/$((n + 2)) passed"
[ "$bad" -eq 0 ]
