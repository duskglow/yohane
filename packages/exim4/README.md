Source: exim4
Applies-To: excalibur
Kind: bootstrap
Status: active

# exim4

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds exim4-daemon-heavy without the MySQL and
PostgreSQL lookups. This keeps large build-dependency chains (MariaDB, PostgreSQL) out of the minimal bootstrap set
(found with `tools/builddeps`' chain report, `T2.why`).

**How:** `drop-build-deps` lists `default-libmysqlclient-dev` and `libpq-dev`. `patches/0001-no-sql-lookups.patch`
adds a step to `debian/rules`' `override_dh_auto_configure`: after the heavy daemon's `Local/Makefile` is set up, it
comments out `LOOKUP_MYSQL` and `LOOKUP_PGSQL`, empties `LOOKUP_INCLUDE` and removes `-lmysqlclient -lpq` from
`LOOKUP_LIBS`, then fails if any uncommented MySQL or PostgreSQL line is left. LDAP and SQLite lookups stay.

**No longer dropped: the X11 libraries (2026-11-26).** `libx11-dev`, `libxaw7-dev`, `libxext-dev`, `libxmu-dev` and
`libxt-dev` were dropped for the eximon X monitor, but no patch to remove eximon was ever written, so stage 2 failed on
`X11/IntrinsicP.h`. Yohane builds all five, so eximon4 builds as in Devuan.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.
