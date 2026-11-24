Source: libftdi1
Applies-To: 1.5-10
Kind: bootstrap
Status: 0001 and 0002 active

# libftdi1

## 0001 and 0002: Boost headers only, tests only when they run (2026-11-24)

**Problem.** libftdi1 build-depends on `libboost-test-dev` and always configures `BUILD_TESTS=ON`. Boost.Test is a
compiled library, so T2 had to rebuild all of Boost, and Debian's Boost packaging builds Boost.MPI unconditionally,
which needs an MPI implementation (and through ucx, golang). Found when boost1.83 failed in T2 after its MPI build
dependency was trimmed.

**Change.** `0001-boost-headers-only.patch` build-depends on `libboost-dev` (headers only, ELF-free, so imported
under decision 13) instead. `0002-tests-honour-nocheck.patch` builds the unit tests only when tests run. The C++
binding (libftdipp1) is unchanged.

**Restore** in the full pass, when Boost is built in full.
