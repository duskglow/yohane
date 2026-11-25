Source: apparmor
Applies-To: excalibur
Kind: bootstrap
Status: planned (patch written when the package is first built)

# apparmor

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds apparmor without the Apache module mod_apparmor.
This keeps large build-dependency chains out of the minimal bootstrap set (they were found with
`tools/builddeps`' chain report, `T2.why`).

**How:** a patch removes `apache2-dev`, `dh-apache2` from `debian/control` and disables what needs them.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

## T2 trim (2026-11-24): the desktop-notification test of aa-notify

**Bootstrap only (decisions 16 and 24).** Yohane builds apparmor without the desktop-notification test of aa-notify, because it pulls in the D-Bus/GLib desktop stack. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `python3-notify2`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps`.

## Patch: no Apache module (0001-no-apache2.patch, 2026-11-25)

The drop list removes apache2-dev and dh-apache2, but debian/rules still ran the apache2 debhelper sequence and
installed mod_apparmor, so the build stopped at "unable to load addon apache2" (first seen in stage 2: stage 1
built apparmor unpatched). The patch drops the sequence, the mod_apparmor install and the dh_apache2 override
from debian/rules, and the libapache2-mod-apparmor package from debian/control. apparmor stays in the set for
dh-apparmor (bind9, cups, man-db, unbound) and libapparmor (dbus, systemd).
