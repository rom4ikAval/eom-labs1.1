#include "io_helpers.h"

int main(void)
{
    const char message[] = "Hello from write()\n";
    int fd = open("output.txt", O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) {
        perror("open");
        return EXIT_FAILURE;
    }

    if (write_all(fd, message, sizeof(message) - 1) < 0) {
        perror("write");
        return finish(fd, EXIT_FAILURE);
    }

    printf("Requested: %zu bytes\nWritten in total: %zu bytes\n",
           sizeof(message) - 1, sizeof(message) - 1);
    return finish(fd, EXIT_SUCCESS);
}
