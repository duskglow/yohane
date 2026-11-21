# Yohane package changes

Every change Yohane makes to a Devuan source package is here, one directory per source package. Yohane patches
freely; the rule is that every change is written down. Patches are not sent upstream unless a bug is egregious.

## Layout

```
packages/<source>/
  README.md        what the change does, why, the failure it fixes, the libniji issue (if any)
  patches/*.patch  applied in name order to the unpacked Devuan source before building
  build-profiles   build profiles Yohane builds the source with (e.g. "nodoc")
  drop-build-deps  binary build dependencies the source's patch removes (e.g. "pandoc"),
                   so tier planning (tools/builddeps) leaves them out
  revision         N in the version suffix yohaneN (default 1)
```

Each `README.md` starts with this header block:

```
Source: <source package>
Applies-To: <Devuan version(s) the patch was made against>
Kind: build-fix | build-profile | libniji-workaround | yohane-identity | drop
Libniji-Issue: duskglow/libniji#N   (libniji-workaround only)
Status: active | obsolete (and why)
```

- **build-fix:** the package doesn't build or work in Yohane for a reason unrelated to libniji (for example, a
  vendor check that only knows Debian).
- **build-profile:** no patch; the source is built with a Debian build profile it already supports (e.g. `nodoc`).
- **libniji-workaround:** a stopgap for a libniji bug. It names the issue and is dropped once libniji fixes it.
- **yohane-identity:** one of the minimal changes that make the system Yohane rather than Devuan (`base-files`).
- **drop:** the package isn't built for Yohane. The README says why (e.g. it uses `GLIBC_PRIVATE`).

A rebuilt package with a Yohane patch gets the version `<devuan-version>yohane<N>`; see docs/design.md, section 3.
