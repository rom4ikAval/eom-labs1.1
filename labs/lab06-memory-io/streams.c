#include "io_helpers.h"

int main(void)
{
    const char out[] = "Normal output\n";
    const char err[] = "Error output\n";

    if (write_all(1, out, sizeof(out) - 1) < 0 ||
        write_all(2, err, sizeof(err) - 1) < 0) {
        perror("write");
        return EXIT_FAILURE;
    }
    return EXIT_SUCCESS;
}
