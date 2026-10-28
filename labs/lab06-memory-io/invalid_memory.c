#include <stdio.h>

int main(void)
{
    int *pointer = NULL;
    puts("About to access invalid memory");
    fflush(stdout);

    *pointer = 42; /* Intentional undefined behavior. */

    puts("You should not normally see this");
    return 0;
}
