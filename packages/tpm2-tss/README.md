Source: tpm2-tss
Applies-To: 4.1.3-1.2
Kind: build-fix
Status: active

# tpm2-tss

## 0001: the FAPI tmpfiles.d snippet without systemd-tmpfiles (2026-11-24)

**Problem.** `configure` installs `tpm2-tss-fapi.conf` (tmpfiles.d) only when it finds `systemd-tmpfiles` on the build
host. A Devuan build root has none, but `debian/libtss2-fapi1t64.install` always names the file, so `dh_install`
failed on missing files.

**Change.** `patches/0001-tmpfiles-snippet-without-systemd.patch` passes `ac_cv_prog_systemd_tmpfiles=yes`, so the
snippet is built and shipped as in Debian (tmpfiles.d is read by any tmpfiles implementation, not only systemd's).
With DESTDIR set, the install hook creates the FAPI directories itself, so the build never runs the tool.
