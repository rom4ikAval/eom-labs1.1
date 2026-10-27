#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    printf("Before exec: PID=%ld\n", (long)getpid());
    fflush(stdout);

    if (argc == 2) {
        execl(argv[1], argv[1], (char *)NULL);
    } else {
        execlp("echo", "echo", "Hello from exec!", (char *)NULL);
    }

    perror("exec");
    return EXIT_FAILURE;
}
