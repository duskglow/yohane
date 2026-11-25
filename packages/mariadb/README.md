Source: mariadb
Applies-To: excalibur
Kind: bootstrap
Status: active

# mariadb

## T2 trim (2026-11-24): the Java-based parts

**Bootstrap only (decisions 16 and 24).** Yohane builds mariadb without the Java-based parts, because they pull in a JDK. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `default-jdk`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps`.

**Patch `0001-no-connect-jdbc.patch`:** removes the arch:all `mariadb-plugin-connect-jdbc` package from `debian/control`.
Its JDBC interface jar needs a JDK, so without `default-jdk` the indep build failed in dh_install
(`usr/share/mariadb/JdbcInterface.jar` missing). Stage 1 built arch:any only and never reached it.
