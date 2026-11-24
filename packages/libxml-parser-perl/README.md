Source: libxml-parser-perl
Applies-To: 2.47-2~deb13u1
Kind: build-fix
Status: active

# libxml-parser-perl

## 0001: honour nodoc when post-processing docs or examples (2026-11-24)

**Problem.** Every bootstrap build uses the `nodoc` profile (decision 15). Under nodoc, `dh_installexamples` and
`dh_installdocs` install nothing, and `debian/rules` then runs commands (`sed`, `chmod`, `rm`, `find`) on the
files they would have installed, which fail. Found by a scan of every T2 source still to build (tools: the T2
scratch scripts, nodocscan) after libdbi-perl, libvariable-magic-perl and libxml-parser-perl failed this way.

**Change.** `patches/0001-honour-nodoc.patch` wraps those commands in a nodoc check. A normal build is unchanged, so the
patch can stay.
