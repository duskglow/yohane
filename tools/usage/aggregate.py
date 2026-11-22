"""Aggregate the stage1u usage pass.

    python3 -I aggregate.py LOGDIR OUTDIR [PKGMAP]

Reads every LOGDIR/*.log.zst (the stage1u build logs), takes the YOHANE-USAGE lines
(format v2: path procs user_us sys_us maxrss n10 cpu10 n1 cpu1), and writes:
  OUTDIR/per-program.tsv   one row per executable, all columns, sorted by CPU
  OUTDIR/per-source.tsv    source, program, procs, cpu_us (for "which packages use it most")
  OUTDIR/summary.md        whole-build totals and the top tables
  OUTDIR/paths.txt         every executable path (for mapping to binary packages)
PKGMAP (optional): "path<TAB>package" lines; adds a package column and per-package totals.
Logs still in format v1 (no short-process columns) are listed and left out.
"""
import collections, glob, os, re, subprocess, sys

logdir, outdir = sys.argv[1], sys.argv[2]
pkgmap = {}
if len(sys.argv) > 3:
    for line in open(sys.argv[3]):
        p, _, pkg = line.rstrip("\n").partition("\t")
        pkgmap[p] = pkg or "?"
os.makedirs(outdir, exist_ok=True)

prog = collections.defaultdict(lambda: [0] * 8)   # procs user sys maxrss n10 c10 n1 c1
users = collections.defaultdict(collections.Counter)  # path -> source -> cpu
users_n = collections.defaultdict(collections.Counter)
srcrows, oldfmt, nousage, sources = [], [], [], []

for f in sorted(glob.glob(os.path.join(logdir, "*.log.zst"))):
    base = os.path.basename(f)
    if base.endswith((".check.log.zst", ".gate.log.zst", ".prep.log.zst")):
        continue
    src = re.sub(r"_[^_]*\.log\.zst$", "", base)
    text = subprocess.run(["zstdcat", f], capture_output=True, text=True, errors="replace").stdout
    # Only the first report block: a failed build reports from sbuild's build-failed hook, and the
    # cleanup hook might report again.
    block = text.split("YOHANE-USAGE-END", 1)[0]
    lines = [l.split() for l in block.splitlines() if l.startswith("YOHANE-USAGE ")]
    if not lines:
        nousage.append(src); continue
    if any(len(l) != 10 for l in lines):
        oldfmt.append(src); continue
    sources.append(src)
    for l in lines:
        path = l[1]; v = list(map(int, l[2:]))
        # Programs a package builds and runs from its own build tree (its test suite, mostly) are
        # one category per source, not tens of thousands of paths.
        if path.startswith("/<<PKGBUILDDIR>>/"):
            path = "[built in tree: " + src + "]"
        a = prog[path]
        a[0] += v[0]; a[1] += v[1]; a[2] += v[2]; a[3] = max(a[3], v[3])
        a[4] += v[4]; a[5] += v[5]; a[6] += v[6]; a[7] += v[7]
        cpu = v[1] + v[2]
        users[path][src] += cpu; users_n[path][src] += v[0]
        srcrows.append((src, path, v[0], cpu))

def cpu(a): return a[1] + a[2]
tot_procs = sum(a[0] for a in prog.values()); tot_cpu = sum(cpu(a) for a in prog.values())
tot_n10 = sum(a[4] for a in prog.values()); tot_c10 = sum(a[5] for a in prog.values())
tot_n1 = sum(a[6] for a in prog.values()); tot_c1 = sum(a[7] for a in prog.values())
order = sorted(prog, key=lambda p: -cpu(prog[p]))

with open(os.path.join(outdir, "paths.txt"), "w") as o:
    o.write("\n".join(sorted(prog)) + "\n")
with open(os.path.join(outdir, "per-program.tsv"), "w") as o:
    o.write("program\tpackage\tprocs\tsources\tcpu_s\tcpu_share\tuser_s\tsys_s\tmaxrss_kib\tprocs_lt10ms\tcpu_lt10ms_s\tprocs_lt1ms\tcpu_lt1ms_s\ttop_sources_by_cpu\n")
    for p in order:
        a = prog[p]
        top = ",".join(s for s, _ in users[p].most_common(3))
        o.write(f"{p}\t{pkgmap.get(p, '')}\t{a[0]}\t{len(users[p])}\t{cpu(a)/1e6:.2f}\t{cpu(a)/tot_cpu:.5f}\t{a[1]/1e6:.2f}\t{a[2]/1e6:.2f}\t{a[3]}\t{a[4]}\t{a[5]/1e6:.2f}\t{a[6]}\t{a[7]/1e6:.2f}\t{top}\n")
with open(os.path.join(outdir, "per-source.tsv"), "w") as o:
    o.write("source\tprogram\tprocs\tcpu_us\n")
    for r in sorted(srcrows):
        o.write("\t".join(map(str, r)) + "\n")

def pct(x, y): return f"{100*x/y:.1f}%" if y else "-"
def h(s): return f"{s/1e6/3600:.1f} h" if s >= 36e8 else f"{s/1e6:.0f} s"
md = []
md.append(f"Sources aggregated: {len(sources)}. Old-format logs left out: {len(oldfmt)} ({' '.join(oldfmt) or 'none'}). "
          f"No usage lines: {len(nousage)} ({' '.join(nousage) or 'none'}).\n")
md.append("## Whole pass\n")
md.append("| | processes | CPU (user + system) |\n|---|---|---|")
md.append(f"| all | {tot_procs:,} | {h(tot_cpu)} |")
md.append(f"| under 10 ms CPU each | {tot_n10:,} ({pct(tot_n10, tot_procs)}) | {h(tot_c10)} ({pct(tot_c10, tot_cpu)}) |")
md.append(f"| under 1 ms CPU each | {tot_n1:,} ({pct(tot_n1, tot_procs)}) | {h(tot_c1)} ({pct(tot_c1, tot_cpu)}) |\n")
if pkgmap:
    pk = collections.defaultdict(lambda: [0, 0, 0, 0, set()])
    for p, a in prog.items():
        k = pkgmap.get(p, "?"); b = pk[k]
        b[0] += a[0]; b[1] += cpu(a); b[2] += a[4]; b[3] += a[5]; b[4].add(os.path.basename(p))
    md.append("## By binary package (top 30 by CPU)\n")
    md.append("| package | processes | CPU | share | procs < 10 ms | their CPU | programs |\n|---|---|---|---|---|---|---|")
    for k in sorted(pk, key=lambda k: -pk[k][1])[:30]:
        b = pk[k]; progs = ", ".join(sorted(b[4])[:6]) + (" ..." if len(b[4]) > 6 else "")
        md.append(f"| {k} | {b[0]:,} | {h(b[1])} | {pct(b[1], tot_cpu)} | {pct(b[2], b[0])} | {pct(b[3], b[1])} | {progs} |")
    md.append("")
md.append("## Programs, top 40 by CPU\n")
md.append("| program | package | processes | sources | CPU | share | procs < 10 ms | their CPU | most CPU in |\n|---|---|---|---|---|---|---|---|---|")
for p in order[:40]:
    a = prog[p]
    md.append(f"| `{p}` | {pkgmap.get(p, '')} | {a[0]:,} | {len(users[p])} | {h(cpu(a))} | {pct(cpu(a), tot_cpu)} | {pct(a[4], a[0])} | {pct(a[5], cpu(a))} | {', '.join(s for s, _ in users[p].most_common(3))} |")
md.append("\n## Programs, top 40 by process count\n")
md.append("| program | package | processes | sources | CPU | procs < 10 ms | procs < 1 ms | most processes in |\n|---|---|---|---|---|---|---|---|")
for p in sorted(prog, key=lambda p: -prog[p][0])[:40]:
    a = prog[p]
    md.append(f"| `{p}` | {pkgmap.get(p, '')} | {a[0]:,} | {len(users[p])} | {h(cpu(a))} | {pct(a[4], a[0])} | {pct(a[6], a[0])} | {', '.join(s for s, _ in users_n[p].most_common(3))} |")
open(os.path.join(outdir, "summary.md"), "w").write("\n".join(md) + "\n")
print(f"{len(sources)} sources, {len(prog)} programs, {tot_procs:,} processes, {tot_cpu/1e6/3600:.1f} CPU-hours; "
      f"<10ms: {pct(tot_n10, tot_procs)} of processes, {pct(tot_c10, tot_cpu)} of CPU; old format: {len(oldfmt)}; none: {len(nousage)}")
