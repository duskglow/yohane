Source: gpgme1.0
Applies-To: excalibur
Kind: bootstrap
Status: active

# gpgme1.0

## T2 trim (2026-11-24): the Qt bindings (qgpgme)

**Bootstrap only (decisions 16 and 24).** Yohane builds gpgme1.0 without the Qt bindings (qgpgme), because they pull in Qt 5 and Qt 6. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `qt6-base-dev`, `qtbase5-dev`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps`.

**Patch (2026-11-24):** `patches/0001-no-qt-bindings.patch`. Dropping Qt from the build dependencies wasn't enough:
`debian/rules` passes `--enable-languages="python cpp qt5 qt6"`, so configure failed looking for Qt5Test. The patch
asks for `python cpp` only and removes the four Qt binding packages (`libqgpgme15t64`, `libqgpgmeqt6-15` and their
`-dev` packages) from `debian/control`.
