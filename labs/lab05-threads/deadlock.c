#include "thread_check.h"
#include <unistd.h>

pthread_mutex_t mutex1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutex2 = PTHREAD_MUTEX_INITIALIZER;


void *worker1(void *arg)
{
    (void)arg;
    puts("Thread 1: locking mutex1");
    CHECK(pthread_mutex_lock(&mutex1));
    puts("Thread 1: acquired mutex1");

    sleep(1);

    puts("Thread 1: locking mutex2");
    CHECK(pthread_mutex_lock(&mutex2));
    puts("Thread 1: critical section");

    CHECK(pthread_mutex_unlock(&mutex2));
    CHECK(pthread_mutex_unlock(&mutex1));
    return NULL;
}


void *worker2(void *arg)
{
    (void)arg;
    puts("Thread 2: locking mutex2");
    CHECK(pthread_mutex_lock(&mutex2));
    puts("Thread 2: acquired mutex2");

    sleep(1);

    puts("Thread 2: locking mutex1");
    CHECK(pthread_mutex_lock(&mutex1));
    puts("Thread 2: critical section");

    CHECK(pthread_mutex_unlock(&mutex1));
    CHECK(pthread_mutex_unlock(&mutex2));
    return NULL;
}


int main(void)
{
    setvbuf(stdout, NULL, _IONBF, 0);
    pthread_t thread1, thread2;

    CHECK(pthread_create(&thread1, NULL, worker1, NULL));
    CHECK(pthread_create(&thread2, NULL, worker2, NULL));
    CHECK(pthread_join(thread1, NULL));
    CHECK(pthread_join(thread2, NULL));

    CHECK(pthread_mutex_destroy(&mutex1));
    CHECK(pthread_mutex_destroy(&mutex2));
    puts("Main: both workers finished");
    return EXIT_SUCCESS;
}
