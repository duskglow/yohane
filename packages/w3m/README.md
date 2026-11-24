Source: w3m
Applies-To: excalibur
Kind: bootstrap
Status: active

# w3m

## T2 trim (2026-11-24): the image viewer helper (w3m-img)

**Bootstrap only (decisions 16 and 24).** Yohane builds w3m without the image viewer helper (w3m-img), because it pulls in imlib2 and through it the X and image stack. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** the build profile `stage1`, which Debian's packaging defines, in `build-profiles`.

**Restore** in the full pass, or when a package Yohane ships needs it: remove `stage1` from `build-profiles`.
