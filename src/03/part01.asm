; advent of code 2021 - day 3, part 1
; https://adventofcode.com/2021/day/1
;
; run:
; nasm -f elf32 part01.asm -o part01.o && gcc -m32 part01.o -o part01.out && ./part01.out

extern printf
extern strtok
global main

section .data
file db "../../input/03.txt", 0
delim db 0x0a, 0 ; \n
out_str db "gamma: %d, epsilon: %d, mult: %d", 0x0a, 0
len equ 13500
max_line_len equ 12

section .bss
buffer resb len
value_counters resd max_line_len
line_counter resd 1
last_line_len resd 1
gamma resd 1
epsilon resd 1
test_str resb 13

section .text
main:
    ; open file
    mov eax, 5 ; open
    mov ebx, file
    mov ecx, 0 ; read-only
    int 0x80

    ; store file descriptor
    push eax

    ; read file to buffer
    mov ebx, eax ; file desc
    mov eax, 3 ; read
    mov ecx, buffer
    mov edx, len
    int 0x80

    ; close file
    mov eax, 6 ; close
    pop ebx ; file desc
    int 0x80

    mov ecx, 0
    .init_loop:
        mov dword [value_counters + ecx * 4], 0
        inc ecx
        cmp ecx, max_line_len
        jge .end_init
        jmp .init_loop
    .end_init:

    ; char *token = strtok(*buffer, delim)
    push delim
    push buffer
    call strtok
    add esp, 8

    ; if token == NULL
    cmp eax, 0
    je .end

    .loop:
        inc dword [line_counter]
        mov dword [last_line_len], 0
        mov ecx, 0

        .char_loop:
            ; null
            cmp byte [eax + ecx], 0
            je .end_char

            ; 0
            cmp byte [eax + ecx], 0x30
            jne .end_0
            ;inc dword [value_counters + ecx * 4]
            jmp .end_1
            .end_0:

            ; 1
            cmp byte [eax + ecx], 0x31
            jne .end_1
            inc dword [value_counters + ecx * 4]
            .end_1:

            ; sanity
            inc dword [last_line_len]
            cmp dword [last_line_len], max_line_len
            jge .end_char

            inc ecx
            jmp .char_loop
        .end_char:

        ; token = strtok(NULL, delim)
        push delim
        push 0
        call strtok
        add esp, 8

        ; if token == NULL
        cmp eax, 0
        je .end

        jmp .loop

    .end:

    ; ceil(0.5 * line count)
    mov edx, 0
    mov dword eax, [line_counter]
    mov ecx, 2
    div ecx
    cmp edx, 0
    jle .end_div
    inc ecx
    .end_div:

    mov edx, eax

    xor eax, eax
    xor ecx, ecx
    mov dword [gamma], 0
    mov dword [epsilon], 0
    mov dword ebx, [last_line_len]
    dec dword ebx

    .loop_to_dec:
        ; 2^n
        cmp ebx, 0
        jne .not_0
        mov eax, 1
        jmp .is_0
        .not_0:
        push edx
        push ebx
        push ecx
        mov eax, 2
        mov ecx, eax
        .pow_loop:
            cmp ebx, 1
            jle .end_pow
            mul ecx
            dec ebx
            jmp .pow_loop
        .end_pow:
        pop ecx
        pop ebx
        pop edx
        .is_0:

        ; add to gamma or epsilon
        cmp dword [value_counters + ecx * 4], edx
        jl .end_gamma
        add dword [gamma], eax
        jmp .end_epsilon
        .end_gamma:
        add dword [epsilon], eax
        .end_epsilon:

        ; n--
        sub ebx, 1
        cmp ebx, 0
        jl .end_to_dec

        inc ecx
        jmp .loop_to_dec
    .end_to_dec:

    mov dword eax, [gamma]
    mul dword [epsilon]

    push eax
    push dword [epsilon]
    push dword [gamma]
    push out_str
    call printf
    add esp, 16

    ; exit
    mov eax, 1
    mov ebx, 0
    int 0x80
