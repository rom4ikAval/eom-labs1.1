#include <stdio.h>
#include <unistd.h>

int main(void)
{
    printf("PID=%ld\n", (long)getpid());
    fflush(stdout);
    sleep(60);
    return 0;
}
