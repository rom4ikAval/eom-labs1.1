#include <stdio.h>

void print_binary(unsigned char value)
{
    for (int i = 7; i >= 0; i--) {
        printf("%u", (value >> i) & 1u);
    }
}

int main(void)
{
    unsigned char values[] = {0, 1, 10, 65, 127, 128, 255};

    printf("Decimal  Hex   Binary\n");
    for (unsigned int i = 0; i < 7; i++) {
        printf("%7u  0x%02X  ",
               (unsigned int)values[i], (unsigned int)values[i]);
        print_binary(values[i]);
        printf("\n");
    }
    return 0;
}