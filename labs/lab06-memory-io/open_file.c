#include "io_helpers.h"

int main(void)
{
    int fd = open("example.txt", O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) {
        perror("open");
        return EXIT_FAILURE;
    }

    printf("PID: %ld\nOpened file descriptor: %d\n", (long)getpid(), fd);
    puts("READY");

    return finish(fd, pause_input() == 0 ? EXIT_SUCCESS : EXIT_FAILURE);
}
