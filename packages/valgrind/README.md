Source: valgrind
Applies-To: excalibur
Kind: bootstrap
Status: active

# valgrind

## T2 trim (2026-11-24): the MPI wrapper library

**Bootstrap only (decisions 16 and 24).** Yohane builds valgrind without the MPI wrapper library, because it pulls in an MPI implementation. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `mpi-default-dev`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps`.

## valgrind without its 32-bit (x86) tools (2026-11-24)

**Problem.** Its T2 build failed at install-deps (or would have): `gcc-multilib` and `libc6-dev-i386` need glibc's 32-bit C library, which Yohane doesn't have (decision 21). valgrind's configure finds no `-m32` support and builds the amd64 tools only; the 32-bit x86 tools are not built. Nothing in Yohane runs 32-bit x86 programs.

**Change.** `drop-build-deps` lists `gcc-multilib`, `libc6-dev-i386` (applied by `tools/trimcontrol`); no patch needed.
