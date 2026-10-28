#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

static inline void die(const char *s)
{
    perror(s);
    _exit(1);
}

static inline void shut(int fd)
{
    if (close(fd) < 0)
        die("close");
}

static inline void send_all(int fd, const char *s, size_t size)
{
    while (size) {
        ssize_t n = write(fd, s, size);
        if (n < 0 && errno == EINTR)
            continue;
        if (n <= 0) {
            if (n == 0) errno = EIO;
            die("write");
        }
        s += n;
        size -= (size_t)n;
    }
}

static inline ssize_t receive(int fd, char *s, size_t size)
{
    ssize_t n;
    do {
        n = read(fd, s, size);
    } while (n < 0 && errno == EINTR);
    if (n < 0)
        die("read");
    return n;
}

static inline int reap(pid_t pid)
{
    int status;
    pid_t result;
    do {
        result = waitpid(pid, &status, 0);
    } while (result < 0 && errno == EINTR);

    if (result < 0) {
        perror("waitpid");
        return 1;
    }
    if (WIFSIGNALED(status)) {
        fprintf(stderr, "Child signal=%d\n", WTERMSIG(status));
        return 128 + WTERMSIG(status);
    }
    return WIFEXITED(status) ? WEXITSTATUS(status) : 1;
}

static inline void disposition(int sig, void (*handler)(int))
{
    struct sigaction a = {0};
    a.sa_handler = handler;
    sigemptyset(&a.sa_mask);
    if (sigaction(sig, &a, NULL) < 0)
        die("sigaction");
}

int main(void)
{
    int fd = open("redirected.txt", O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0)
        die("open");
    if (dup2(fd, 1) < 0)
        die("dup2");
    if (fd != 1)
        shut(fd);

    if (printf("This goes to the file\n") < 0 || fflush(stdout) == EOF)
        die("stdout");

    shut(1);
    return 0;
}
