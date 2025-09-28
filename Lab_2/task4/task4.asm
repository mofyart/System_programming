format ELF
public _start

section '.data'  writeable
    N       dd 568093600
    res     dd 0
    newline db 10
    place   db 0

section '.text' executable
_start:
    mov eax, [N]
    mov ebx, 10
    mov ecx, 0

.iter1:
    xor edx, edx
    div ebx
    add ecx, edx
    test eax, eax
    jnz .iter1

    mov [res], ecx
    call print

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    call exit

print:
    mov eax, [res]
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
