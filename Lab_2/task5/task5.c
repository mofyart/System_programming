#include <stdio.h>

int main() {
    long long n = 568093600;

    char sum = 0;

    for (; n > 0; n /= 10) {
        sum += n % 10;
    }

    printf("%d\n", sum);
}
