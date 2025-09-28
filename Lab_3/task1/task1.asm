format ELF
public _start
public exit

section '.data' writeable
    newline db 10
    place db 1

section '.txt' executable
_start:
    add esp, 8
    pop esi
    xor eax, eax
    mov byte al, [esi]

    call print

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    call exit

print:
    xor ebx, ebx
    mov ecx, 10

    .loop:
        xor edx, edx
        div ecx

        push edx
        inc ebx

        test eax, eax
        jnz .loop

    .print_loop:
        pop eax
        add eax, '0'
        mov [place], al

        push ebx

        mov eax, 4
        mov ebx, 1
        mov ecx, place
        mov edx, 1
        int 0x80

        pop ebx
        dec ebx
        jnz .print_loop

        ret
exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
