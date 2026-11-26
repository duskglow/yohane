Source: libidn
Applies-To: excalibur
Kind: bootstrap
Status: active

# libidn

**Bootstrap only (decision 16).** Yohane builds libidn without graphviz (documentation tooling).
This keeps a large build-dependency chain out of the minimal bootstrap set (found with
`tools/builddeps`' chain report, `T2.why`).

**How:** `drop-build-deps` removes `graphviz` from `debian/control`. graphviz's `dot` draws the manual's components
diagram (`libidn-components.png`), which stage 2 failed on. `patches/0001-no-components-diagram.patch` takes the
image out of the manual: the `@image` line in `doc/libidn.texi`, the PNG's install and build dependencies in
`doc/Makefile.am`, and its line in `debian/libidn-dev.install`. The paragraph describing the components stays.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

**No longer dropped: git.** gnulib's clone step needs it, and git is now built by Yohane, so
the Go chain it was dropped for is gone (same change as libidn2).
