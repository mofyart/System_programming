format ELF64

public _start
public exit

section '.data' writeable
    newline db 10
    place   db 1

section '.bss' writeable
    input_buffer dq 32

section '.text' executable

_start:
    mov rax, 0
    mov rdi, 0
    mov rsi, input_buffer
    mov rdx, 32
    syscall

    mov rsi, input_buffer
    call stoi
    mov rdi, rax

    call func

    call print

    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, 60
    xor rdi, rdi
    syscall

func:
    mov     rbx, rax

    mov     rax, rdi
    xor     rdx, rdx
    mov     rcx, 5
    div     rcx
    sub     rbx, rax

    mov     rax, rdi
    xor     rdx, rdx
    mov     rcx, 11
    div     rcx
    sub     rbx, rax

    mov     rax, rdi
    xor     rdx, rdx
    mov     rcx, 55
    div     rcx
    add     rbx, rax

    mov     rax, rbx
    ret

print:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    xor rbx, rbx

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
        add rax, '0'
        mov [place], al

        push rbx

        mov rax, 1
        mov rdi, 1
        mov rsi, place
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
