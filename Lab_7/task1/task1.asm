format ELF64
public _start
public exit

section '.data' writeable
    cmd_buffer      rb 256
    argv_ptrs       rq 10

    path_lab5       db './Asm10', 0
    path_lab6       db './Asm6', 0

    str_lab5        db 'Asm10', 0
    str_lab6        db 'Asm6', 0
    str_q           db 'q', 0

    child_pid       dq 0
    wait_status     dq 0

    envp            dq 0

    prompt          db '> ', 0
    msg_unknown     db 'Unknown command', 10, 0
    msg_error_fork  db 'Fork failed', 10, 0

section '.text' executable
_start:
    lea rbx, [rsp + 8]      ; rbx = адрес первого элемента argv (пропускаем argc)

    .find_envp_loop:
        cmp qword [rbx], 0      ; Проверяем, не дошли ли мы до NULL (конец argv)
        je .found_null
        add rbx, 8              ; Переходим к следующему элементу
        jmp .find_envp_loop

    .found_null:
        add rbx, 8              ; Пропускаем сам NULL. Теперь rbx указывает на начало envp
        mov [envp], rbx         ; Сохраняем правильный указатель!

    .main_loop:
        ; Вывод приглашения
        mov rax, 1
        mov rdi, 1
        mov rsi, prompt
        mov rdx, 2
        syscall

        ; Чтение ввода
        mov rax, 0
        mov rdi, 0
        mov rsi, cmd_buffer
        mov rdx, 255
        syscall

        cmp rax, 0
        jle exit

        ; Удаление \n
        mov rcx, rax
        dec rcx
        cmp byte [cmd_buffer + rcx], 10
        jne .parse_input
        mov byte [cmd_buffer + rcx], 0

    .parse_input:
        mov rsi, cmd_buffer
        mov rdi, argv_ptrs
        xor rcx, rcx

    .token_loop:
        cmp byte [rsi], ' '
        je .skip_space
        cmp byte [rsi], 0
        je .tokens_done

        mov [rdi + rcx*8], rsi
        inc rcx

    .scan_word:
        inc rsi
        cmp byte [rsi], ' '
        je .end_word
        cmp byte [rsi], 0
        je .tokens_done
        jmp .scan_word

    .end_word:
        mov byte [rsi], 0
        inc rsi
        jmp .token_loop

    .skip_space:
        inc rsi
        jmp .token_loop

    .tokens_done:
        mov qword [rdi + rcx*8], 0

        cmp rcx, 0
        je .main_loop

        ; --- Сравнение ---
        mov rsi, [argv_ptrs]
        mov rdi, str_q
        call strcmp
        test rax, rax
        jz exit

        mov rsi, [argv_ptrs]
        mov rdi, str_lab5
        call strcmp
        test rax, rax
        jz .run_lab5

        mov rsi, [argv_ptrs]
        mov rdi, str_lab6
        call strcmp
        test rax, rax
        jz .run_lab6

        mov rax, 1
        mov rdi, 1
        mov rsi, msg_unknown
        mov rdx, 16
        syscall
        jmp .main_loop

    .run_lab5:
        mov rbx, path_lab5
        jmp .do_fork

    .run_lab6:
        mov rbx, path_lab6
        jmp .do_fork

    .do_fork:
        mov rax, 57 ; создаём копию основного процесса
        syscall

        cmp rax, 0
        jl .fork_error
        je .child_process

        mov [child_pid], rax
        jmp .wait_child

    .child_process:
        mov rax, 59             ; sys_execve
        mov rdi, rbx            ; Имя файла
        mov rsi, argv_ptrs      ; Аргументы
        mov rdx, [envp]         ; Передаем найденное окружение
        syscall

        call exit_error

    .wait_child:
        mov rax, 61 ; sys_wait4
        mov rdi, [child_pid]
        mov rsi, wait_status
        mov rdx, 0
        mov r10, 0
        syscall
        jmp .main_loop

    .fork_error:
        mov rax, 1
        mov rdi, 1
        mov rsi, msg_error_fork
        mov rdx, 12
        syscall
        jmp .main_loop

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

exit:
    mov rax, 60
    xor rdi, rdi
    syscall

strcmp:
    push rsi
    push rdi
    push rbx

    .loop:
        mov al, [rsi]
        mov bl, [rdi]
        cmp al, bl
        jne .not_equal
        test al, al
        jz .equal
        inc rsi
        inc rdi
        jmp .loop
    .not_equal:
        mov rax, 1
        jmp .done
    .equal:
        xor rax, rax
    .done:
        pop rbx
        pop rdi
        pop rsi
        ret
