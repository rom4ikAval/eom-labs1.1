#include "io_helpers.h"

int main(void)
{
    long size = sysconf(_SC_PAGESIZE);
    if (size <= 0) {
        fputs("Cannot get page size\n", stderr);
        return EXIT_FAILURE;
    }
    printf("Page size: %ld bytes\n", size);
    return EXIT_SUCCESS;
}
