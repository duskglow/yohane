Source: xen
Applies-To: excalibur
Kind: build-fix
Status: planned (patch written when the package is first built)

# xen

**Problem.** `debian/control` build-depends on `pandoc` unconditionally, for documentation only. pandoc is a
Haskell program, so it would pull ghc and about 260 Haskell libraries into the bootstrap on libniji (decision 14).

**Change (planned).** Mark `pandoc` `<!nodoc>` and skip the pandoc-generated documentation under the `nodoc` build
profile, which Yohane uses for this package (`build-profiles`). `drop-build-deps` declares that the patch removes
`pandoc`, so tier planning (`tools/builddeps`) already leaves it out.

**Reverted** when ghc is brought up on libniji (the later milestone in decision 14).
