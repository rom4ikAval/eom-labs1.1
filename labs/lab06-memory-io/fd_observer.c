#include "io_helpers.h"

int main(void)
{
    printf("PID: %ld\n", (long)getpid());
    puts("READY");
    return pause_input() == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}
