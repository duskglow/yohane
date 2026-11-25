Source: gcc-14
Applies-To: 14.2.0-19
Kind: build-fix (0001); bootstrap (planned trims)
Status: 0001 active; bootstrap trims planned (patch written when first needed)

# gcc-14

## 0001: no multilib

**Problem.** On amd64, Debian builds gcc with 32-bit (`-m32`) and x32 (`-mx32`) multilib: extra runtime libraries
(`lib32gcc-s1`, `libx32stdc++6`, ...) and a test-suite pass per configuration. That needs glibc's 32-bit and x32
libraries (`libc6-dev-i386`, `libc6-dev-x32`), and gcc also build-depends on `libc6-dbg`. libniji is 64-bit only, has
no debug-symbol package, and Yohane doesn't ship multilib (design, section 1), so in stage 1 the build dependencies
couldn't be installed (2026-11-16).

**Change.** `0001-no-multilib.patch`:
- removes `g++-multilib`, `libc6-dev-i386`, `libc6-dev-x32`, `lib32gcc-s1`, `libx32gcc-s1`, `lib32z1-dev` and
  `libc6-dbg` from `debian/control`;
- turns multilib off by default in `debian/rules.defs` (the packaging's own `biarch` switch; `DEB_BUILD_OPTIONS=lang=biarch`
  turns it back on).

gcc then builds only 64-bit runtime libraries, and its test suite runs once instead of three times. The stage 0
baseline (glibc, with multilib) took 8 h 14 min, much of it in the `-m32` test configuration.

**Permanent,** not only for the bootstrap: there is no 32-bit C library to build against.

## Bootstrap trims (planned, decision 16)

During the bootstrap, Yohane builds gcc-14 without the Ada, D and Rust front ends and the GPU offload compilers: a
C/C++-only bootstrap compiler (they pull LLVM 19, rustc, OCaml). This keeps large build-dependency chains out of the
minimal bootstrap set (found with `tools/builddeps`' chain report, `T2.why`). Stage 1 doesn't need it, because its
build environment still installs Devuan's binaries; the patch is written when stage 2 needs it.

**How:** a patch removes `gnat-14`, `gnat-13`, `gdc-14`, `cargo`, `nvptx-tools`, `amdgcn-tools-19` from `debian/control`
and disables what needs them.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

## Stage 2: dropped build dependencies (g++-multilib lib32gcc-s1 lib32z1-dev libc6-dev-i386 libc6-dev-x32 libx32gcc-s1 locales-all)

Yohane is amd64-only: libniji has no 32-bit or x32 libc, so gcc-14 is built without biarch (stage 1's build already produced no lib32/libx32 packages). locales-all comes from glibc, which Yohane does not build; libniji provides no locales-all.

Found by stage 2, whose build root holds only Yohane's archive (design section 4): stage 1 could still install these from Devuan.
