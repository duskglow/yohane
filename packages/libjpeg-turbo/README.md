Source: libjpeg-turbo
Applies-To: excalibur
Kind: bootstrap
Status: active

# libjpeg-turbo

## T2 trim (2026-11-24): the Java bindings (libturbojpeg-java)

**Bootstrap only (decisions 16 and 24).** Yohane builds libjpeg-turbo without the Java bindings (libturbojpeg-java), because they pull in a JDK. Found with
`tools/builddeps` and the min-cut analysis of 2026-11-24: T2 went from 833 sources to 269 with this batch.

**How:** `drop-build-deps` lists `default-jdk`, `javahelper`; `tools/buildone` removes them from `debian/control` with `tools/trimcontrol`. The binary packages that need them may then fail to build; if so, a patch under `patches/` drops them from `debian/control` too, and this section says which.

**Restore** in the full pass, or when a package Yohane ships needs it: remove those names from `drop-build-deps`.

## 0001: rules without Java (2026-11-24)

**Problem.** Dropping `default-jdk` and `javahelper` wasn't enough: `debian/rules` runs `dh $@ --with javahelper` and
configures `WITH_JAVA=1` on amd64, so the build failed at its first step ("unable to load addon javahelper").

**Change.** `patches/0001-no-java-bindings.patch` empties `JAVA_ARCHS` (so `WITH_JAVA=0`) and drops the javahelper
add-on. `libturbojpeg-java` is `Architecture: all`, so an arch-only build never built it anyway. Restore together
with the drop-build-deps lines.

**0002 (2026-11-24): JNI symbols optional.** Without Java, `libturbojpeg.so` no longer exports its
`Java_org_libjpegturbo_*` JNI entry points, and the symbols file (checked at level 4) required them.
`patches/0002-jni-symbols-optional.patch` marks them optional. **This is an ABI difference from Debian's
libturbojpeg0:** a Java program using Debian's libturbojpeg-java would not find those functions in this build. Nothing
in Yohane uses them; restore with the rest of this trim.

**0002 revised (2026-11-24): JNI symbols removed, not optional.** Marking them optional (the first 0002) wasn't
enough: `debian/rules` sets `DPKG_GENSYMBOLS_CHECK_LEVEL = 4`, which fails on any change, optional symbols
disappearing included. `patches/0002-no-jni-symbols.patch` replaces it and removes the 31 lines from the symbols
file. **This is an ABI difference from Debian's
libturbojpeg0:** a Java program using Debian's libturbojpeg-java would not find those functions in this build. Nothing
in Yohane uses them; restore with the rest of this trim.
