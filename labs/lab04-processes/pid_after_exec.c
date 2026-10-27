#include <stdio.h>
#include <unistd.h>

int main(void)
{
    printf("New program PID=%ld\n", (long)getpid());
    return 0;
}
