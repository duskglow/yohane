Source: libxmu
Applies-To: excalibur
Kind: bootstrap
Status: active

# libxmu

## T2 trim (2026-11-24): the documentation build

**Bootstrap only (decisions 16 and 24).** Yohane builds libxmu without the documentation build, because xmlto pulls in a documentation toolchain. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `xmlto`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps`.

**xmlto trim lifted (2026-11-24).** The trim above was chosen while `tools/builddeps` still counted Recommends, which
made xmlto look expensive. Resolved as sbuild does, without Recommends, xmlto adds only itself to T2, so it is built
instead and this package keeps its manual pages.
