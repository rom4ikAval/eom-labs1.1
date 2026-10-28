#include "thread_check.h"


void *worker(void *arg)
{
    int id = *(int *)arg;
    printf("Thread %d is running\n", id);
    return NULL;
}

int main(void)
{
    enum { THREAD_COUNT = 4 };
    pthread_t threads[THREAD_COUNT];
    int ids[THREAD_COUNT];

    for (int i = 0; i < THREAD_COUNT; ++i) {
        ids[i] = i + 1;
        CHECK(pthread_create(&threads[i], NULL, worker, &ids[i]));
    }
    for (int i = 0; i < THREAD_COUNT; ++i)
        CHECK(pthread_join(threads[i], NULL));

    
    return EXIT_SUCCESS;
}
