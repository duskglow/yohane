Source: bash
Applies-To: 5.2.37-2
Kind: build-fix
Status: 0001 active

# bash

## 0001: `debian/rules` tolerates a missing bash-doc examples directory

**Problem.** Every stage 1 build uses the `nodoc` build profile (decision 15). With `nodoc`, `dh_installexamples`
does nothing for the documentation package `bash-doc`, so `debian/bash-doc/usr/share/doc/bash/examples` is never
created. The install target in bash's `debian/rules` then runs `cd` into that directory twice, to fix the modes of
three example scripts. The first `cd` fails and stops the whole arch-dependent build
(`stamps/stamp-install-bash`), after the build and the test suite have passed. Seen in stage 1 on
`snapshot-2026-11-23.1`; Debian's own builds never use `nodoc` for bash, so they don't hit it.

**Change.** `0001-debian-rules-nodoc-bash-doc-examples.patch` skips the two `chmod` steps when the directory is
absent. A normal build creates it and is unchanged. `bash-doc` is `Architecture: all`, and stage 1 builds only the
arch-dependent packages, so nothing we ship loses a file.

Not egregious, and specific to a build profile Debian doesn't use for bash, so not sent (package patch policy).

**Restore** when stage 1 stops using `nodoc` for bash (the end of the bootstrap, decision 15), or if Debian makes
the rules `nodoc`-safe.
