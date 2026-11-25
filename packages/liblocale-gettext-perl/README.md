# liblocale-gettext-perl

Yohane changes to the liblocale-gettext-perl source package.

## Stage 2: dropped build dependencies (locales-all)

locales-all comes from glibc, which Yohane does not build; libniji provides no locales-all. It is test-only (<!nocheck>); the tests that need extra locales will skip or fail, and a failing test run is retried without tests.

Found by stage 2, whose build root holds only Yohane's archive (design section 4): stage 1 could still install these from Devuan.
