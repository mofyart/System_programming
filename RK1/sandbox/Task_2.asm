format ELF64
public _start
public exit

section '.data' writeable
    n           dq 0
    total_sum   dq 0
    buffer      rb 20
    newline     db 10

section '.text' executable
_start:
    cmp qword [rsp], 2
    jne exit_error

    mov rdi, [rsp+16]
    call stoi
    mov [n], rax

    mov rcx, 1
    xor rbx, rbx

    .main_loop:
        cmp rcx, [n]
        jg .print_result

        mov rdi, rcx
        call reverse_number
        add rbx, rax

        inc rcx
        jmp .main_loop

    .print_result:
        mov rax, rbx
        call print

        mov rax, 1
        mov rdi, 1
        mov rsi, newline
        mov rdx, 1
        syscall

        call exit

reverse_number:
    mov rax, rdi
    xor rsi, rsi

    .rev_loop:
        xor rdx, rdx
        mov rdi, 10
        div rdi

        imul rsi, rsi, 10
        add rsi, rdx

        test rax, rax
        jnz .rev_loop
        mov rax, rsi

        ret
stoi:
    xor rax, rax

    .stoi_loop:
        movzx rcx, byte [rdi]

        cmp cl, '0'
        jb .stoi_exit
        cmp cl, '9'
        ja .stoi_exit

        sub cl, '0'
        imul rax, rax, 10
        add rax, rcx
        inc rdi
        jmp .stoi_loop
    .stoi_exit:
        ret

print:
    mov rdi, buffer + 19

    .to_str_loop:
        xor rdx, rdx
        mov rsi, 10
        div rsi
        add dl, '0'
        mov [rdi], dl
        dec rdi
        test rax, rax
        jnz .to_str_loop

        inc rdi
        mov rax, 1
        mov rsi, rdi
        mov rdx, buffer + 20
        sub rdx, rdi
        mov rdi, 1
        syscall
        ret

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
