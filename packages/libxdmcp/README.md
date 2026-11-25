Source: libxdmcp
Applies-To: excalibur
Kind: bootstrap
Status: planned (patch written when the package is first built)

# libxdmcp

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds libxdmcp without the protocol documentation.
This keeps large build-dependency chains out of the minimal bootstrap set (found with
`tools/builddeps`' chain report, `T2.why`).

**How:** a patch removes `xmlto`, `xorg-sgml-doctools`, `w3m` from `debian/control` and disables what needs them.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

**Patch `0001-no-xmlto-docs.patch` (2026-11-25):** the drop list removes `xmlto`, but the rules still configured `--with-xmlto` and configure stopped. The patch configures `--without-xmlto`, drops the generated `xdmcp.txt` from `libxdmcp-dev`, and lets the XML cleanup skip a missing doc directory. The library is unchanged.
