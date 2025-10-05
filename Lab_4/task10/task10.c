#include <stdio.h>
#include <string.h>

int main() {
    const char* password = "1234Artem";

    char input_buffer[32];

    int acess = 0;

    int count = 0;

    for (int i = 0; i < 5; ++i) {
        printf("Введите пароль:\n");
        if (fgets(input_buffer, sizeof(input_buffer), stdin) == NULL) {
            break;
        }

        if (strlen(input_buffer) > 0 && input_buffer[strlen(input_buffer) - 1] == '\n') {
            input_buffer[strlen(input_buffer) - 1] = '\0';
        }

        if (strcmp(password, input_buffer) == 0) {
            printf("Вошли");
            acess = 1;
            break;
        } else {
            acess = 0;
        }
    }

    if (acess == 0) {
        printf("Неудача");
    }
}
