#include "thread_check.h"
#define THREAD_COUNT 4
#define ITERATIONS 500000

long counter = 0;
pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;

void *increment(void *arg)
{
    (void)arg;
    
    for (int i = 0; i < ITERATIONS; ++i) {
        CHECK(pthread_mutex_lock(&mutex));
        counter++;
        CHECK(pthread_mutex_unlock(&mutex));
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
    CHECK(pthread_mutex_destroy(&mutex));
    return EXIT_SUCCESS;
}
