#include "io_helpers.h"

int main(void)
{
    if (printf("A") < 0 || printf("B") < 0 || printf("C") < 0)
        return EXIT_FAILURE;

    /* Intentionally mix stdio and descriptor I/O without fflush. */

    if (write_all(1, "D", 1) < 0) {
        perror("write");
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
