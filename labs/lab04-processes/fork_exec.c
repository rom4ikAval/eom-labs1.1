#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>

int main(void)
{
    printf("PARENT: PID=%ld\n", (long)getpid());
    fflush(stdout);

    pid_t pid = fork();
    if (pid < 0) {
        perror("fork");
        return EXIT_FAILURE;
    }

    if (pid == 0) {
        printf("CHILD before exec: PID=%ld\n", (long)getpid());
        fflush(stdout);
        execlp("echo", "echo", "Program started by child",
               (char *)NULL);
        perror("execlp");
        _exit(EXIT_FAILURE);
    }

    printf("PARENT: created child PID=%ld\n", (long)pid);
    fflush(stdout);
    if (wait(NULL) < 0) {
        perror("wait");
        return EXIT_FAILURE;
    }

    printf("PARENT: child completed\n");
    return EXIT_SUCCESS;
}
