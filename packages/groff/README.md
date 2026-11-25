Source: groff
Applies-To: excalibur
Kind: bootstrap
Status: active (0001)

# groff

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds groff without PDF/TeX output tooling and the gxditview X previewer (pulls TeX Live, ghostscript, X).
This keeps large build-dependency chains out of the minimal bootstrap set (they were found with
`tools/builddeps`' chain report, `T2.why`).

**How:** a patch removes `texlive-base`, `texlive-latex-base`, `ghostscript`, `netpbm`, `psutils`, `libx11-dev`, `libxaw7-dev`, `libxmu-dev`, `libxt-dev` from `debian/control` and disables what needs them.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

**Patch `0001-no-x11-previewer.patch` (written 2026-11-25):** removes the X11 parts from `debian/groff.install`: the
gxditview previewer, xtotroff, their man pages, the app-defaults directory, `FontMap-X11` and the `devX*` fonts.
Stage 1 never applied the drop list; stage 2 did, and dh_install failed on the missing X files. Everything else in
`groff` and `groff-base` is unchanged; the PDF/PostScript tools built without the dropped dependencies.
