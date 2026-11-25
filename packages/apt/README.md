Source: apt
Applies-To: excalibur
Kind: bootstrap-profile
Status: active

# apt

**Bootstrap only (decision 16).** During the bootstrap, Yohane builds apt without sqv (Sequoia, Rust) for signature checks; gpgv is used instead, so rust-sequoia-sq and rustc leave the bootstrap.
This keeps large build-dependency chains out of the minimal bootstrap set (found with
`tools/builddeps`' chain report, `T2.why`).

**How:** built with the Debian build profile(s) `pkg.apt.nosqv` the package already defines, and `drop-build-deps`
lists `sqv`.

**Why both (2026-11-25):** the profile alone did not work. The Build-Depends group is
`sqv (>= 1.3.0) [...] <!pkg.apt.nosqv> | gpgv`, and sbuild's resolver installs the first alternative. In stage 1
it installed sqv despite the profile ("Filtered Build-Depends: ... sqv (>= 1.3.0)"). `debian/rules` then makes apt
depend on sqv whenever `/usr/bin/sqv` exists at build time (`-Vopenpgp:Depends=$(shell test -e /usr/bin/sqv ...)`),
so the stage 1 apt depended on sqv, a Rust package Yohane doesn't build, and the stage 2 build root (Yohane binaries
only) could not install apt. `drop-build-deps` removes sqv from `debian/control`, leaving `gpgv`, so sqv is never
installed and apt depends on gpgv, as Devuan's own apt does.

**Restored in the full pass,** once the system rebuilds itself; Snow Halation ships the full-featured build.
