#include "thread_check.h"
/* Intentional data race: undefined behavior in C. */
int value = 0;

void *worker(void *arg)
{
    int id = *(int *)arg;
    
    value = id * 100;
    printf("Thread %d: value=%d, address=%p\n",
           id, value, (void *)&value);

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

    printf("Main: value=%d, address=%p\n", value, (void *)&value);
    return EXIT_SUCCESS;
}
