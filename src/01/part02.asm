; advent of code 2021 - day 1, part 2
; https://adventofcode.com/2021/day/1
;
; run:
; nasm -f elf32 part02.asm -o part02.o && gcc -m32 part02.o -o part02.out && ./part02.out

extern printf
extern strtok
extern atoi
global main

section .data
file db "../../input/01.txt", 0
delim db 0x0a, 0 ; \n
out_str db "three-measurement windows larger than previous: %d", 0x0a, 0
len equ 10000 ; 01.txt fits into 10kb

section .bss
buffer resb len
count resd 1
prev_window resd 1
has_prev resb 1
window resd 3
woffset resb 1

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

    ; init to 0
    mov dword [count], 0
    mov dword [prev_window], 0
    mov byte [has_prev], 0
    mov dword [window], 0
    mov dword [window + 4], 0
    mov dword [window + 8], 0

    ; char *token = strtok(*buffer, delim)
    push delim
    push buffer
    call strtok
    add esp, 8

    ; if token == NULL
    cmp eax, 0
    je .end

    .loop:
        ; atoi(token)
        push eax
        call atoi
        add esp, 4

        ; store line into window,
        ; replacing oldest value
        mov ebx, [woffset]
        mov dword [window + ebx], eax

        ; total value of window
        xor eax, eax
        add dword eax, [window]
        add dword eax, [window + 4]
        add dword eax, [window + 8]

        ; inc count if greater than prev window
        cmp byte [has_prev], 1
        jne .end_count
        cmp dword eax, [prev_window]
        jle .end_count
        inc dword [count]
        .end_count:

        ; update prev window value
        mov dword [prev_window], eax
        
        ; loop window offset
        ; between 0, 4, 8.
        ; if offset has rolled back to 0,
        ; we have a read enough values
        ; to have full prev window value;
        ; start comparing next loop.
        add byte [woffset], 4
        cmp byte [woffset], 8
        jle .end_offset
        mov byte [woffset], 0
        mov byte [has_prev], 1
        .end_offset:

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

    ; printf(out_str, count)
    push dword [count]
    push out_str
    call printf
    add esp, 8

    ; exit
    mov eax, 1
    mov ebx, 0
    int 0x80
