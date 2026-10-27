#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

int main(void)
{
    uint32_t value = UINT32_C(0x12345678);
    unsigned char *p = (unsigned char *)&value;

    printf("value = 0x%08" PRIX32 "\n", value);
    printf("Byte  Address             Value\n");

    for (size_t i = 0; i < sizeof(value); i++) {
        printf("%4zu  %p  0x%02X\n",
               i, (void *)&p[i], (unsigned int)p[i]);
    }

    if (p[0] == 0x78 && p[1] == 0x56 &&
        p[2] == 0x34 && p[3] == 0x12) {
        printf("Byte order: Little-endian\n");
    } else if (p[0] == 0x12 && p[1] == 0x34 &&
               p[2] == 0x56 && p[3] == 0x78) {
        printf("Byte order: Big-endian\n");
    } else {
        printf("Byte order: Other\n");
    }

    return 0;
}