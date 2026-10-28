#ifndef THREAD_CHECK_H
#define THREAD_CHECK_H
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static inline void check_thread(int error, const char *operation)
{
    if (error != 0) {
        fprintf(stderr, "%s: %s\n", operation, strerror(error));
        exit(EXIT_FAILURE);
    }
}
#define CHECK(call) check_thread((call), #call)
#endif
