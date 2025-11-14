format ELF64
public _start

extrn curs_set
extrn initscr
extrn start_color
extrn init_pair
extrn getmaxx
extrn getmaxy
extrn raw
extrn noecho
extrn keypad
extrn stdscr
extrn move
extrn getch
extrn addch
extrn refresh
extrn endwin
extrn exit
extrn timeout
extrn usleep
extrn printw
extrn attron
extrn attroff
extrn bkgdset

section '.bss' writable
    x dq 1
    y dq 1
    xMax dq 1
    yMax dq 1
    char dq 1
    delay dq 10000
    newColor dq 1


    direction dq 1
    top_b dq 1
    left_b dq 1
    right_b dq 1
    bottom_b dq 1

section '.text' executable
_start:
    call initscr
    mov rdi, [stdscr]

    call getmaxx
    mov [xMax], rax

    call getmaxy
    mov [yMax], rax

    call start_color

    mov rdi, 1
    mov rsi, 7
    mov rdx, 5  ; COLOR_MAGENTA
    call init_pair

    mov rdi, 2
    mov rsi, 7
    mov rdx, 6  ; COLOR_CYAN
    call init_pair

    xor rdi, rdi
    call curs_set
    call refresh
    call noecho
    call raw

    mov rax, ' '
    mov [char], rax
    mov qword [newColor], 1
printBegin:
    mov qword [x], 0
    mov qword [y], 0
    mov qword [left_b], 0
    mov qword [top_b], 0

    mov rax, [xMax]
    dec rax
    mov [right_b], rax    ; right_b = xMax - 1

    mov rax, [yMax]
    dec rax
    mov [bottom_b], rax

    mov qword [direction], 0


mainLoop:
    mov rdi, [y]
    mov rsi, [x]
    call move

    mov rdi, [newColor]
    shl rdi, 8
    call attron

    mov rdi, [char]
    call addch

    call refresh

    mov rdi, [delay]
    call usleep


    xor rdi, rdi
    call timeout
    call getch

    cmp rax, 'v'
    je return
    cmp rax, 'b'
    je updateSpeed


    mov r10, [direction]
    mov r11, [top_b]
    mov r12, [left_b]
    mov r13, [right_b]
    mov r14, [bottom_b]
    mov r8, [x]
    mov r9, [y]


    cmp r12, r13        ; if (left_b > right_b)
    jg .restartSpiral
    cmp r11, r14        ; if (top_b > bottom_b)
    jg .restartSpiral

   ; для 4-х направлений
    cmp r10, 0
    je .moveRight
    cmp r10, 1
    je .moveDown
    cmp r10, 2
    je .moveLeft
    ; else (r10 == 3)
    jmp .moveUp

.moveRight:
    inc r8
    mov [x], r8
    cmp r8, r13
    jl mainLoop

    inc r11
    mov [top_b], r11
    mov qword [direction], 1
    jmp mainLoop

.moveDown:
    inc r9
    mov [y], r9
    cmp r9, r14         ; if (y < bottom_b)
    jl mainLoop

    dec r13
    mov [right_b], r13
    mov qword [direction], 2
    jmp mainLoop

.moveLeft:
    dec r8
    mov [x], r8
    cmp r8, r12         ; if (x > left_b)
    jg mainLoop

    dec r14
    mov [bottom_b], r14
    mov qword [direction], 3
    jmp mainLoop

.moveUp:
    dec r9
    mov [y], r9
    cmp r9, r11         ; if (y > top_b)
    jg mainLoop

    inc r12
    mov [left_b], r12
    mov qword [direction], 0
    jmp mainLoop

.restartSpiral:
    mov rdi, qword [newColor]
    xor rdi, 3
    mov qword [newColor], rdi
    jmp printBegin

updateSpeed:
    cmp qword [delay], 10000
    jne setSlow
    mov qword [delay], 3000
    jmp mainLoop
setSlow:
    mov qword [delay], 10000
    jmp mainLoop

return:
    call endwin
    mov rax, 60
    xor rdi, rdi
    syscall
