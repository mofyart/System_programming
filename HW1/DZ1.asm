format ELF64

; === Экспортируемые функции для C ===
public queue_init
public queue_push
public queue_pop
public queue_fill_random
public queue_print_odds
public queue_count_end1

; === Секция данных (глобальные переменные) ===
section '.data' writeable
    q_data dq 0
    q_head dq 0
    q_tail dq 0
    q_size dq 0
    q_cap dq 0
    newline db 10
    place db 1

; === Основной код ===
section '.text' executable

; --- Инициализация очереди (heap) ---
queue_init:
    mov rdi, 256

    mov rax, 9
    mov rsi, rdi
    mov rdx, 0x3
    mov r10, 0x22
    xor r8, r8
    xor r9, r9
    syscall

    mov [q_data], rax
    mov qword [q_head], 0
    mov qword [q_tail], 0
    mov qword [q_size], 0
    mov qword [q_cap], 32
    ret

; --- Добавить элемент в конец ---
queue_push:
    push rbx

    mov rax, [q_size]
    mov rbx, [q_cap]
    cmp rax, rbx
    jge .done

    mov rbx, [q_tail]
    mov rcx, [q_data]
    mov [rcx + rbx * 8], rdi
    inc rbx
    mov rdx, [q_cap]
    cmp rbx, rdx
    jl .no_over

    xor rbx, rbx

    .no_over:
        mov [q_tail], rbx
        inc qword [q_size]
    .done:
        pop rbx
        ret

; --- Удалить из начала, вернуть значение ---
queue_pop:
    push rbx
    mov rax, [q_size]
    test rax, rax
    jz .fail

    mov rbx, [q_head]
    mov rcx, [q_data]
    mov rdx, [rcx + rbx * 8]
    inc rbx
    mov rsi, [q_cap]
    cmp rbx, rsi
    jl .no_over2

    xor rbx, rbx

    .no_over2:
        mov [q_head], rbx
        dec qword [q_size]
        mov rax, rdx
        pop rbx
        ret
    .fail:
        xor rax, rax
        pop rbx
        ret

; --- Заполнить случайными числами [0, maxv-1], n штук ---
queue_fill_random:
    mov rcx, rdi
    mov r8, rsi

    .lp_fill:
        test rcx, rcx
        jz .done_fill

        push rcx
        push r8

        rdtsc
        xor rdx, rdx
        div r8
        mov rdi, rdx
        call queue_push

        pop r8
        pop rcx

        dec rcx
        jmp .lp_fill
    .done_fill:
        ret

; --- Вывести все НЕЧЕТНЫЕ числа через print_int ---
queue_print_odds:
    mov rbx, [q_head]
    mov rcx, [q_size]
    mov rdx, [q_cap]
    mov rsi, [q_data]

    test rsi, rsi
    jz .done_odd

    .lp_odd:
        test rcx, rcx
        jz .done_odd
        mov rax, [rsi + rbx*8]
        test rax, 1
        jz .skip_odd


        push rbx
        push rcx
        push rdx
        push rsi

        mov rdi, rax
        call print_int
        call print_newline

        pop rsi
        pop rdx
        pop rcx
        pop rbx

    .skip_odd:
        inc rbx
        cmp rbx, rdx
        jl .no_over_odd

        xor rbx, rbx
    .no_over_odd:
        dec rcx
        jmp .lp_odd
    .done_odd:
        ret

; --- Вернуть кол-во чисел в очереди, оканчивающихся на 1 ---
queue_count_end1:
    mov rbx, [q_head]
    mov rcx, [q_size]
    mov rdx, [q_cap]
    xor r8, r8

    mov rax, [q_data]

    test rax, rax
    jz .done_c1

    .lp_c1:
        test rcx, rcx
        jz .done_c1
        mov rax, [q_data]
        mov rsi, [rax + rbx*8]

        push rbx
        push rcx
        push rdx

        mov rax, rsi
        xor rdx, rdx
        mov r9, 10
        div r9
        cmp rdx, 1

        pop rdx
        pop rcx
        pop rbx

        jne .skip_c1
        inc r8
    .skip_c1:
        inc rbx
        cmp rbx, [q_cap]
        jl .no_over_c1
        xor rbx, rbx
    .no_over_c1:
        dec rcx
        jmp .lp_c1
    .done_c1:
        mov rax, r8
        ret

; ============ СЛУЖЕБНЫЕ ---------


print_int:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax, rdi
    xor rbx, rbx

    cmp rax, 0
    jge .positive

    neg rax
    mov byte [place], '-'
    mov rax, 1
    mov rdi, 1
    lea rsi, [place]
    mov rdx, 1
    syscall

    .positive:
        mov rcx, 10

    .loop:
        xor rdx, rdx
        div rcx
        push rdx
        inc rbx
        test rax, rax
        jnz .loop

    .print_loop:
        pop rax
        add al, '0'
        mov [place], al

        push rbx

        mov rax, 1
        mov rdi, 1
        lea rsi, [place]
        mov rdx, 1
        syscall

        pop rbx
        dec rbx
        jnz .print_loop

        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret

; --- печать перевода строки ---
print_newline:
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall
    ret
