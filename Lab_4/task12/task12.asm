format ELF64

public _start

section '.data' writeable
    newline db 10
    place   db 1

    msg_yes db "Да", 10
    len_yes = $ - msg_yes

    msg_no  db "Нет", 10
    len_no  = $ - msg_no
section '.bss' writeable
    input_buffer dq 32

section '.text' executable

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 32
    syscall

    mov byte [rsi + rax - 1], 0
    mov rsi, input_buffer
    call stoi

    mov rdi, rax
    call check_monotonous

    cmp rax, 1
    je .print_yes

    .print_no:
        mov rax, 1
        mov rdi, 1
        mov rsi, msg_no
        mov rdx, len_no
        syscall
        jmp .exit

    .print_yes:
        mov rbx, 1
        mov rdi, 1
        mov rsi, msg_yes
        mov rdx, len_yes
        syscall
        jmp .exit

    .exit:
        mov rax, 60
        xor rdi, rdi
        syscall

check_monotonous:
    mov rcx, 10

    .loop:
        cmp rdi, 0
        je .success

        mov rax, rdi

        xor rdx, rdx
        mov rbx, 10
        div rbx

        cmp rdx, rcx
        ja .failure

        mov rcx, rdx
        mov rdi, rax
        jmp .loop

    .failure:
        mov rax, 0
        ret

    .success:
        mov rax, 1
        ret
stoi:
    push rbx
    push rcx
    push rdx

    xor rax, rax
    xor rcx, rcx
    xor rdx, rdx

    .loop:
        movzx rcx, byte [rsi]
        test cl, cl
        jz .exit

        cmp cl, '0'
        jb .exit
        cmp cl, '9'
        ja .exit

        sub cl, '0'

        mov rbx, 10
        mul rbx

        add rax, rcx

        inc rsi
        jmp .loop

    .exit:
        pop rdx
        pop rcx
        pop rbx
        ret
