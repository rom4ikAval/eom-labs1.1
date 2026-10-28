#ifndef IO_HELPERS_H
#define IO_HELPERS_H
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/stat.h>

static inline ssize_t read_retry(int fd, void *buf, size_t size)
{
    ssize_t n;
    do {
        n = read(fd, buf, size);
    } while (n < 0 && errno == EINTR);
    return n;
}

static inline int write_all(int fd, const void *buf, size_t size)
{
    const char *p = buf;
    while (size > 0) {
        ssize_t n = write(fd, p, size);
        if (n < 0) {
            if (errno == EINTR)
                continue;
            return -1;
        }
        if (n == 0) {
            errno = EIO;
            return -1;
        }
        p += n;
        size -= (size_t)n;
    }
    return 0;
}

static inline int finish(int fd, int status)
{
    if (close(fd) == -1) {
        perror("close");
        return EXIT_FAILURE;
    }
    return status;
}

static inline int pause_input(void)
{
    fflush(stdout);
    if (getchar() == EOF) {
        fputs("Expected Enter on stdin\n", stderr);
        return -1;
    }
    return 0;
}
#endif
