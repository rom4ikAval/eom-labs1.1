#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <ctype.h>

void print_binary(unsigned char value)
{
    for (int i = 7; i >= 0; i--) {
        printf("%u", (value >> i) & 1u);
    }
}

int main(void)
{
    char input[128];
    char *end;

    printf("Enter value (0-255): ");

    if (!fgets(input, sizeof(input), stdin)) {
        return 1;
    }

    errno = 0;
    long value = strtol(input, &end, 10);

    if (end == input || errno != 0) {
        printf("Error: enter an integer from 0 to 255.\n");
        return 1;
    }

    while (isspace((unsigned char)*end)) {
        end++;
    }

    if (*end != '\0' || value < 0 || value > 255) {
        printf("Error: enter an integer from 0 to 255.\n");
        return 1;
    }

    printf("Decimal:     %ld\n", value);
    printf("Hexadecimal: 0x%02X\n", (unsigned int)value);
    printf("Binary:      ");
    print_binary((unsigned char)value);
    printf("\n");

    if (value >= 32 && value <= 126) {
        printf("Character:   %c\n", (int)value);
    }

    return 0;
}