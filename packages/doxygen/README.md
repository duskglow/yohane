Source: doxygen
Applies-To: excalibur
Kind: bootstrap
Status: active

# doxygen

## T2 trim (2026-11-24): doxywizard, the Qt GUI

**Bootstrap only (decisions 16 and 24).** Yohane builds doxygen without doxywizard, the Qt GUI, because it pulls in Qt 5. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** the build profile `stage1`, which Debian's packaging defines, in `build-profiles`.

**Restore** in the full pass, or when a package Yohane ships needs it: remove `stage1` from `build-profiles`.
