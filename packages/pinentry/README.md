Source: pinentry
Applies-To: excalibur
Kind: bootstrap
Status: active

# pinentry

## T2 trim (2026-11-24): the GUI pinentries (GTK 2, GNOME/gcr, Qt 6, FLTK, KDE)

**Bootstrap only (decisions 16 and 24).** Yohane builds pinentry without the GUI pinentries (GTK 2, GNOME/gcr, Qt 6, FLTK, KDE), because they pull in Qt 6, GTK, the KDE frameworks and libsecret. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** the build profile `pkg.pinentry.onlytty`, which Debian's packaging defines, in `build-profiles`.

**Restore** in the full pass, or when a package Yohane ships needs it: remove `pkg.pinentry.onlytty` from `build-profiles`.
