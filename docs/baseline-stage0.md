# Stage 0 baseline: T1 rebuilt with glibc

Status: **complete.** Run of 2026-11-15 (gcc-14 finished 23:05 UTC, after a rebuild with a longer time limit).

Stage 0 rebuilds every source package of tier T1 (a base Devuan excalibur system, 173 source packages) with
**glibc**, on the same infrastructure later stages use. Every later stage is compared against it: a package that
builds and passes its tests here but fails with libniji points at libniji; one that fails here doesn't.

## How it was built

- **Environment:** decision 11, "build like Debian, ship like Devuan": Debian trixie with Devuan excalibur layered over
  it (Devuan pinned higher), dpkg vendor Debian. See [design.md](design.md), section 1 and decision 11.
- **What:** the architecture-dependent binaries of each source (`--arch-any`; `Architecture: all` is imported, per
  decision 1), with the packages' own build-time tests on, and no debug symbol packages.
- **Tools:** `tools/buildone` (sbuild, unshare mode, unprivileged), dispatched by `tools/driver` over two build hosts.

## Results

| | Count |
|---|---|
| Built and passed their own tests | **172** (gcc-14 included; see below) |
| Failed | **1** (elfutils, fixed by a Yohane patch) |

**The one failure, elfutils 0.192-4:** packaging aborts because `/etc/debuginfod/elfutils.urls` is missing. The
packaging only creates that file when a default debuginfod server URL is configured. The URL is derived from the OS
identity in base-files, which here is Devuan's, so it comes out empty; on Debian it would be Debian's debuginfod
server. All 283 of its tests passed. **Fixed** by the Yohane `build-fix` patch in `packages/elfutils/`, verified: with
it, elfutils builds and passes its tests (stage `stage0p`).

**gcc-14 14.2.0-19: built** in 8 h 14 min (sbuild `Package-Time`), with 16 parallel jobs. The first attempt was
stopped by the general 8-hour backstop, which isn't a package result; the rebuild had a 24-hour backstop for gcc.
Most of the time isn't the native compiler. Debian's package also builds the JIT library, an hppa64 cross compiler and
the NVIDIA and AMD GPU offload compilers, then runs the test suite in three configurations (default,
`-fstack-protector`, `-m32`).

Like Debian's, gcc's packaging records test failures without failing the build. This run had 215 distinct failing
tests, a small fraction of the suite. That's the glibc reference that stage 1 is compared against, test by test:
- 102 are the `-fhardened` tests under C++ options (`c-c++-common/fhardened-*`), probably conflicting with the hardening
  flags Debian's gcc enables by default (not yet investigated);
- 35 are ThreadSanitizer (`tsan`), and 42 are OpenMP runtime (`libgomp`), both timing-sensitive kinds of test (cause not yet
  investigated);
- the rest are scattered: 22 in `gcc.dg`, 3 in `gcc.target/i386`, and about ten in Go and its runtime.

Note for later: the `-m32` configuration tests 32-bit code generation, which Yohane doesn't ship (no multilib, design
section 1), and decision 16 already drops the GPU offload compilers for the bootstrap. Those two are
the main levers on gcc's build time (not yet measured).

## Build times

From sbuild's own accounting (`Build-Time`), for all 173 builds: **about 22.6 build-hours** in total, over a third of
it gcc-14.

| Build time | Packages |
|---|---|
| under 2 minutes | 113 |
| 2–10 minutes | 44 |
| 10–30 minutes | 9 |
| 30–60 minutes | 2 |
| over 1 hour | 4 (gcc-14 494 min, python3.13 175 min, binutils 152 min, glibc 64 min) |

Wall time is set by the few long test suites, not by the number of packages. That's the main input for planning the
larger tiers.

## The first attempt, in a Devuan-only environment

A first run built the same list in a pure Devuan excalibur environment. It is kept for comparison (stage
`stage0-devuanenv`). Its failures, and what happened to them:

| Package | Devuan-only environment | Build-like-Debian environment |
|---|---|---|
| e2fsprogs | build dependency `systemd` not installable | built |
| dhcpcd | build dependency `systemd-timesyncd` not installable | built |
| grub2 | rules ask for a Xen package missing from the package list | built |
| elfutils | missing `elfutils.urls` | still fails (above) |

Devuan publishes Debian's own binaries for about 99.7% of its packages, built by Debian in a Debian environment, so
Devuan itself never meets these. That's the reason for decision 11.

## Build-host problems found along the way

None of these were package or libniji problems; each was diagnosed before anything was rerun, and each is fixed in
`tools/buildone`:

1. **Job time cap.** The host job queue caps shared jobs at 150 minutes by default, which cut off binutils and gcc-14.
   Builds now lift the cap above their own 8-hour backstop (24 hours for gcc).
2. **Core pinning.** The queue pinned each job to a block of cores; libuv's `thread_affinity` test requires CPU 0 in
   the affinity mask. Builds now run unpinned (the queue still counts cores).
3. **Revoked session keyring.** Builds are started detached from a short SSH command and inherited that login's session
   keyring, which PAM (`pam_keyinit force revoke`) revokes at logout. krb5's `t_cccol.py` needs a live session keyring.
   Each build now runs in a fresh anonymous session keyring.

The lesson recorded for later stages: **when a test fails in only one environment, suspect the build host first.**

## What follows

- **Patch mechanism:** done. Stage `stage0p` applies `packages/<source>/patches/` to the verified Devuan source
  (`tools/getsource`), versions it `<version>yohane<N>` and builds it; the elfutils patch is the first.
- **Tier T2** (the build dependencies of T0–T1, resolved in the build environment): being computed (`tools/builddeps`).
- **Stage 1** starts with libniji's next snapshot tag. libniji's side of stage 1 was complete on 2026-11-15, and the
  snapshot is in its final validation. It ships a coexistence flavour (`niji6`, `niji6-dev`) for building against
  libniji on a glibc host.
