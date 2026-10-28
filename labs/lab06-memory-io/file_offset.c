#include "io_helpers.h"

int main(void)
{
    char buffer[6];
    int fd = open("input.txt", O_RDONLY);
    if (fd < 0) {
        perror("open");
        return EXIT_FAILURE;
    }

    for (int i = 0; i < 2; ++i) {
        /* Continue from current offset. */
        ssize_t n = read_retry(fd, buffer, 5);
        if (n < 0) {
            perror("read");
            return finish(fd, EXIT_FAILURE);
        }

        buffer[n] = '\0';
        off_t offset = lseek(fd, 0, SEEK_CUR);
        if (offset == (off_t)-1) {
            perror("lseek");
            return finish(fd, EXIT_FAILURE);
        }

        printf("Read %d: [%s], bytes=%zd, offset=%lld\n",
               i + 1, buffer, n, (long long)offset);
    }
    return finish(fd, EXIT_SUCCESS);
}
