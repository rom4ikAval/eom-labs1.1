#include <stdio.h>
#include <stdlib.h>

#define N 1000000LL

int main(void)
{
    long long total = 0;
    for (long long i = 1; i <= N; ++i)
        total += i;

    const long long expected = N * (N + 1) / 2;
    printf("Sequential result: %lld\nExpected result: %lld\nCorrect: %s\n",
           total, expected, total == expected ? "YES" : "NO");

    return total == expected ? EXIT_SUCCESS : EXIT_FAILURE;
}
