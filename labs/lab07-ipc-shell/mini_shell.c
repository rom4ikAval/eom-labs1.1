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

#define LINE_SIZE 1024
#define MAX_TOKENS 128

static int builtin(const char *s)
{
    return strcmp(s, "cd") == 0 || strcmp(s, "exit") == 0;
}

int main(void)
{
    disposition(SIGINT, SIG_IGN);

    /* No job control: shell and commands share the foreground group. */
    char line[LINE_SIZE];
    int interactive = isatty(0);

    while (1) {
        if (interactive) {
            printf("myshell> ");
            fflush(stdout);
        }

        if (!fgets(line, sizeof(line), stdin)) {
            if (ferror(stdin))
                perror("fgets");
            break;
        }

        if (!strchr(line, '\n') && !feof(stdin)) {
            int c;
            while ((c = getchar()) != '\n' && c != EOF) {}
            fputs("Input too long\n", stderr);
            continue;
        }

        if (strpbrk(line, "\"'`$*?&;<\\")) {
            fputs("Unsupported syntax\n", stderr);
            continue;
        }

        char expanded[LINE_SIZE * 3];
        size_t j = 0;
        for (size_t i = 0; line[i]; ++i) {
            if (line[i] == '|' || line[i] == '>') {
                expanded[j++] = ' ';
                expanded[j++] = line[i];
                expanded[j++] = ' ';
            } else {
                expanded[j++] = line[i];
            }
        }
        expanded[j] = '\0';

        char *args[MAX_TOKENS + 1];
        int n = 0, overflow = 0;
        char *state;

        for (char *t = strtok_r(expanded, " \t\r\n", &state);
             t; t = strtok_r(NULL, " \t\r\n", &state)) {
            if (n == MAX_TOKENS) {
                overflow = 1;
                break;
            }
            args[n++] = t;
        }

        if (overflow) {
            fputs("Too many tokens\n", stderr);
            continue;
        }
        args[n] = NULL;
        if (!n)
            continue;

        int pipe_at = -1, out_at = -1, bad = 0;
        for (int i = 0; i < n; ++i) {
            if (!strcmp(args[i], "|")) {
                if (pipe_at >= 0)
                    bad = 1;
                pipe_at = i;
            }
            if (!strcmp(args[i], ">")) {
                if (out_at >= 0)
                    bad = 1;
                out_at = i;
            }
        }

        if (out_at >= 0 && (out_at == 0 || out_at != n-2))
            bad = 1;

        int command_end = out_at >= 0 ? out_at : n;
        if (pipe_at >= 0 &&
            (pipe_at == 0 || pipe_at >= command_end-1))
            bad = 1;

        if (bad) {
            fputs("Syntax error: one pipe and optional final > file\n", stderr);
            continue;
        }

        const char *output = out_at >= 0 ? args[out_at+1] : NULL;
        if (out_at >= 0)
            args[out_at] = NULL;

        char **right = NULL;
        if (pipe_at >= 0) {
            args[pipe_at] = NULL;
            right = &args[pipe_at+1];
        }

        if (builtin(args[0]) || (right && builtin(right[0]))) {
            if (right || output) {
                fputs("Built-ins do not support pipes/redirection\n", stderr);
                continue;
            }

            if (!strcmp(args[0], "exit")) {
                if (n != 1) {
                    fputs("Usage: exit\n", stderr);
                    continue;
                }
                break;
            }

            if (n != 2) {
                fputs("Usage: cd directory\n", stderr);
                continue;
            }
            if (chdir(args[1]) < 0)
                perror("chdir");
            continue;
        }

        launch(args, right, output);
    }
    return 0;
}
