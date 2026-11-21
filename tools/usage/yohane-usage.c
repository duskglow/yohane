/* yohane-usage: per-process usage logger for Yohane's tool inventory pass (stage1u).
 *
 * Loaded into every process through /etc/ld.so.preload in the stage1u build chroot only.
 * When a process ends (exit(), return from main, _exit() or _Exit()), it appends one line
 *     <executable path> <user µs> <system µs> <max RSS KiB>
 * to /var/tmp/yohane-usage.log with a single O_APPEND write, so concurrent writers don't interleave.
 * The log is opened only at exit, so the process never holds an extra descriptor while it runs
 * (tests that check which descriptors are open see nothing). Processes killed by a signal are not
 * counted. Usage carries across execve, so time before an exec is counted under the final program.
 */
#define _GNU_SOURCE
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/resource.h>
#include <sys/syscall.h>
#include <unistd.h>

#define LOG "/var/tmp/yohane-usage.log"

static int done;

static void record(void)
{
    if (done) return;
    done = 1;
    char exe[512];
    ssize_t n = readlink("/proc/self/exe", exe, sizeof exe - 1);
    if (n <= 0) return;
    exe[n] = 0;
    for (char *p = exe; *p; p++) if (*p == ' ' || *p == '\n') *p = '_';
    struct rusage ru;
    if (getrusage(RUSAGE_SELF, &ru) != 0) return;
    char line[640];
    int len = snprintf(line, sizeof line, "%s %ld %ld %ld\n", exe,
                       (long)ru.ru_utime.tv_sec * 1000000L + ru.ru_utime.tv_usec,
                       (long)ru.ru_stime.tv_sec * 1000000L + ru.ru_stime.tv_usec,
                       ru.ru_maxrss);
    if (len <= 0 || len >= (int)sizeof line) return;
    int fd = open(LOG, O_WRONLY | O_APPEND | O_CLOEXEC);
    if (fd < 0) return;
    ssize_t w = write(fd, line, len);
    (void)w;
    close(fd);
}

__attribute__((destructor)) static void at_exit(void) { record(); }

/* dash and others end with _exit(), which runs no destructors. */
void _exit(int status)
{
    record();
    syscall(SYS_exit_group, status);
    for (;;) ;
}

void _Exit(int status) { _exit(status); }
