Source: poppler
Applies-To: excalibur
Kind: bootstrap
Status: active

# poppler

## T2 trim (2026-11-24): the GLib/GTK demo and the Qt 5 and Qt 6 bindings

**Bootstrap only (decisions 16 and 24).** Yohane builds poppler without the GLib/GTK demo and the Qt 5 and Qt 6 bindings, because they pull in GTK 3, Qt 5 and Qt 6. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `libgtk-3-dev`, `qt6-base-dev`, `qtbase5-dev`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps`.

**Patch (2026-11-24):** `patches/0001-no-qt-bindings.patch` switches off `ENABLE_QT5` (hard-coded on in
`debian/rules`) and drops the four Qt binding packages from `debian/control`. Without it the build would fail at
configure for lack of Qt. The GLib binding is kept.
