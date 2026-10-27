#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    (void)argv;
    int immediate_wait = argc > 1;

    pid_t pid = fork();
    if (pid < 0) {
        perror("fork");
        return EXIT_FAILURE;
    }

    if (pid == 0) {
        printf("CHILD: PID=%ld, exiting now\n", (long)getpid());
        fflush(stdout);
        _exit(0);
    }

    printf("PARENT: PID=%ld, child=%ld\n",
           (long)getpid(), (long)pid);
    fflush(stdout);

    if (immediate_wait) {
        if (waitpid(pid, NULL, 0) < 0) {
            perror("waitpid");
            return EXIT_FAILURE;
        }
        printf("PARENT: child reaped; sleeping 5 seconds\n");
        fflush(stdout);
        sleep(5);
    } else {
        printf("PARENT: sleeping 5 seconds without wait\n");
        fflush(stdout);
        sleep(5);
        if (waitpid(pid, NULL, 0) < 0) {
            perror("waitpid");
            return EXIT_FAILURE;
        }
        printf("PARENT: child reaped after observation\n");
    }
    return EXIT_SUCCESS;
}
