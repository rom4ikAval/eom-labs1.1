#include "thread_check.h"

#define N 1000000LL
#define THREAD_COUNT 4

struct Task {
    long long start;
    long long end;
    long long result;
};

void *calculate_sum(void *arg)
{
    struct Task *task = arg;
    long long local_sum = 0;

    for (long long i = task->start; i <= task->end; ++i)
        local_sum += i;

    task->result = local_sum;
    return NULL;
}

int main(void)
{
    pthread_t threads[THREAD_COUNT];
    struct Task tasks[THREAD_COUNT];

    /* Fixed range 1..1000000: indices and sums fit in long long. */
    for (int i = 0; i < THREAD_COUNT; ++i) {
        tasks[i].start = N * i / THREAD_COUNT + 1;
        tasks[i].end = N * (i + 1) / THREAD_COUNT;
        tasks[i].result = 0;
        CHECK(pthread_create(&threads[i], NULL,
                             calculate_sum, &tasks[i]));
    }

    long long total = 0;
    for (int i = 0; i < THREAD_COUNT; ++i) {
        CHECK(pthread_join(threads[i], NULL));
        printf("Thread %d: [%lld..%lld] sum=%lld\n",
               i + 1, tasks[i].start, tasks[i].end, tasks[i].result);
        total += tasks[i].result;
    }

    const long long expected = N * (N + 1) / 2;
    printf("Parallel result: %lld\nExpected result: %lld\nCorrect: %s\n",
           total, expected, total == expected ? "YES" : "NO");

    return total == expected ? EXIT_SUCCESS : EXIT_FAILURE;
}
