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

int main(int argc, char **argv)
{
    int keep_open = !(argc == 2 && strcmp(argv[1], "--fixed") == 0);
    int p[2];
    if (pipe(p) < 0)
        die("pipe");

    printf("Before fork: read=%d write=%d\n", p[0], p[1]);
    fflush(stdout);

    pid_t child = fork();
    if (child < 0) {
        perror("fork");
        shut(p[0]);
        shut(p[1]);
        return 1;
    }

    if (child == 0) {
        if (!keep_open)
            shut(p[1]);

        send_all(1, "Child received: ", sizeof("Child received: ")-1);

        char buffer[128];
        ssize_t n;
        while ((n = receive(p[0], buffer, sizeof(buffer))) > 0)
            send_all(1, buffer, (size_t)n);

        send_all(1, "Child: EOF\n", sizeof("Child: EOF\n")-1);
        shut(p[0]);
        if (keep_open)
            shut(p[1]);
        _exit(0);
    }

    shut(p[0]);
    const char message[] = "Message from parent\n";
    send_all(p[1], message, sizeof(message)-1);
    shut(p[1]);


    if (keep_open) {
        sleep(2);

        int state;
        pid_t done = waitpid(child, &state, WNOHANG);
        if (done == -1)
            die("waitpid");

        if (done == 0) {
            puts("No EOF: child still waiting; stopping and reaping child");
            fflush(stdout);
            if (kill(child, SIGTERM) < 0)
                die("kill");
            return reap(child) == 128 + SIGTERM ? 0 : 1;
        }

        fputs("Unexpected early child exit\n", stderr);
        return 1;
    }

    int status = reap(child);

    printf("Parent: child status=%d\n", status);
    return status;
}
