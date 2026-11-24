Source: gdb
Applies-To: 16.3-1
Kind: bootstrap
Status: active

# gdb

## T2 trim (2026-11-24): source highlighting

**Bootstrap only (decisions 16 and 24).** Yohane builds gdb without GNU source-highlight, which colours source
listings. source-highlight is built on Boost.Regex, and Debian's Boost packaging builds Boost.MPI unconditionally,
so keeping it would put all of Boost and an MPI implementation into T2. gdb's configure detects the library and
builds without it; gdb still styles output with its own Python-free fallback.

**How:** `drop-build-deps` lists `libsource-highlight-dev`, applied by `tools/trimcontrol`.

**Restore** in the full pass, when Boost is built in full: remove that line.
