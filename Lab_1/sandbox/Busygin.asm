format ELF64 executable 3
entry start

segment readable executable

start:
    ; System call write
    mov rax, 1          ; syscall number for write
    mov rdi, 1          ; file descriptor (stdout)
    mov rsi, msg        ; pointer to message
    mov rdx, msg_len    ; message length
    syscall

    ; System call exit
    mov rax, 60         ; syscall number for exit
    xor rdi, rdi        ; exit code 0
    syscall

segment readable writeable

msg db 'Busygin Artem Dmitrievich', 0xA
msg_len = $ - msg

; fasm name.arm name ; compilation
; chmod +x ./Galesssio ; change mode for file to make it exe.
; ./name ; call
