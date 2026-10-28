#include "io_helpers.h"
#define BUFFER_SIZE 4096

int main(int argc, char *argv[])
{
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <source> <destination>\n", argv[0]);
        return EXIT_FAILURE;
    }

    int source = open(argv[1], O_RDONLY);
    if (source < 0) {
        perror("open source");
        return EXIT_FAILURE;
    }

    /* Do not truncate until we have excluded the same inode. */
    int destination = open(argv[2], O_WRONLY | O_CREAT, 0644);
    if (destination < 0) {
        perror("open destination");
        return finish(source, EXIT_FAILURE);
    }

    int status = EXIT_FAILURE;
    struct stat src, dst;

    if (fstat(source, &src) < 0 || fstat(destination, &dst) < 0) {
        perror("fstat");
        goto cleanup;
    }

    if (src.st_dev == dst.st_dev && src.st_ino == dst.st_ino) {
        fputs("Source and destination are the same file\n", stderr);
        goto cleanup;
    }

    if (S_ISREG(dst.st_mode) && ftruncate(destination, 0) < 0) {
        perror("ftruncate");
        goto cleanup;
    }

    char buffer[BUFFER_SIZE];
    ssize_t n;

    while ((n = read_retry(source, buffer, sizeof(buffer))) > 0) {
        if (write_all(destination, buffer, (size_t)n) < 0) {
            perror("write");
            goto cleanup;
        }
    }

    if (n < 0) {
        perror("read");
        goto cleanup;
    }

    status = EXIT_SUCCESS;

cleanup:
    status = finish(destination, status);
    return finish(source, status);
}
