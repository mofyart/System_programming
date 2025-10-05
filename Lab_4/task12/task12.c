#include <stdio.h>

int main() {
    int n;

    scanf("%d", &n);

    int pred = 10;

    while (n != 0) {
        int ele = n % 10;
        n /= 10;

        if (pred < ele) {
            printf("Нет");
            return 0;
        }

        pred = ele;
    }

    printf("Да");
}
