Source: netcat-openbsd
Applies-To: 1.229-1
Kind: build-fix
Status: active

# netcat-openbsd

## 0001: honour nodoc when renaming the man page (2026-11-24)

**Problem.** Every bootstrap build uses the `nodoc` profile (decision 15). Under nodoc, `dh_installman` installs
nothing, and `execute_after_dh_installman` then fails to rename `nc.1` to `nc_openbsd.1`.

**Change.** `patches/0001-honour-nodoc-man-rename.patch` runs the rename only when docs are built. The man page
slaves in postinst point at a file that is absent under nodoc, which update-alternatives tolerates. A normal build is
unchanged.
