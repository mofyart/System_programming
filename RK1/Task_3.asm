format ELF64
public _start
public exit


section '.data' writeable
    dir_fd       dq 0
    bytes_read   dq 0
    dir_buffer   rb 4096
    path_buffer  rb 256
    dir_name_buf rb 256

section '.text' executable
_start:
    cmp qword [rsp], 2
    jne exit_error


    mov rdi, dir_name_buf
    mov rsi, [rsp+16]
    call strcpy


    mov rax, 2
    mov rdi, dir_name_buf
    mov rsi, 0x10000
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl exit_error
    mov [dir_fd], rax

    mov rax, 217
    mov rdi, [dir_fd]
    mov rsi, dir_buffer
    mov rdx, 4096
    syscall

    cmp rax, 0
    jle .cleanup
    mov [bytes_read], rax

    mov rbx, dir_buffer
    mov rcx, 3

    .main_loop:
        cmp rcx, 0
        je .cleanup

        mov rax, rbx
        sub rax, dir_buffer
        cmp rax, [bytes_read]
        jge .cleanup

        cmp byte [rbx+18], 8
        jne .next_entry

        call build_full_path

        rdrand rdx
        and rdx, 777o

        mov rax, 90
        mov rdi, path_buffer
        mov rsi, rdx
        syscall

        dec rcx
    .next_entry:
        movzx rdx, word [rbx+16]
        add rbx, rdx
        jmp .main_loop
    .cleanup:
        mov rax, 3
        mov rdi, [dir_fd]
        syscall

        call exit
build_full_path:
    mov rdi, path_buffer
    mov rsi, dir_name_buf

    .copy_dir:
        mov al, [rsi]
        mov [rdi], al
        inc rsi
        inc rdi
        test al, al
        jnz .copy_dir
        dec rdi


        mov byte [rdi], '/'
        inc rdi


        mov rsi, rbx
        add rsi, 19
    .copy_file:
        mov al, [rsi]
        mov [rdi], al
        inc rsi
        inc rdi

        test al, al
        jnz .copy_file

        ret
strcpy:
    .loop:
        mov al, [rsi]
        mov [rdi], al
        inc rsi
        inc rdi

        test al, al
        jnz .loop

        ret
exit_error:
    mov rax, 60
    mov rdi, 1
    syscall
exit:
    mov rax, 60
    xor rdi, rdi
    syscall
