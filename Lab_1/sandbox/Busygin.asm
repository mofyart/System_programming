format ELF
public _start

msg:
 db "Busygin", 10
 db "Artem", 10
 db "Dmitrievich", 10
msgEnd:

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, msg_len
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80


msg_len = msgEnd - msg
