Source: gawk
Applies-To: 1:5.2.1-2
Kind: bootstrap
Status: active

# gawk

## T2 trim (2026-11-24): locales-all

**Problem.** gawk build-depends on `locales-all` (unannotated, though only its tests use the locales). Debian's
`locales-all` is glibc's precompiled locale set and depends on glibc's `libc-l10n (> 2.41)`; libniji has no such
package, so gawk's T2 build failed at install-deps.

**Change.** `drop-build-deps` lists `locales-all`. T2 builds without tests (decision 15), so nothing is lost.

**Restore** when the build runs tests and libniji (or Yohane) provides precompiled locales; or rewrite the tests'
locale setup to generate the few locales they need with libniji's `localedef`.
