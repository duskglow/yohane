Source: lvm2
Applies-To: excalibur
Kind: bootstrap
Status: planned (patch written when the package is first built)

# lvm2

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds lvm2 without cluster locking (dlm, corosync, sanlock) and the rest of corosync support.
This keeps large build-dependency chains out of the minimal bootstrap set (they were found with
`tools/builddeps`' chain report, `T2.why`).

**How:** a patch removes `libcorosync-common-dev`, `libdlm-dev`, `libdlmcontrol-dev`, `libsanlock-dev` from `debian/control` and disables what needs them.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.

**Patch `0001-no-lvmlockd.patch` (2026-11-25):** the drop list removes sanlock, dlm and corosync, but the rules still enabled `--enable-lvmlockd-dlm` and `--enable-lvmlockd-sanlock`, and configure stopped (libsanlock_client not found). The patch drops both flags; with no lock manager, lvmlockd isn't built, so the `lvm2-lockd` package goes too. Local LVM, dmeventd and lvmpolld are unchanged.
