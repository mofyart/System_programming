format ELF64
public _start

extrn initscr
extrn start_color
extrn init_pair
extrn noecho
extrn raw
extrn curs_set
extrn stdscr
extrn addch
extrn refresh
extrn endwin
extrn getch
extrn timeout
extrn attron
extrn attroff

section '.data' writeable
    stat_buf rb 144
    file_fd  dq 0
    file_size dq 0
    mem_ptr  dq 0
    char_buf dq 0

section '.text' executable
_start:
    mov rax, [rsp]
    cmp rax, 2
    jl exit_app

    mov rbx, [rsp + 16]

    call initscr
    call start_color

    xor rdi, rdi
    call curs_set
    call noecho
    call raw

    mov rdi, 1
    mov rsi, 1
    mov rdx, 0
    call init_pair

    mov rdi, 2
    mov rsi, 2
    mov rdx, 0
    call init_pair

    mov rdi, 3
    mov rsi, 3
    mov rdx, 0
    call init_pair

    mov rdi, 4
    mov rsi, 4
    mov rdx, 0
    call init_pair

    mov rdi, 5
    mov rsi, 5
    mov rdx, 0
    call init_pair

    mov rax, 2
    mov rdi, rbx
    xor rsi, rsi
    xor rdx, rdx
    syscall

    cmp rax, 0
    jl exit_ncurses
    mov [file_fd], rax

    mov rax, 5
    mov rdi, [file_fd]
    mov rsi, stat_buf
    syscall

    mov rax, qword [stat_buf + 48]
    mov [file_size], rax

    test rax, rax
    jz close_file

    mov rax, 9
    mov rdi, 0
    mov rsi, [file_size]
    mov rdx, 3
    mov r10, 34
    mov r8, -1
    mov r9, 0
    syscall

    cmp rax, -1
    je close_file
    mov [mem_ptr], rax

    mov rax, 0
    mov rdi, [file_fd]
    mov rsi, [mem_ptr]
    mov rdx, [file_size]
    syscall

    xor r12, r12
    mov r13, [file_size]
    mov r14, [mem_ptr]

printLoop:
    cmp r12, r13
    jge waitKey

    mov rax, r12
    xor rdx, rdx
    mov rbx, 5
    div rbx
    inc rdx

    mov rdi, rdx
    shl rdi, 8
    call attron

    movzx rdi, byte [r14 + r12]
    call addch

    call refresh

    mov rdi, 50
    call timeout

    call getch

    cmp rax, 'q'
    je exit_resources
    cmp rax, 'Q'
    je exit_resources

    inc r12
    jmp printLoop

waitKey:
    mov rdi, -1
    call timeout
    call getch

exit_resources:
    mov rax, 11
    mov rdi, [mem_ptr]
    mov rsi, [file_size]
    syscall

close_file:
    mov rax, 3
    mov rdi, [file_fd]
    syscall

exit_ncurses:
    call endwin

exit_app:
    mov rax, 60
    xor rdi, rdi
    syscall
