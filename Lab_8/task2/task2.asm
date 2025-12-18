format ELF64
public _start

extrn printf
extrn scanf
extrn exit

SYS_EXIT        = 60
EXIT_SUCCESS    = 0

section '.data' writeable
    input_fmt       db "%lf", 0
    output_header   db "%-10s%-15s%-15s", 10, 0
    output_row      db "%-10.6f%-15.6f%-15d", 10, 0

    str_x           db "x", 0
    str_eps         db "epsilon", 0
    str_terms       db "terms", 0

    msg_prompt_x    db "Enter x (-1 < x < 1): ", 0
    msg_prompt_eps  db "Enter epsilon: ", 0
    msg_newline     db 10, 0

    val_1_0         dq 1.0
    val_4_0         dq 4.0

    x               rq 1        ; входной x
    epsilon         rq 1        ; точность
    result          rq 1        ; сумма ряда
    term_count      rq 1        ; счетчик итераций
    current_term    rq 1        ; текущий член ряда
    temp            rq 1        ; временный буфер
    x_power         rq 1        ; степень x

section '.text' executable

_start:
    mov rdi, msg_prompt_x
    xor rax, rax
    call printf

    mov rdi, input_fmt
    mov rsi, x
    xor rax, rax
    call scanf

    mov rdi, msg_prompt_eps
    xor rax, rax
    call printf

    mov rdi, input_fmt
    mov rsi, epsilon
    xor rax, rax
    call scanf

    finit
    fld qword [x]
    fabs                    ; st0 = |x|
    fld1                    ; st0 = 1, st1 = |x|
    fcomip st1
    fstp st0                ; очистка стека
    jbe .invalid_input      ; если 1 <= |x|

    ; Расчеты
    call calc_analytic      ; результат в st0 -> temp
    fstp qword [temp]       ; сохраняем для (возможного) использования

    call calc_series        ; результат в [result]

    ; Вывод заголовка
    mov rdi, output_header
    mov rsi, str_x
    mov rdx, str_eps
    mov rcx, str_terms
    xor rax, rax
    call printf

    ; Вывод строки с данными
    mov rdi, output_row
    movq xmm0, [x]
    movq xmm1, [epsilon]
    mov rsi, [term_count]
    mov rax, 2              ; 2 float аргумента в xmm
    call printf

    ; Выход
    mov rax, SYS_EXIT
    xor rdi, rdi
    syscall

    .invalid_input:
        mov rdi, msg_newline
        call printf
        mov rdi, msg_newline
        call printf

        mov rax, SYS_EXIT
        mov rdi, 1
        syscall


calc_analytic:
    push rbp
    mov rbp, rsp

    ; (1/4) * ln((1+x)/(1-x))
    fld1
    fadd qword [x]          ; st0 = 1 + x
    fld1
    fsub qword [x]          ; st0 = 1 - x
    fdivp st1, st0          ; st0 = (1+x)/(1-x)
    fyl2x                   ; st0 = log2(...)
    fldln2
    fmulp st1, st0          ; st0 = ln(...)

    fld qword [val_1_0]
    fld qword [val_4_0]
    fdivp st1, st0          ; st0 = 0.25
    fmulp st1, st0          ; st0 = 0.25 * ln(...)

    ; (1/2) * arctan(x)
    fld qword [x]
    fld1
    fpatan                  ; st0 = arctan(x)

    fld1
    fadd st0, st0           ; st0 = 2.0
    fdivrp st1, st0         ; st0 = arctan(x) / 2

    ; суммируем
    faddp st1, st0

    leave
    ret


; Вычисление ряда: x + x^5/5 + x^9/9 ...
calc_series:
    push rbp
    mov rbp, rsp

    finit
    fldz
    fstp qword [result]

    mov qword [term_count], 0
    mov qword [x_power], 1  ; инициализация для логики степеней

    ; Базовая инициализация для первой итерации
    fld qword [x]
    fstp qword [current_term]
    fld qword [x]
    fstp qword [x_power]

    .loop:
        inc qword [term_count]

        finit
        fld qword [x_power]

        fld qword [x]
        fmul st0, st0           ; x^2
        fmul st0, st0           ; x^4
        fmulp st1, st0          ; x^(old + 4)
        fst qword [x_power]     ; сохранили новую степень

        ; Делитель (4n + 1)
        fild qword [term_count]
        fld qword [val_4_0]
        fmulp st1, st0          ; 4n
        fld1
        faddp st1, st0          ; 4n + 1

        fdivp st1, st0          ; x^(4n+1) / (4n+1)
        fst qword [current_term]

        ; Суммирование
        fadd qword [result]
        fstp qword [result]

        ; Проверка точности |term| < epsilon
        fld qword [current_term]
        fabs
        fld qword [epsilon]
        fcomip st1
        fstp st0
        jb .next_iter           ; epsilon < |term| продолжаем
        jmp .done

    .next_iter:
        cmp qword [term_count], 1000000
        jl .loop

    .done:
        leave
        ret
