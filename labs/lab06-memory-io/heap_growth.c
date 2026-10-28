#include "io_helpers.h"

int main(void)
{
    const size_t size = 100u * 1024u * 1024u;
    long page = sysconf(_SC_PAGESIZE);
    if (page <= 0)
        return EXIT_FAILURE;

    volatile unsigned char *memory = malloc(size);
    if (!memory) {
        perror("malloc");
        return EXIT_FAILURE;
    }

    printf("PID: %ld\nAllocated: %zu bytes\nAddress: %p\nPage size: %ld\n",
           (long)getpid(), size, (void *)memory, page);

    puts("BEFORE_TOUCH: press Enter");
    if (pause_input() < 0) {
        free((void *)memory);
        return EXIT_FAILURE;
    }

    for (size_t i = 0; i < size; i += (size_t)page)
        memory[i] = 1;
    memory[size - 1] = 1;

    puts("AFTER_TOUCH: press Enter");
    int status = pause_input() == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
    free((void *)memory);
    return status;
}
