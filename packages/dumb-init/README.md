# dumb-init

Yohane changes to the dumb-init source package.

## Stage 2: dropped build dependencies (python3-py)

Its test suite's python3-py is not built by Yohane, and dumb-init is built without tests (T2). The dependency is not marked <!nocheck>, so it is dropped.

Found by stage 2, whose build root holds only Yohane's archive (design section 4): stage 1 could still install these from Devuan.
