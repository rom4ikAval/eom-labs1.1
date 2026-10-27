#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(void)
{
    printf("Before fork: PID=%ld\n", (long)getpid());
    fflush(stdout);

    pid_t pid = fork();
    if (pid < 0) {
        perror("fork");
        return EXIT_FAILURE;
    }

    if (pid == 0) {
        printf("CHILD: PID=%ld, PPID=%ld, fork returned=%ld\n",
               (long)getpid(), (long)getppid(), (long)pid);
    } else {
        printf("PARENT: PID=%ld, child PID=%ld, fork returned=%ld\n",
               (long)getpid(), (long)pid, (long)pid);
    }
    return EXIT_SUCCESS;
}
