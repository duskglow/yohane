Source: dbus
Applies-To: excalibur
Kind: bootstrap (0001); also a build-fix until libniji ships libc6-dbg
Status: 0001 active

# dbus

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds dbus without Valgrind instrumentation (pulls valgrind and LLVM 17).
This keeps large build-dependency chains out of the minimal bootstrap set (they were found with
`tools/builddeps`' chain report, `T2.why`).

## 0001: no valgrind

**Change.** `0001-no-valgrind.patch` removes `valgrind-if-available` from `debian/control` (`drop-build-deps` lists it
for `tools/builddeps`). `debian/rules` configures with `-Dvalgrind=auto`, so dbus builds without its Valgrind client
requests. They only help Valgrind runs; nothing else changes.

**Also needed on libniji.** On amd64 `valgrind-if-available` is `valgrind`, and Debian's `valgrind` depends on glibc's
debug-symbols package `libc6-dbg`. libniji has no `libc6-dbg` (duskglow/libniji#13), so in stage 1 the build
dependencies couldn't be installed (2026-11-17). python3.13's 0001 is the same change.

**Restored in the full pass,** once the system rebuilds itself and libniji ships a `libc6-dbg`; Snow Halation ships the
full-featured build.

## No drop-build-deps

0001-no-valgrind.patch already removes valgrind-if-available from debian/control, so a drop list naming it
(there was one until 2026-11-25) fails: trimcontrol refuses a name it cannot find.
