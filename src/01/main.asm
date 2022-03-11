; advent of code 2021 - day 1
; https://adventofcode.com/2021/day/1
;
; compile:
; nasm -f elf32 main.asm -o main.o && ld -m elf_i386 main.o -o main.out

global _start


section .data

file db "../../input/01.txt", 0
len equ 16000
buffer resb len


section .text

_start:
    ; open file
    mov eax, 5 ; open
    mov ebx, file
    mov ecx, 0 ; "r"
    int 80h

    ; store file descriptor
    push eax

    ; read file to buffer
    mov ebx, eax ; file desc
    mov eax, 3 ; read
    mov ecx, buffer
    mov edx, len
    int 80h

    mov edx, eax ; num of bytes read

    ; close file
    mov eax, 6 ; close
    pop ebx ; file desc
    int 80h

    ; write buffer to terminal
    mov eax, 4 ; write
    mov ebx, 1 ; terminal
    mov ecx, buffer
    int 80h

    ; exit
    mov eax, 1
    mov ebx, 0
    int 80h
