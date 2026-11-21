Source: ncurses
Applies-To: 6.5+20250216-2
Kind: build-profile
Status: active

# ncurses

**No 32-bit variant.** Debian builds ncurses for amd64 and, alongside it, a 32-bit (`i386`) variant, which needs
`gcc-multilib` and glibc's 32-bit libraries. libniji is 64-bit only and Yohane doesn't ship multilib (design, section
1), so those build dependencies can't be installed (stage 1, 2026-11-16).

**How:** built with the Debian build profile `nobiarch`, which the package already defines for exactly this.

**Permanent,** not only for the bootstrap: there is no 32-bit C library to build against.
