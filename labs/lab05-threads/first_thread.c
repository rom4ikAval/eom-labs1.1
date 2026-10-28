#include "thread_check.h"

void *worker(void *arg)
{
    (void)arg;
    puts("Hello from worker thread!");
    return NULL;
}

int main(void)
{
    pthread_t thread;
    puts("Main: creating thread");
    CHECK(pthread_create(&thread, NULL, worker, NULL));
    CHECK(pthread_join(thread, NULL));
    puts("Main: worker finished");
    return EXIT_SUCCESS;
}
