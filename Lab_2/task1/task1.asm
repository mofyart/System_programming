format ELF
public _start
public exit

section '.data' writeable
my db 0xA, "dCvNLCHIwRBfHrlibTfnOuAfqXhQskBnlVMtoFF"
newline db 10

section '.text' executable
_start:
    mov ecx, my
    add ecx, 39
    .iter:
        mov eax, 4
        mov ebx, 1

        mov edx, 1
        int 0x80

        dec ecx
        cmp ecx, my
        jne .iter

    mov eax, 4
    mov ebx, 1

    mov ecx, newline
    mov edx, 1
    int 0x80

    call exit

exit:
  mov eax, 1
  xor ebx, ebx
  int 0x80
