#include "thread_check.h"


void *worker(void *arg)
{
    int id = *(int *)arg;
    
    int local = id * 10;
    printf("Thread %d: local=%d, address=%p\n",
           id, local, (void *)&local);

    return NULL;
}

int main(void)
{
    enum { THREAD_COUNT = 2 };
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
