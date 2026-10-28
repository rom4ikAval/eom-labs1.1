#include "io_helpers.h"

int main(void)
{
    printf("STDIN=%d\nSTDOUT=%d\nSTDERR=%d\n",
           STDIN_FILENO, STDOUT_FILENO, STDERR_FILENO);
    return 0;
}
