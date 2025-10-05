format ELF64
public _start

section '.data' writeable
    password      db "1234Artem", 0
    msg_success   db "Вошли", 10
    len_success   = $ - msg_success

    msg_incorrect db "Невереный пароль", 10
    len_incorrect = $ - msg_incorrect

    msg_failure   db "Неудача", 10
    len_failure   = $ - msg_failure

    attempts      db 5

section '.bss' writeable
    input_buffer dq 32

section '.text' executable
_start:
    mov bl, [attempts]

    attempt_loop:
        mov rax, 0
        mov rdi, 0
        mov rsi, input_buffer
        mov rdx, 32
        syscall

        mov byte [rsi + rax - 1], 0

        mov rdi, password
        mov rsi, input_buffer
        call strcmp

        cmp rax, 0
        je success_path

        jmp incorrect_path

    success_path:
        mov rax, 1
        mov rdi, 1
        mov rsi, msg_success
        mov rdx, len_success
        syscall
        jmp exit

    incorrect_path:
        mov rax, 1
        mov rdi, 1
        mov rsi, msg_incorrect
        mov rdx, len_incorrect
        syscall

        dec bl
        jnz attempt_loop

    failure_path:
        mov rax, 1
        mov rdi, 1
        mov rsi, msg_failure
        mov rdx, len_failure
        syscall
        jmp exit

    exit:
        mov rax, 60
        xor rdi, rdi
        syscall

strcmp:
    .loop:
        mov al, byte [rdi]
        mov dl, byte [rsi]
        cmp al, dl
        jne .not_equal

        cmp al, 0
        je .equal

        inc rdi
        inc rsi
        jmp .loop

    .not_equal:
        mov rax, 1
        ret

    .equal:
        mov rax, 0
        ret
