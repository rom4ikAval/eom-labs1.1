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

static void redirect_to(const char *path)
{
    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0)
        die("open");
    if (dup2(fd, STDOUT_FILENO) < 0)
        die("dup2");
    if (fd != STDOUT_FILENO)
        shut(fd);
}

static int launch(char **left, char **right, const char *output)
{
    int p[2] = {-1, -1};
    if (right && pipe(p) < 0) {
        perror("pipe");
        return 1;
    }

    fflush(NULL);
    pid_t a = fork();
    if (a < 0) {
        perror("fork");
        if (right) {
            shut(p[0]);
            shut(p[1]);
        }
        return 1;
    }

    if (a == 0) {
        disposition(SIGINT, SIG_DFL);
        disposition(SIGPIPE, SIG_DFL);

        if (right) {
            if (dup2(p[1], 1) < 0)
                die("dup2");
            shut(p[0]);
            shut(p[1]);
        } else if (output) {
            redirect_to(output);
        }

        execvp(left[0], left);
        perror("execvp");
        _exit(127);
    }

    if (!right)
        return reap(a);

    pid_t b = fork();
    if (b < 0) {
        perror("fork");
        shut(p[0]);
        shut(p[1]);
        if (kill(a, SIGTERM) < 0 && errno != ESRCH)
            perror("kill");
        reap(a);
        return 1;
    }

    if (b == 0) {
        disposition(SIGINT, SIG_DFL);
        disposition(SIGPIPE, SIG_DFL);

        if (dup2(p[0], 0) < 0)
            die("dup2");
        shut(p[0]);
        shut(p[1]);

        if (output)
            redirect_to(output);

        execvp(right[0], right);
        perror("execvp");
        _exit(127);
    }

    shut(p[0]);
    shut(p[1]);

    int first = reap(a);
    int second = reap(b);
    (void)first;
    return second;
}

int main(void)
{
    char *left[] = {"ls", "-l", NULL};
    char *right[] = {"wc", "-l", NULL};
    return launch(left, right, NULL);
}
