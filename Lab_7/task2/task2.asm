format ELF64
public _start
ARRAY_LEN       = 10
TOTAL_THREADS   = 4

section '.data' writeable
    msg_gen         db '[Parent] Генерируем 754 рандомных числа', 10, 0
    msg_arr         db '[Parent] Элементы массива: ', 0    ; <-- Добавлено для вывода
    msg_space       db ' ', 0                              ; <-- Добавлено (разделитель)
    msg_task1       db '[Task 1] 5-ое число после минимального (значение: ', 0
    msg_task1_idx   db ', по индексу: ', 0
    msg_res         db ') -> Результат: ', 0
    msg_task2       db '[Task 2] 3-ий число после максимального (значение: ', 0
    msg_task2_idx   db ', по индексу: ', 0
    msg_task3       db '[Task 3] Количество чисел кратных 5: ', 0
    msg_task4       db '[Task 4] Среднее значение (округление до целого): ', 0
    newline         db 10, 0
    fmt_num_buf     rb 20
    array_ptr       dq 0
    seed            dq 123456789

section '.text' executable
_start:
    mov rax, 9                  ; sys_mmap
    mov rdi, 0
    mov rsi, 8192               ; Размер памяти

    mov rdx, 3                  ; 1 (READ) + 2 (WRITE) = 3

    mov r10, 34                 ; 2 (PRIVATE) + 32 (ANONYMOUS, 0x20) = 34 (0x22)

    mov r8, -1
    mov r9, 0
    syscall

    cmp rax, 0
    jl exit_error
    mov [array_ptr], rax

    ; --- 2. ЗАПОЛНЕНИЕ МАССИВА ---
    mov rdi, [array_ptr]
    mov rcx, ARRAY_LEN

    .fill_loop:
        call rand
        mov [rdi], rax
        add rdi, 8
        loop .fill_loop

        mov rsi, msg_gen
        call print_string

        ; --- ВСТАВКА: ВЫВОД МАССИВА ---
        mov rsi, msg_arr        ; Выводим заголовок "Элементы массива: "
        call print_string

        mov rbx, [array_ptr]    ; Указатель на начало массива
        mov rcx, ARRAY_LEN      ; Счётчик цикла
        xor r12, r12            ; Индекс (используем r12, т.к. он callee-saved и не портится функциями print)

    .print_loop:
        mov rax, [rbx + r12*8]  ; Загружаем число из массива
        call print_uint         ; Выводим число

        mov rsi, msg_space      ; Выводим пробел
        call print_string

        inc r12
        loop .print_loop        ; rcx уменьшается автоматически

        call print_newline      ; Перенос строки после вывода массива
        ; ------------------------------

        ; --- 3. ЗАПУСК ПРОЦЕССОВ (FORK) ---

        call fork_process
        test rax, rax
        jz task_min_plus_5

        call fork_process
        test rax, rax
        jz task_max_plus_3

        call fork_process
        test rax, rax
        jz task_count_div_5

        call fork_process
        test rax, rax
        jz task_average

        ; --- 4. ОЖИДАНИЕ ЗАВЕРШЕНИЯ ---
        mov rcx, TOTAL_THREADS
    .wait_loop:
        push rcx
        mov rax, 61
        mov rdi, -1
        mov rsi, 0
        mov rdx, 0
        mov r10, 0
        syscall
        pop rcx
        loop .wait_loop

        call exit

task_min_plus_5:
    mov rbx, [array_ptr]
    mov rcx, ARRAY_LEN
    mov rax, [rbx]              ; Мин. значение
    xor rdx, rdx                ; Индекс мин.
    xor r8, r8

    .loop_min:
        cmp [rbx + r8*8], rax
        jge .skip_min
        mov rax, [rbx + r8*8]
        mov rdx, r8
    .skip_min:
        inc r8
        cmp r8, rcx
        jl .loop_min

        push rax
        push rdx
        mov rsi, msg_task1
        call print_string
        pop rdx
        push rdx
        mov rax, [rsp+8]
        call print_uint
        mov rsi, msg_task1_idx
        call print_string
        pop rdx
        mov rax, rdx
        call print_uint
        mov rsi, msg_res
        call print_string

        add rdx, 5
        mov rax, rdx
        xor rdx, rdx
        mov r9, ARRAY_LEN
        div r9

        mov rbx, [array_ptr]
        mov rax, [rbx + rdx*8]
        call print_uint
        call print_newline
        call exit_thread

task_max_plus_3:
    mov rbx, [array_ptr]
    mov rcx, ARRAY_LEN
    mov rax, [rbx]
    xor rdx, rdx
    xor r8, r8

    .loop_max:
        cmp [rbx + r8*8], rax
        jle .skip_max
        mov rax, [rbx + r8*8]
        mov rdx, r8
    .skip_max:
        inc r8
        cmp r8, rcx
        jl .loop_max

        push rax
        push rdx
        mov rsi, msg_task2
        call print_string
        mov rax, [rsp+8]
        call print_uint
        mov rsi, msg_task2_idx
        call print_string
        pop rdx
        mov rax, rdx
        call print_uint
        mov rsi, msg_res
        call print_string

        add rdx, 3
        mov rax, rdx
        xor rdx, rdx
        mov r9, ARRAY_LEN
        div r9

        mov rbx, [array_ptr]
        mov rax, [rbx + rdx*8]
        call print_uint
        call print_newline
        call exit_thread

task_count_div_5:
    mov rbx, [array_ptr]
    mov rcx, ARRAY_LEN
    xor r12, r12
    xor r8, r8
    mov r9, 5

    .loop_div:
        mov rax, [rbx + r8*8]
        xor rdx, rdx
        div r9
        cmp rdx, 0
        jne .next_div
        inc r12
    .next_div:
        inc r8
        cmp r8, rcx
        jl .loop_div

        mov rsi, msg_task3
        call print_string
        mov rax, r12
        call print_uint
        call print_newline
        call exit_thread

task_average:
    mov rbx, [array_ptr]
    mov rcx, ARRAY_LEN
    xor r12, r12
    xor r8, r8

    .loop_avg:
        add r12, [rbx + r8*8]
        inc r8
        cmp r8, rcx
        jl .loop_avg

        mov rax, r12
        xor rdx, rdx
        mov r9, ARRAY_LEN
        div r9

        mov rsi, msg_task4
        call print_string
        call print_uint
        call print_newline
        call exit_thread

; Используем FORK (57) вместо CLONE.
; Fork создает точную копию процесса.
; В родителе возвращает PID ребенка, в ребенке возвращает 0.
fork_process:
    mov rax, 57
    syscall
    ret

rand:
    ; ВАЖНО: Сохраняем RCX, так как он используется как счетчик цикла снаружи!
    push rcx

    mov rax, [seed]
    mov rbx, 6364136223846793005
    mul rbx

    mov rcx, 1442695040888963407
    add rax, rcx

    mov [seed], rax
    xor rdx, rdx
    mov rbx, 1000
    div rbx
    mov rax, rdx

    pop rcx
    ret

print_string:
    push rdi
    push rax
    push rdx
    push rcx
    mov rdi, rsi
    call strlen
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    pop rcx
    pop rdx
    pop rax
    pop rdi
    ret

print_newline:
    mov rsi, newline
    call print_string
    ret

print_uint:
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    mov rbx, 10
    mov rcx, fmt_num_buf
    add rcx, 19
    mov byte [rcx], 0

    .convert_loop:
        dec rcx
        xor rdx, rdx
        div rbx
        add dl, '0'
        mov [rcx], dl
        test rax, rax
        jnz .convert_loop
        mov rsi, rcx
        call print_string
        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop rbx
        ret

strlen:
    xor rax, rax
    .loop:
        cmp byte [rdi + rax], 0
        je .done
        inc rax
        jmp .loop
    .done:
        ret

exit_thread:
    mov rax, 60
    xor rdi, rdi
    syscall

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
