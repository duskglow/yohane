Source: z3
Applies-To: excalibur
Kind: bootstrap
Status: active

# z3

## T2 trim (2026-11-24): the Java bindings

**Bootstrap only (decisions 16 and 24).** Yohane builds z3 without the Java bindings, because they pull in a JDK. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** the build profile `nojava`, which Debian's packaging defines, in `build-profiles`.

**Restore** in the full pass, or when a package Yohane ships needs it: remove `nojava` from `build-profiles`.
