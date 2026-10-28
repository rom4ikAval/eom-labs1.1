#include "thread_check.h"
#define THREAD_COUNT 2
#define ITERATIONS 1000000

long counter = 0;
/* Intentional data race: undefined behavior in C. */

void *increment(void *arg)
{
    (void)arg;
    
    for (int i = 0; i < ITERATIONS; ++i) {
        
        counter++;
        
    }
    
    return NULL;
}

int main(void)
{
    pthread_t threads[THREAD_COUNT];
    for (int i = 0; i < THREAD_COUNT; ++i)
        CHECK(pthread_create(&threads[i], NULL, increment, NULL));
    for (int i = 0; i < THREAD_COUNT; ++i)
        CHECK(pthread_join(threads[i], NULL));

    printf("Threads=%d Iterations=%d Expected=%ld Actual=%ld\n",
           THREAD_COUNT, ITERATIONS,
           (long)THREAD_COUNT * ITERATIONS, counter);
    
    return EXIT_SUCCESS;
}
