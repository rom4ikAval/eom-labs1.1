#include <stdio.h>

int main(void)
{
    char values[] = {'A', 'B', 'a', '0', '9'};

    printf("Character  Decimal  Hex\n");
    for (unsigned int i = 0; i < 5; i++) {
        printf("%9c  %7u  0x%02X\n", values[i],
               (unsigned int)(unsigned char)values[i],
               (unsigned int)(unsigned char)values[i]);
    }
    return 0;
}