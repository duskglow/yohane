Source: rustc
Applies-To: 1.85.1+dfsg1-1+deb13u1
Kind: build-fix
Status: active

# rustc

## rustc without the profiler runtime (2026-11-24)

**Problem.** Its T2 build failed at install-deps (or would have): rustc links clang's `libclang_rt.profile` for its profiler builtins, from `libclang-rt-19-dev`, and Debian's `libclang-rt-19-dev` depends on `libc6-i386` (glibc's 32-bit C library), which Yohane can't install (decision 21). `0001` treats amd64 like the architectures Debian already builds without the profiler; `drop-build-deps` removes `libclang-rt-19-dev`. Missing until restored: `-C instrument-coverage` and PGO instrumentation. **Restore** when Yohane's own LLVM 19 (built without multilib, so its `libclang-rt-19-dev` has no `libc6-i386` dependency) is what builds resolve against: stage 2 on.

**Change.** `drop-build-deps` lists `libclang-rt-19-dev` (applied by `tools/trimcontrol`), and `patches/0001-no-profiler-runtime.patch` changes `debian/rules` as described.
