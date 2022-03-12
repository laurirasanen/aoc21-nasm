; advent of code 2021 - day 1, part 1
; https://adventofcode.com/2021/day/1
;
; run:
; nasm -f elf32 part01.asm -o part01.o && gcc -m32 part01.o -o part01.out && ./part01.out

extern printf
extern strtok
extern atoi
global main

section .data
file db "../../input/01.txt", 0
delim db 0x0a ; \n
out_str db "measurements larger than previous: %d", 0x0a, 0
len equ 10000 ; 01.txt fits into 10kb

section .bss
buffer resb len
count resd 1
prev_line resd 1

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

    mov dword [count], 0
    mov dword [prev_line], 0x7fffffff

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

        ; increment count if
        ; larger than prev line
        cmp eax, [prev_line]
        jle .skip
        inc dword [count]
        .skip:

        ; store prev line
        mov dword [prev_line], eax

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
