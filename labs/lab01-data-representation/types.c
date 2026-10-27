#include <stdio.h>
#include <limits.h>

int main(void)
{
    printf("Type       Bytes  Bits\n");
    printf("char       %5zu  %4zu\n", sizeof(char), sizeof(char) * CHAR_BIT);
    printf("short      %5zu  %4zu\n", sizeof(short), sizeof(short) * CHAR_BIT);
    printf("int        %5zu  %4zu\n", sizeof(int), sizeof(int) * CHAR_BIT);
    printf("long       %5zu  %4zu\n", sizeof(long), sizeof(long) * CHAR_BIT);
    printf("long long  %5zu  %4zu\n", sizeof(long long), sizeof(long long) * CHAR_BIT);
    printf("float      %5zu  %4zu\n", sizeof(float), sizeof(float) * CHAR_BIT);
    printf("double     %5zu  %4zu\n", sizeof(double), sizeof(double) * CHAR_BIT);
    printf("void *     %5zu  %4zu\n", sizeof(void *), sizeof(void *) * CHAR_BIT);
    return 0;
}