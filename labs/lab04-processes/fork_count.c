#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    int count = 2;
    if (argc == 2 && strcmp(argv[1], "3") == 0) {
        count = 3;
    } else if (argc > 1 &&
               !(argc == 2 && strcmp(argv[1], "2") == 0)) {
        fprintf(stderr, "Usage: %s [2|3]\n", argv[0]);
        return EXIT_FAILURE;
    }

    for (int i = 0; i < count; ++i) {
        if (fork() < 0) {
            perror("fork");
            return EXIT_FAILURE;
        }
    }

    printf("PID=%ld PPID=%ld\n",
           (long)getpid(), (long)getppid());
    fflush(stdout);

    for (;;) {
        if (wait(NULL) >= 0) {
            continue;
        }
        if (errno == EINTR) {
            continue;
        }
        if (errno != ECHILD) {
            perror("wait");
            return EXIT_FAILURE;
        }
        break;
    }
    return EXIT_SUCCESS;
}
