Source: vim
Applies-To: excalibur
Kind: bootstrap
Status: planned (patch written when the package is first built)

# vim

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds vim without the GUI flavours (GTK, Motif) and event sounds (pulls libcanberra, samba's libtdb, PulseAudio, bluez).
This keeps large build-dependency chains out of the minimal bootstrap set (found with
`tools/builddeps`' chain report, `T2.why`).

**How:** built with the Debian build profile(s) `pkg.vim.noruby` the package already defines; a patch removes `libgtk-3-dev`, `libmotif-dev`, `libcanberra-dev` from `debian/control` and disables what needs them.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

## Stage 2: dropped build dependencies (locales-all)

locales-all comes from glibc, which Yohane does not build; libniji provides no locales-all. It is test-only (<!nocheck>).

Found by stage 2, whose build root holds only Yohane's archive (design section 4): stage 1 could still install these from Devuan.
