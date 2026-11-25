Source: newt
Applies-To: excalibur
Kind: bootstrap
Status: planned (patch written when the package is first built)

# newt

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds newt without the Tcl binding (whiptcl) and DocBook documentation.
This keeps large build-dependency chains out of the minimal bootstrap set (found with
`tools/builddeps`' chain report, `T2.why`).

**How:** a patch removes `tcl8.6-dev`, `docbook-utils` from `debian/control` and disables what needs them.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

**Patch `0001-no-tcl-no-docbook.patch` (2026-11-25):** the drop list removes `tcl8.6-dev`, but the rules forced `WHIPTCLLIB=whiptcl` and the build failed (tcl.h not found). The patch stops forcing it and removes the `newt-tcl` package. whiptail and the libraries are unchanged. It also skips the HTML tutorial, which needs the dropped docbook-utils (docbook2html).
