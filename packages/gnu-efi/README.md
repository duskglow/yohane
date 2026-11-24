Source: gnu-efi
Applies-To: 3.0.18-1+deb13u1
Kind: build-fix
Status: active

# gnu-efi

## gnu-efi without the ia32 compat libraries (2026-11-24)

**Problem.** Its T2 build failed at install-deps (or would have): On amd64 gnu-efi also builds an ia32 copy into `/usr/lib32` with `gcc-multilib`. Yohane has no 32-bit C library, and 32-bit UEFI is out of scope for now (decision 21: UEFI-only, 64-bit). `0001` builds x86_64 only; `drop-build-deps` removes `gcc-multilib`.

**Change.** `drop-build-deps` lists `gcc-multilib` (applied by `tools/trimcontrol`), and `patches/0001-no-ia32-compat.patch` changes `debian/rules` as described.
