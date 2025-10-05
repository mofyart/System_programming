#include <stdio.h>

int main(int argc, char* argv[]) {
    int n;
    printf("Введите целое число: ");
    scanf("%d", &n);

    long long res = n - (n / 5) - (n / 11) + (n / 55);

    printf("%lld\n", res);
}
