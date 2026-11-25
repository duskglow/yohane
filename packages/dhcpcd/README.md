Source: dhcpcd
Applies-To: excalibur
Kind: bootstrap
Status: active

# dhcpcd

## Stage 1 with Yohane's systemd (2026-11-25)

**Why:** dhcpcd build-depends on `systemd-timesyncd`, which Devuan doesn't ship. Debian's needs glibc 2.41, so in
a stage 1 root (Devuan and Debian binaries only) its build dependencies don't resolve. It was deferred to stage 2,
but the stage 2 root holds only stage 1 output, and the finish line needs dhcpcd (DHCP on the installed system).
Yohane's own stage 1 systemd is in the bootstrap suite.

**How:** `stage1-bootstrap-repo` makes `tools/buildone` add Yohane's bootstrap suite to the stage 1 build's
repositories, and pin the binary packages it lists (`systemd-timesyncd` and the systemd packages it depends on) to it.
The pin is needed because Yohane's systemd has the same version as Debian's, and apt took Debian's. Nothing in the
source changes.

**Restore:** delete `stage1-bootstrap-repo` once stage 1 is no longer rebuilt (after stage 2).
