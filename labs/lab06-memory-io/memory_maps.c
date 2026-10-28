#include "io_helpers.h"

int global_value = 10;

int main(void)
{
    int local = 20;
    int *dynamic = malloc(sizeof(*dynamic));
    if (!dynamic) {
        perror("malloc");
        return EXIT_FAILURE;
    }
    *dynamic = 30;

    printf("PID: %ld\n", (long)getpid());
    printf("main: %p\nglobal: %p\nheap: %p\nstack: %p\n",
           (void *)main, (void *)&global_value,
           (void *)dynamic, (void *)&local);
    puts("READY");

    int status = pause_input() == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
    free(dynamic);
    return status;
}
