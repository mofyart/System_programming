format ELF
public _start
public exit

section '.data' writeable
sym db '+'
M dd 4
K dd 7
newline db 10

section '.text' executable
_start:
    mov ecx, [K]

    .iter1:
        push ecx
        mov edx, [M]

        .iter2:
            push edx

            mov ecx, sym

            mov eax, 4
            mov ebx, 1
            mov edx, 1
            int 0x80

            pop edx
            dec edx
            cmp edx, 0
            jne .iter2

        mov eax, 4
        mov ebx, 1

        mov ecx, newline
        mov edx, 1
        int 0x80

        pop ecx
        dec ecx
        cmp ecx, 0
        jne .iter1


    call exit

exit:
  mov eax, 1
  xor ebx, ebx
  int 0x80
