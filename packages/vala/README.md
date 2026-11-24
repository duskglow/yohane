Source: vala
Applies-To: excalibur
Kind: bootstrap
Status: active

# vala

## T2 trim (2026-11-24): valadoc's graph output

**Bootstrap only (decisions 16 and 24).** Yohane builds vala without valadoc's graph output, because it pulls in graphviz and through it GTK and GTS. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** the build profile `pkg.vala.nographviz`, which Debian's packaging defines, in `build-profiles`.

**Restore** in the full pass, or when a package Yohane ships needs it: remove `pkg.vala.nographviz` from `build-profiles`.
