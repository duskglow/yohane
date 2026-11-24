Source: cython
Applies-To: 3.0.11+dfsg-2
Kind: build-fix
Status: 0001 active

# cython

## 0001: python3-setuptools is needed to build, not only to test (2026-11-24)

**Problem.** Debian's `debian/control` lists `python3-setuptools <!nocheck>`, as if only the tests needed it. But
`setup.py` imports setuptools (falling back to distutils, which Python 3.12 removed) for every step, even
`setup.py clean`. So any build with the `nocheck` profile fails at its very first step: "No module named
'setuptools'". Seen in Yohane's T2 build, which uses nocheck (decision 15). Debian's own builds never use nocheck
for cython, so they don't hit it.

**Change.** `0001-setuptools-is-a-build-dependency.patch` drops the `<!nocheck>` restriction.

A genuine packaging bug, but small and only visible with nocheck, so not sent (package patch policy). It's harmless
in every build, so it can stay.
