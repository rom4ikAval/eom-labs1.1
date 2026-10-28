#include "io_helpers.h"

int main(void)
{
    char buffer[16];
    int fd = open("input.txt", O_RDONLY);
    if (fd < 0) {
        perror("open");
        return EXIT_FAILURE;
    }

    ssize_t n;
    while ((n = read_retry(fd, buffer, sizeof(buffer))) > 0) {
        if (write_all(STDOUT_FILENO, buffer, (size_t)n) < 0) {
            perror("write");
            return finish(fd, EXIT_FAILURE);
        }
    }

    if (n < 0) {
        perror("read");
        return finish(fd, EXIT_FAILURE);
    }
    return finish(fd, EXIT_SUCCESS);
}
