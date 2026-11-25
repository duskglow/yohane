Source: libidn
Applies-To: excalibur
Kind: bootstrap
Status: planned (patch written when the package is first built)

# libidn

**Bootstrap only (decision 16).** Yohane builds libidn without graphviz (documentation tooling).
This keeps a large build-dependency chain out of the minimal bootstrap set (found with
`tools/builddeps`' chain report, `T2.why`).

**How:** `drop-build-deps` removes `graphviz` from `debian/control`; a patch disables what needs it if the build does.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

**No longer dropped: git.** gnulib's clone step needs it, and git is now built by Yohane, so
the Go chain it was dropped for is gone (same change as libidn2).
