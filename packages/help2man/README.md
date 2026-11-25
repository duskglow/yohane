Source: help2man
Applies-To: 1.49.3
Kind: build-fix
Status: active

# help2man

**Problem.** help2man is a native package, and its `debian/rules` clean step (`check-maint-prep`) accepts a version
that isn't the upstream release only when it looks like a Debian binNMU (`+bN`). Yohane's stage 2 and 3 builds are
binNMU-style with a `+yohaneN` suffix (decision 26), so the check failed before the build started.

**Change.** `0001-yohane-binnmu.patch` also accepts `+yohaneN` as a binNMU.

**Permanent** while Yohane uses the `+yohaneN` suffix. Other native packages with the same `+bN` test need the same
change.
