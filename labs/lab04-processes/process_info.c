#include <stdio.h>
#include <unistd.h>

int main(void)
{
    printf("PID: %ld\nPPID: %ld\n",
           (long)getpid(), (long)getppid());
    fflush(stdout);
    sleep(30);
    return 0;
}
