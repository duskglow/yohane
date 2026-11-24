Source: protobuf
Applies-To: excalibur
Kind: bootstrap
Status: active

# protobuf

## T2 trim (2026-11-24): the manual pages build

**Bootstrap only (decisions 16 and 24).** Yohane builds protobuf without the manual pages build, because xmlto pulls in a documentation toolchain. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `xmlto`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps`.

**xmlto trim lifted (2026-11-24).** The trim above was chosen while `tools/builddeps` still counted Recommends, which
made xmlto look expensive. Resolved as sbuild does, without Recommends, xmlto adds only itself to T2, so it is built
instead and this package keeps its manual pages.

## 0001: honour nodoc when post-processing docs or examples (2026-11-24)

**Problem.** Every bootstrap build uses the `nodoc` profile (decision 15). Under nodoc, `dh_installexamples` and
`dh_installdocs` install nothing, and `debian/rules` then runs commands (`sed`, `chmod`, `rm`, `find`) on the
files they would have installed, which fail. Found by a scan of every T2 source still to build (tools: the T2
scratch scripts, nodocscan) after libdbi-perl, libvariable-magic-perl and libxml-parser-perl failed this way.

**Change.** `patches/0001-honour-nodoc.patch` wraps those commands in a nodoc check. A normal build is unchanged, so the
patch can stay.
