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
