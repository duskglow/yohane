Source: dracut
Applies-To: excalibur
Kind: bootstrap
Status: active

# dracut

## T2 trim (2026-11-24): the manual pages (asciidoc)

**Bootstrap only (decisions 16 and 24).** Yohane builds dracut without the manual pages (asciidoc), because asciidoc pulls in a large documentation toolchain. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `asciidoc-base`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Patch (2026-11-26):** the build still ran asciidoc for the man pages (`man/lsinitrd.1.xml` failed in stage 2).
`patches/0001-no-manpages.patch` configures with `--disable-documentation`, dracut's own switch for skipping the
pages, and removes `debian/dracut-core.manpages`, since there are no pages to install.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps` and
the patch.
