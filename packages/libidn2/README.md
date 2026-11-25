Source: libidn2
Applies-To: excalibur
Kind: none
Status: retired

# libidn2

**No changes.** Yohane builds libidn2 as Devuan ships it.

**History:** during the bootstrap (decision 16) this list dropped `git`, which gnulib's
clone step uses, to keep git and through it Go out of the minimal bootstrap set. The patch
that would have replaced the clone was never needed: stage 1 built libidn2 with git, and git
is now built by Yohane. From the indep stage on, the drop took effect without that patch and
`dh_gnulib_clone` failed ("git: No such file or directory"), so the drop was removed.
