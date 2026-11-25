Source: grub2
Applies-To: 2.12-9+deb13u2
Kind: build-fix (0001); bootstrap (planned trims)
Status: active (UEFI-only until BIOS support is investigated)

# grub2

**Problem.** On amd64, Debian's grub2 also builds the 32-bit x86 boot platforms: BIOS (`grub-pc`, `grub-rescue-pc`,
`grub-firmware-qemu`), 32-bit UEFI (`grub-efi-ia32`), coreboot, IEEE 1275 and Xen. GRUB itself doesn't use a C
library, but its 32-bit build needs gcc's 32-bit support (`gcc-multilib`), which in Debian depends on glibc's 32-bit
libraries. libniji is 64-bit only, so in stage 1 the build dependencies couldn't be installed (2026-11-16).

**Owner decision (2026-11-16): UEFI-only for now.** `0001-uefi-only-on-amd64.patch`:
- drops `gcc-multilib` from the build dependencies on amd64;
- builds the 32-bit x86 platform packages only on i386 (`grub-pc*`, `grub-rescue-pc`, `grub-coreboot*`,
  `grub-efi-ia32*`, `grub-ieee1275*`, `grub-firmware-qemu`, `grub-xen*`, `grub-xen-host`);
- makes 64-bit UEFI (`efi-amd64`) the common platform on amd64 in place of `pc`.

On amd64, Yohane ships `grub-common`, `grub2-common`, `grub-efi-amd64*` and `grub-emu`.

**Consequence.** Yohane boots on UEFI machines and VMs only. Proxmox and QEMU VMs default to BIOS (SeaBIOS); set
their firmware to OVMF (UEFI). Yohane's own image boot test is unaffected (it boots the kernel directly).

**Later milestone: BIOS boot.** GRUB's BIOS build needs 32-bit code generation, not a 32-bit C library, so it may be
possible to give gcc just enough 32-bit support for GRUB. To be investigated.

## Bootstrap trims (planned, decision 16)

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds grub2 without grub-emu's SDL display, the qemu-based tests, grub-mount (FUSE) and grub-mkrescue's ISO support (pulls qemu, SDL, PulseAudio and LLVM 22).
This keeps large build-dependency chains out of the minimal bootstrap set (they were found with
`tools/builddeps`' chain report, `T2.why`).

**How:** a patch removes `libsdl2-dev`, `qemu-system`, `libfuse3-dev`, `xorriso` from `debian/control` and disables what needs them.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

## Stage 2: dropped build dependencies (gcc-multilib)

Yohane is amd64-only (libniji has no 32-bit libc). grub's i386-pc and ia32 EFI platforms are freestanding code compiled with -m32 by the amd64 compiler and don't link a 32-bit libc.

Found by stage 2, whose build root holds only Yohane's archive (design section 4): stage 1 could still install these from Devuan.
