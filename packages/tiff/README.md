Source: tiff
Applies-To: excalibur
Kind: bootstrap
Status: active

# tiff

## T2 trim (2026-11-24): tiffgt, the OpenGL viewer

**Bootstrap only (decisions 16 and 24).** Yohane builds tiff without tiffgt, the OpenGL viewer, because it pulls in GLUT, Mesa and X. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `freeglut3-dev`, `libglu1-mesa-dev`, `libxi-dev`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps`.
