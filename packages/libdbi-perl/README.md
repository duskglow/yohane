Source: libdbi-perl
Applies-To: 1.656-1~deb13u1
Kind: build-fix
Status: 0001 active

# libdbi-perl

## 0001: honour nodoc for the examples (2026-11-24)

**Problem.** Every bootstrap build uses the `nodoc` profile (decision 15). Under nodoc, `dh_installexamples`
installs nothing, and `debian/rules` then runs `sed -i` on `.../examples/*`, which matches no file, so the build
fails after compiling and testing cleanly. Seen in Yohane's T2 build; Debian never builds this package with nodoc.

**Change.** `0001-honour-nodoc-for-examples.patch` runs the two `sed` commands only when examples are installed. A
normal build is unchanged, so the patch can stay.
