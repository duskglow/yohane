Source: llvm-toolchain-19
Applies-To: 1:19.1.7-3
Kind: build-fix
Status: active

# llvm-toolchain-19

## LLVM 19 without 32-bit (multilib) runtimes (2026-11-24)

**Problem.** Its T2 build failed at install-deps (or would have): `g++-multilib` needs glibc's 32-bit C library (`libc6-dev-i386`, `libc6-dev-x32`), which cannot be installed beside Yohane's 64-bit-only libniji (decision 21). The build dependency is `g++-multilib | hello`, so trimming leaves `hello`; compiler-rt's CMake then finds no 32-bit support and builds the x86_64 runtimes only. The install lists use globs, so nothing else changes.

**Change.** `drop-build-deps` lists `g++-multilib` (applied by `tools/trimcontrol`); no patch needed.
