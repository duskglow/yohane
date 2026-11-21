Source: libzstd
Applies-To: 1.5.7+dfsg-1
Kind: build-fix
Status: 0001 active

# libzstd

## 0001: zstd-small keeps the build's hardening flags

**Problem.** Yohane's C library (libniji) marks its start files (`crt1.o`, `Scrt1.o`, `crti.o`, `crtn.o`) with the
x86 CET properties IBT and SHSTK. Debian's glibc doesn't (decision 23). zstd's `lib/libzstd.mk` adds
`-z cet-report=error` to LDFLAGS whenever a trivial test link with that flag succeeds. Against Debian's unmarked start
files it never does, so the flag is never used. Against libniji's it does, so the flag goes on.

`programs/Makefile` builds the test program `zstd-small` with `CFLAGS = -Os -Wl,-s`. That replaces the flags
`debian/rules` passes in, `-fcf-protection` among them, but keeps LDFLAGS. So `zstd-small`'s own objects lack the CET
properties, and the link fails: "missing IBT and SHSTK properties", 32 times (stage 1 on `snapshot-2026-11-21.4`, in
the test step; the library and tools build fine).

**Change.** `0001-zstd-small-keep-hardening-flags.patch` makes it `CFLAGS += -Os -Wl,-s`, so `zstd-small` is built
with the distribution's flags plus `-Os`, like every other program. It's an upstream Makefile bug that Debian never
hits, since `cet-report` is never enabled there. Not egregious, so not sent (package patch policy).

**Restored** never needed. The patch is harmless on glibc: there `zstd-small` simply gets the hardening flags too.
