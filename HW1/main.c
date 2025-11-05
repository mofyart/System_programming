#include <stdio.h>

extern void queue_init();
extern void queue_push(long val);
extern long queue_pop();
extern void queue_fill_random(int n, int maxv);
extern void queue_print_odds();
extern long queue_count_end1();

void print_menu() {
    printf("1. Добавить в конец\n");
    printf("2. Удалить из начала\n");
    printf("3. Заполнить случайными числами\n");
    printf("4. Получить список нечетных чисел\n");
    printf("5. Подсчитать количество чисел, оканчивающихся на 1\n");
    printf("0. Выйти\n");
}

int main() {
    queue_init();
    int cmd;
    while (1) {
        print_menu();
        printf("\nВаша команда: ");
        scanf("%d", &cmd);
        if (cmd == 0) break;
        if (cmd == 1) {
            long val;

            printf("Введите число: ");
            scanf("%ld", &val);


            queue_push(val);
        } else if (cmd == 2) {
            long x = queue_pop();

            printf("Удалено: %ld\n", x);
        } else if (cmd == 3) {
            int n, maxv;
            printf("Введите n и max_value: ");
            scanf("%d%d", &n, &maxv);

            queue_fill_random(n, maxv);
            printf("Заполнено!\n");
        } else if (cmd == 4) {
            queue_print_odds();
            printf("\n");
        } else if (cmd == 5) {
            long c = queue_count_end1();

            printf("Количество: %ld", c);
            printf("\n");
        }
    }
    return 0;
}
