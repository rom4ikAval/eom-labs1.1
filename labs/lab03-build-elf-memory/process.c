#include <stdio.h>
#include <unistd.h>

int main(void)
{
    printf("PID: %ld\n", (long)getpid());
    printf("Process is running...\n");
    fflush(stdout);
    sleep(60);
    return 0;
}
