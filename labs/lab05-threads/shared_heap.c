#include "thread_check.h"

struct SharedData { int value; };

void *worker(void *arg)
{
    struct SharedData *data = arg;
    data->value += 10;
    printf("Worker: value=%d, heap address=%p\n",
           data->value, (void *)data);
    return NULL;
}

int main(void)
{
    struct SharedData *data = malloc(sizeof(*data));
    if (data == NULL) {
        perror("malloc");
        return EXIT_FAILURE;
    }

    data->value = 100;
    printf("Main before: value=%d, heap address=%p\n",
           data->value, (void *)data);

    pthread_t thread;
    CHECK(pthread_create(&thread, NULL, worker, data));
    CHECK(pthread_join(thread, NULL));

    printf("Main after: value=%d, heap address=%p\n",
           data->value, (void *)data);
    free(data);
    return EXIT_SUCCESS;
}
