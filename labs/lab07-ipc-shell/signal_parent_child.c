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

static volatile sig_atomic_t terminated = 0;

static void handle_term(int number)
{
    (void)number;
    int saved = errno;
    const char message[] = "Child handler: SIGTERM received\n";
    terminated = 1;
    (void)write(1, message, sizeof(message)-1);
    errno = saved;
}

int main(int argc, char **argv)
{
    int custom = argc == 2 && strcmp(argv[1], "--handled") == 0;

    sigset_t blocked, old;
    sigemptyset(&blocked);
    sigaddset(&blocked, SIGTERM);
    if (sigprocmask(SIG_BLOCK, &blocked, &old) < 0)
        die("sigprocmask");

    pid_t child = fork();
    if (child < 0)
        die("fork");

    if (child == 0) {
        disposition(SIGTERM, custom ? handle_term : SIG_DFL);

        sigset_t waiting = old;
        sigdelset(&waiting, SIGTERM);

        printf("Child ready; handler=%s\n", custom ? "custom" : "default");
        fflush(stdout);

        while (!terminated)
            sigsuspend(&waiting);

        send_all(1, "Child: normal exit after handler\n",
                 sizeof("Child: normal exit after handler\n")-1);
        _exit(0);
    }

    if (sigprocmask(SIG_SETMASK, &old, NULL) < 0)
        die("sigprocmask");

    sleep(1);
    printf("Parent: sending SIGTERM to %ld\n", (long)child);
    fflush(stdout);

    if (kill(child, SIGTERM) < 0) {
        perror("kill");
        reap(child);
        return 1;
    }

    int status = reap(child);
    printf("Parent: child status=%d\n", status);

    return status == (custom ? 0 : 128 + SIGTERM) ? 0 : 1;
}
