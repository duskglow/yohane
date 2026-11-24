Source: opensp
Applies-To: excalibur
Kind: bootstrap
Status: active

# opensp

## T2 trim (2026-11-24): the documentation build

**Bootstrap only (decisions 16 and 24).** Yohane builds opensp without the documentation build, because it pulls in texlive, poppler and xmlto. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** the build profile `pkg.opensp.bootstrap`, which Debian's packaging defines, in `build-profiles`.

**Restore** in the full pass, or when a package Yohane ships needs it: remove `pkg.opensp.bootstrap` from `build-profiles`.

## 0001: the doc build follows the bootstrap profile (2026-11-24)

**Problem.** Debian's `debian/control` drops `xmlto` and `docbook-dsssl` under `pkg.opensp.bootstrap`, but
`debian/rules` passes `--disable-doc-build` only under the `stage1` profile, so the trimmed build failed in configure
("could not find xmlto").

**Change.** `patches/0001-doc-build-follows-bootstrap-profile.patch` disables the doc build under `stage1`, `nodoc` or
`pkg.opensp.bootstrap`. A normal build is unchanged. Keep it while the trim is active; it is harmless after.

## 0001 revised (2026-11-24)

`debian/rules` tests the `stage1` profile a second time, in `install-stamp`, where it edits the generated `onsgmls.1`
that the disabled doc build never made. 0001 now sets one variable from `stage1`, `nodoc` and `pkg.opensp.bootstrap`
and uses it in both places, so the install step takes Debian's stage1 path (empty placeholder man pages).
