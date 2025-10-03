format ELF
public _start
public exit

section '.data' writeable
    place   db 1
    newline db 10
    a       dd 0
    b       dd 0
    c       dd 0

section '.text' executable
_start:
    pop ecx
    pop ecx

    pop esi
    call stoi
    mov [a], eax

    xor esi, esi
    pop esi
    call stoi
    mov [b], eax

    xor esi, esi
    pop esi
    call stoi
    mov [c], eax

    mov eax, [b]
    mul [c]
    sub eax, [b]
    add eax, [c]
    sub eax, [a]
    sub eax, [b]

    call print

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    call exit
stoi:
    push ebx
    push ecx
    push edx

    xor eax, eax
    xor ecx, ecx
    xor edx, edx

    .loop:
        movzx ecx, byte [esi]
        test cl, cl
        jz .exit

        cmp cl, '0'
        jb .exit
        cmp cl, '9'
        ja .exit

        sub cl, '0'

        mov ebx, 10
        mul ebx

        add eax, ecx

        inc esi
        jmp .loop

    .exit:
        pop edx
        pop ecx
        pop ebx
        ret

print:
    push eax
    push ebx
    push ecx
    push edx
    push esi
    push edi

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

        pop edi
        pop esi
        pop edx
        pop ecx
        pop ebx
        pop eax
        ret
exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
