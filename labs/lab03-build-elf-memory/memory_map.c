#include <stdio.h>
#include <stdlib.h>

int global_initialized = 10;
int global_uninitialized;
static int static_initialized = 20;
static int static_uninitialized;

void example_function(void)
{
}

int main(void)
{
    int local = 30;
    const char *literal = "Computer Systems";
    int *dynamic = malloc(sizeof(int));

    if (dynamic == NULL) {
        return 1;
    }
    *dynamic = 40;

    printf("Code/function:        %p\n", (void *)example_function);
    printf("Global initialized:   %p\n", (void *)&global_initialized);
    printf("Global uninitialized: %p\n", (void *)&global_uninitialized);
    printf("Static initialized:   %p\n", (void *)&static_initialized);
    printf("Static uninitialized: %p\n", (void *)&static_uninitialized);
    printf("String literal:       %p\n", (void *)literal);
    printf("Heap allocation:      %p\n", (void *)dynamic);
    printf("Stack/local:          %p\n", (void *)&local);

    free(dynamic);
    return 0;
}
