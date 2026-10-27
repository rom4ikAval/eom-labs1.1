#include <stdio.h>
#include <unistd.h>

int main(void)
{
    printf("Output using printf\n");
    const char message[] = "Output using write\n";
    if (write(STDOUT_FILENO, message, sizeof(message) - 1) < 0) {
        perror("write");
        return 1;
    }
    return 0;
}
