Source: systemd
Applies-To: excalibur
Kind: bootstrap-profile
Status: active

# systemd

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds systemd without BPF, cryptsetup, fido2, qrencode, xen and other optional integrations (pulls LLVM/clang, the kernel tools, xen).
This keeps large build-dependency chains out of the minimal bootstrap set (they were found with
`tools/builddeps`' chain report, `T2.why`).

**How:** built with the Debian build profile(s) `stage1` the package already defines.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

## Stage 2: dropped build dependencies (rsync)

Listed as "rsync | meson (>= 1.3.0~)". sbuild installs only the first alternative, and rsync is not in Yohane's build set; meson is. Dropping rsync leaves meson.

Found by stage 2, whose build root holds only Yohane's archive (design section 4): stage 1 could still install these from Devuan.
