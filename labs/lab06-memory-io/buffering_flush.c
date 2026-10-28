#include "io_helpers.h"

int main(void)
{
    if (printf("A") < 0 || printf("B") < 0 || printf("C") < 0)
        return EXIT_FAILURE;

    
    if (fflush(stdout) == EOF) {
        perror("fflush");
        return EXIT_FAILURE;
    }


    if (write_all(1, "D", 1) < 0) {
        perror("write");
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
