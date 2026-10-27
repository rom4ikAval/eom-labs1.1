#include <stdio.h>

int sum_between(int a, int b)
{
    int start;
    int end;

    if (a <= b) {
        start = a;
        end = b;
    } else {
        start = b;
        end = a;
    }

    int result = 0;

    for (int i = start; i <= end; i++) {
        result += i;
    }

    return result;
}

int main(void)
{
    printf("sum_between(3, 6) = %d\n", sum_between(3, 6));
    printf("sum_between(6, 3) = %d\n", sum_between(6, 3));

    return 0;
}