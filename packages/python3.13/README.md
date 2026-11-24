Source: python3.13
Applies-To: excalibur
Kind: bootstrap (profile active, tk patch planned); build-fix 0001 dropped
Status: profile active; 0001 dropped 2026-11-22 (builds with valgrind again)

# python3.13

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds python3.13 without Bluetooth sockets (pulls bluez and through it about 200 sources) and tkinter (pulls Tk and X).
This keeps large build-dependency chains out of the minimal bootstrap set (they were found with
`tools/builddeps`' chain report, `T2.why`).

**How:** built with the Debian build profile(s) `pkg.python3.13.nobluetooth` the package already defines; a patch removes `tk-dev`, `blt-dev` from `debian/control` and disables what needs them.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

## 0001: no valgrind (dropped 2026-11-22)

**Problem.** python3.13 build-depends on `valgrind-if-available`, which on amd64 is `valgrind`, and Debian's
`valgrind` depends on glibc's debug-symbols package `libc6-dbg`. libniji has no `libc6-dbg`, so in stage 1 the build
dependencies couldn't be installed (2026-11-16).

**Change.** `0001-no-valgrind.patch` removes `valgrind-if-available` from `debian/control` and `debian/control.in`.
`debian/rules` only passes `--with-valgrind` when valgrind is installed, so Python builds without its Valgrind
annotations (they only make Valgrind runs quieter; nothing else changes).

**Restored** 2026-11-22. libniji ships `libc6-dbg` (duskglow/libniji#13, closed on `snapshot-2026-11-21.7`), and
stage 1 build roots offer it from a local repository (tools/niji-swap.sh, step 2b), so `valgrind` installs as a
build dependency and the patch is gone.

## T2 trim (2026-11-24): the tkinter/IDLE tests that need an X server

**Bootstrap only (decisions 16 and 24).** Yohane builds python3.13 without the tkinter/IDLE tests that need an X server, because xvfb pulls in the X server and Mesa. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `xvfb`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps`.
