Source: elfutils
Applies-To: 0.192-4
Kind: build-fix (both patches)
Status: active

# elfutils

**Problem.** `debian/rules` chooses a default debuginfod server from `lsb_release -is`: Debian's for Debian, Ubuntu's
for Ubuntu, none otherwise. It only creates `/etc/debuginfod/elfutils.urls` when a server is chosen, but
`libdebuginfod-common.install` always lists the file, so on any other distribution `dh_install` aborts with "missing
files". Devuan never hits this because it ships Debian's binary (built on Debian, with Debian's server). Found in the
stage 0 baseline (docs/baseline-stage0.md).

**Change.** `0001-ship-urls-file-without-default-server.patch` always creates the file. It holds the URL when one is
configured and is empty otherwise; an empty file means no default debuginfod server.

**Verified:** builds and passes its tests with this patch (stage `stage0p`, 2026-11-15).

**What Yohane actually ships.** `elfutils.urls` belongs to `libdebuginfod-common`, which is `Architecture: all`, and
Yohane imports `Architecture: all` packages from Devuan instead of building them (decision 1). So the shipped file is
Debian's, with Debian's server (`https://debuginfod.debian.net`), exactly as on Devuan today. This patch only makes
the architecture-dependent build succeed. If the owner wants no default server, `libdebuginfod-common` would become an
explicit exception to decision 1 (built by Yohane instead of imported).

## 0002: no gcc-multilib

**Problem.** elfutils build-depends on `gcc-multilib` (for its tests of 32-bit objects), which needs glibc's 32-bit
libraries. libniji is 64-bit only and Yohane doesn't ship multilib, so in stage 1 the build dependencies couldn't be
installed (2026-11-16).

**Change.** `0002-no-gcc-multilib.patch` removes it from `debian/control`. The tests that compile 32-bit objects are
expected to skip themselves when `-m32` doesn't work; stage 1's test results confirm it.

## Stage 2: dropped build dependencies (gcc-multilib)

Its tests build 32-bit binaries with gcc-multilib. Yohane is amd64-only: libniji has no 32-bit libc, so there is no multilib to test against.

Found by stage 2, whose build root holds only Yohane's archive (design section 4): stage 1 could still install these from Devuan.
