Source: libde265
Applies-To: excalibur
Kind: bootstrap
Status: active

# libde265

## T2 trim (2026-11-24): the sample players (dec265, sherlock265)

**Bootstrap only (decisions 16 and 24).** Yohane builds libde265 without the sample players (dec265, sherlock265), because they pull in SDL, ffmpeg and Qt. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `libsdl2-dev`, `libswscale-dev`, `qtbase5-dev`, `libqt4-dev`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps`.
