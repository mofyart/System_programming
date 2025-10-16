format ELF64
public _start
public exit

section '.data' writeable
    in_fd       dq 0
    out_fd      dq 0
    file_ptr    dq 0
    file_size   dq 0
    char_buffer rb 1

section '.text' executable
_start:
    cmp qword [rsp], 3
    jne exit_error

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

    cmp rax, 0
    je .cleanup

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
    mov rsi, 577
    mov rdx, 420
    syscall
    cmp rax, 0
    jl exit_error
    mov [out_fd], rax

    mov r12, [file_ptr]

.main_loop:
    mov rax, r12
    sub rax, [file_ptr]
    cmp rax, [file_size]
    jge .cleanup

    mov r13, r12

.find_end_loop:
    mov rax, r13
    sub rax, [file_ptr]
    cmp rax, [file_size]
    jge .found_end_at_eof

    mov al, byte [r13]
    cmp al, '.'
    je .found_end_delimiter
    cmp al, '!'
    je .found_end_delimiter
    cmp al, '?'
    je .found_end_delimiter

    inc r13
    jmp .find_end_loop

.found_end_at_eof:
    dec r13
    jmp .do_reverse

.found_end_delimiter:

.do_reverse:
    mov r14, r13

.reverse_write_loop:
    cmp r14, r12
    jl .reverse_done

    mov al, byte [r14]
    mov [char_buffer], al

    mov rax, 1
    mov rdi, [out_fd]
    mov rsi, char_buffer
    mov rdx, 1
    syscall

    dec r14
    jmp .reverse_write_loop

.reverse_done:
    mov r12, r13
    inc r12
    jmp .main_loop

.cleanup:
    mov rax, 11
    mov rdi, [file_ptr]
    mov rsi, [file_size]
    syscall

    mov rax, 3
    mov rdi, [in_fd]
    syscall

    mov rax, 3
    mov rdi, [out_fd]
    syscall

    call exit

exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

exit:
    mov rax, 60
    xor rdi, rdi
    syscall
