#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    if (argc != 2) {
        fprintf(stderr, "Usage: %s PROGRAM\n", argv[0]);
        return EXIT_FAILURE;
    }

    printf("Parent PID: %ld\nCreating child...\n", (long)getpid());
    fflush(stdout);

    pid_t pid = fork();
    if (pid < 0) {
        perror("fork");
        return EXIT_FAILURE;
    }

    if (pid == 0) {
        printf("Child PID: %ld\nChild PPID: %ld\nExecuting: %s\n",
               (long)getpid(), (long)getppid(), argv[1]);
        fflush(stdout);
        execlp(argv[1], argv[1], (char *)NULL);
        perror("exec");
        _exit(127);
    }

    printf("Parent: created child PID=%ld\n", (long)pid);
    fflush(stdout);

    int status;
    pid_t result;
    do {
        result = waitpid(pid, &status, 0);
    } while (result < 0 && errno == EINTR);

    if (result < 0) {
        perror("waitpid");
        return EXIT_FAILURE;
    }

    printf("Child %ld completed\n", (long)result);

    int exit_code = EXIT_FAILURE;
    if (WIFEXITED(status)) {
        exit_code = WEXITSTATUS(status);
        printf("Exit status: %d\n", exit_code);
    } else if (WIFSIGNALED(status)) {
        printf("Terminated by signal: %d\n", WTERMSIG(status));
    }

    printf("Parent continues\n");
    return exit_code;
}
