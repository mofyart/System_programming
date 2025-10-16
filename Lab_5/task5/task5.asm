format ELF64
public _start
public exit

section '.data' writeable
    k       dq 0
    m       dq 0
    in_fd   dq 0
    out_fd  dq 0
    file_size dq 0
    file_ptr  dq 0

section '.text' executable
_start:
    cmp qword [rsp], 5
    jne exit_error

    mov rdi, [rsp+32]
    call stoi
    sub rax, 1
    mov [k], rax

    mov rdi, [rsp+40]
    call stoi
    mov [m], rax

    mov rax, 2
    mov rdi, [rsp+16]
    xor rsi, rsi
    xor rdx, rdx
    syscall
    cmp rax, 0
    jl exit_error
    mov [in_fd], rax

    mov rax, 8
    mov rdi, [in_fd]
    xor rsi, rsi
    mov rdx, 2
    syscall
    mov [file_size], rax

    mov rax, 9
    xor rdi, rdi
    mov rsi, [file_size]
    mov rdx, 1
    mov r10, 2
    mov r8, [in_fd]
    xor r9, r9
    syscall
    mov [file_ptr], rax

    mov rax, 2
    mov rdi, [rsp+24]
    mov rsi, 65
    mov rdx, 420
    syscall
    cmp rax, 0
    jl exit_error
    mov [out_fd], rax

    mov rbx, [k]
    cmp rbx, [file_size]
    jge .skip_first

    mov rax, 1
    mov rdi, [out_fd]
    mov rsi, [file_ptr]
    add rsi, rbx
    mov rdx, 1
    syscall
.skip_first:

    mov rcx, 1
.swing_loop:
    cmp rcx, [m]
    jg .loop_end

    mov rbx, [k]
    add rbx, rcx
    cmp rbx, [file_size]
    jge .skip_plus

    mov rax, 1
    mov rdi, [out_fd]
    mov rsi, [file_ptr]
    add rsi, rbx
    mov rdx, 1
    syscall
.skip_plus:

    mov rbx, [k]
    sub rbx, rcx
    js .skip_minus

    mov rax, 1
    mov rdi, [out_fd]
    mov rsi, [file_ptr]
    add rsi, rbx
    mov rdx, 1
    syscall
.skip_minus:

    inc rcx
    jmp .swing_loop

.loop_end:
    mov rax, 3
    mov rdi, [out_fd]
    syscall

    mov rax, 3
    mov rdi, [in_fd]
    syscall

    mov rax, 11
    mov rdi, [file_ptr]
    mov rsi, [file_size]
    syscall

    call exit

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

stoi:
    push rbx
    push rcx
    push rdi

    xor rax, rax
    xor rcx, rcx
.loop:
    movzx ecx, byte [rdi]
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

    inc rdi
    jmp .loop
.exit:
    pop rdi
    pop rcx
    pop rbx
    ret

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
