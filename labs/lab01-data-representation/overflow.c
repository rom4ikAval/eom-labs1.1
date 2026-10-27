#include <stdio.h>
#include <stdint.h>

int main(void)
{
    uint8_t value = 254;
    printf("254:     %u\n", (unsigned int)value);

    value++;
    printf("255:     %u\n", (unsigned int)value);

    value++;
    printf("255 + 1: %u\n", (unsigned int)value);

    value++;
    printf("255 + 2: %u\n", (unsigned int)value);

    return 0;
}