Source: e2fsprogs
Applies-To: excalibur
Kind: bootstrap
Status: active

# e2fsprogs

## Stage 1 with Yohane's systemd (2026-11-25)

**Why:** e2fsprogs build-depends on `systemd`. Devuan doesn't ship systemd, and Debian's needs glibc 2.41, so in a stage 1 root
(Devuan and Debian binaries only) its build dependencies don't resolve. It was deferred to stage 2, but the stage 2
root holds only stage 1 output, and other sources need e2fsprogs' libraries at build time (`libcom-err2` through
`comerr-dev`, for krb5 and others). Yohane's own stage 1 systemd is in the bootstrap suite.

**How:** `stage1-bootstrap-repo` makes `tools/buildone` add Yohane's bootstrap suite to the stage 1 build's
repositories, so `systemd` resolves to Yohane's build. Nothing in the source changes.

**Restore:** delete `stage1-bootstrap-repo` once stage 1 is no longer rebuilt (after stage 2).
