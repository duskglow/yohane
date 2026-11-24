Source: avahi
Applies-To: excalibur
Kind: bootstrap
Status: active

# avahi

## T2 trim (2026-11-24): avahi-discover and the GTK/Qt UI libraries

**Bootstrap only (decisions 16 and 24).** Yohane builds avahi without avahi-discover and the GTK/Qt UI libraries, because they pull in GTK 3. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** the build profile `pkg.avahi.nogui`, which Debian's packaging defines, in `build-profiles`.

**Restore** in the full pass, or when a package Yohane ships needs it: remove `pkg.avahi.nogui` from `build-profiles`.
