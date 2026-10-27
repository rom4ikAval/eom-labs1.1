#include <stdio.h>
#include <stdint.h>

void print_binary(unsigned char value)
{
    for (int i = 7; i >= 0; i--) {
        printf("%u", (value >> i) & 1u);
    }
}

int main(void)
{
    int8_t signed_value = -1;
    uint8_t unsigned_value = 255;

    unsigned char signed_byte =
        *(const unsigned char *)&signed_value;

    printf("Type     Decimal  Hex   Binary\n");

    printf("int8_t   %7d  0x%02X  ",
           (int)signed_value, (unsigned int)signed_byte);
    print_binary(signed_byte);
    printf("\n");

    printf("uint8_t  %7u  0x%02X  ",
           (unsigned int)unsigned_value, (unsigned int)unsigned_value);
    print_binary(unsigned_value);
    printf("\n");

    return 0;
}