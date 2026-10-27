#include <stdio.h>

int main(void)
{
    unsigned int values[] = {10, 65, 127, 255, 256, 1024};

    printf("Decimal  Hexadecimal\n");
    for (unsigned int i = 0; i < 6; i++) {
        printf("%7u  0x%X\n", values[i], values[i]);
    }
    return 0;
}