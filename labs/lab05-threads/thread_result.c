#include "thread_check.h"

void *calculate(void *arg)
{
    const int value = *(int *)arg;
    long long *result = malloc(sizeof(*result));
    if (result == NULL)
        return NULL;

    /* Convert before multiplication; input in this experiment is 12. */
    *result = (long long)value * value;
    return result;
}

int main(void)
{
    int value = 12;
    pthread_t thread;
    void *returned = NULL;

    CHECK(pthread_create(&thread, NULL, calculate, &value));
    CHECK(pthread_join(thread, &returned));

    if (returned == NULL) {
        fputs("Worker failed to allocate the result\n", stderr);
        return EXIT_FAILURE;
    }

    long long *result = returned;
    printf("Input=%d Result=%lld\n", value, *result);
    free(result);
    return EXIT_SUCCESS;
}
