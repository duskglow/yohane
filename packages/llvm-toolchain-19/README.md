Source: llvm-toolchain-19
Applies-To: 1:19.1.7-3
Kind: build-fix
Status: active

# llvm-toolchain-19

## LLVM 19 without 32-bit (multilib) runtimes (2026-11-24)

**Problem.** Its T2 build failed at install-deps (or would have): `g++-multilib` needs glibc's 32-bit C library (`libc6-dev-i386`, `libc6-dev-x32`), which cannot be installed beside Yohane's 64-bit-only libniji (decision 21). The build dependency is `g++-multilib | hello`, so trimming leaves `hello`; compiler-rt's CMake then finds no 32-bit support and builds the x86_64 runtimes only. The install lists use globs, so nothing else changes.

**Change.** `drop-build-deps` lists `g++-multilib` (applied by `tools/trimcontrol`); no patch needed.

## Stage 2: dropped build dependencies (llvm-spirv-19 spirv-tools wasi-libc hello)

The SPIR-V translator, SPIRV-Tools and wasi-libc are for GPU and WebAssembly targets Yohane does not build. Each is listed as "X | hello", where hello is a placeholder meaning "build without X"; Yohane does not build hello either, so whole groups are removed.

Found by stage 2, whose build root holds only Yohane's archive (design section 4): stage 1 could still install these from Devuan.

**Patch `0001-no-wasm-libcxx.patch` (2026-11-25):** sets `LIBCXX_WASM_ENABLE=no` in `debian/rules` and removes the
`libc++-19-dev-wasm32` and `libc++abi-19-dev-wasm32` packages (both depend on wasi-libc) from `debian/control`.
Without it the rules' preconfigure step checks for wasi-libc and stops ("Could not find wasi-libc on the system").