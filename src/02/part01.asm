; advent of code 2021 - day 2, part 1
; https://adventofcode.com/2021/day/2
;
; run:
; nasm -f elf32 part01.asm -o part01.o && gcc -m32 part01.o -o part01.out && ./part01.out

extern printf
extern strtok
extern strtok_r
extern atoi
extern strcmp

global main

section .data
file db "../../input/02.txt", 0
delim_line db 0x0a, 0 ; \n
delim_cmd db " ", 0
out_str db "fwd: %d, depth: %d (up: %d, down: %d), mult: %d", 0x0a, 0
len equ 8000 ; 02.txt fits into 8kb
str_forward db "forward", 0
str_up db "up", 0
str_down db "down", 0

section .bss
buffer resb len
ptr_buff resd 1
down_counter resd 1
up_counter resd 1
forward_counter resd 1
ptr_counter resd 1
ptr_command resd 1

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

    mov dword [up_counter], 0
    mov dword [down_counter], 0
    mov dword [forward_counter], 0

    ; char *token = strtok_r(buffer, delim_line, &ptr_buff)
    push ptr_buff
    push delim_line
    push buffer
    call strtok_r
    add esp, 12

    ; if token == NULL
    cmp eax, 0
    je .end_loop

    .loop:
        ; get the command name 
        ; char *cmd_token = strtok(token, delim_cmd)
        push delim_cmd
        push eax
        call strtok
        add esp, 8

        ; if cmd_token == NULL
        cmp eax, 0
        je .end_loop

        mov dword [ptr_command], eax

        ; get target counter from command name
        push dword [ptr_command]
        push str_forward
        call strcmp
        add esp, 8
        cmp eax, 0
        jne .end_forward
        mov dword [ptr_counter], forward_counter
        jmp .end_down
        .end_forward:

        push dword [ptr_command]
        push str_up
        call strcmp
        add esp, 8
        cmp eax, 0
        jne .end_up
        mov dword [ptr_counter], up_counter
        jmp .end_down
        .end_up:

        push dword [ptr_command]
        push str_down
        call strcmp
        add esp, 8
        cmp eax, 0
        jne .end_down
        mov dword [ptr_counter], down_counter
        .end_down:

        ; get the number
        ; cmd_token = strtok(NULL, delim_cmd)
        push delim_cmd
        push 0
        call strtok
        add esp, 8

        ; if cmd_token == NULL
        cmp eax, 0
        je .end_loop

        ; atoi(cmd_token)
        push eax
        call atoi
        add esp, 4

        ; add to counter
        mov ebx, [ptr_counter]
        add [ebx], eax

        ; token = strtok_r(NULL, delim_line, &ptr_buff)
        push ptr_buff
        push delim_line
        push 0
        call strtok_r
        add esp, 12

        ; if token == NULL
        cmp eax, 0
        je .end_loop

        jmp .loop

    .end_loop:

    ; depth
    mov dword ebx, [down_counter]
    sub dword ebx, [up_counter] ; depth decreases up...

    ; depth * forward
    mov eax, ebx
    mul dword [forward_counter]

    ; printf(out_str, fwd, depth, up, down, mult)
    push eax
    push dword [down_counter]
    push dword [up_counter]
    push ebx
    push dword [forward_counter]
    push out_str
    call printf
    add esp, 24

    ; exit
    mov eax, 1
    mov ebx, 0
    int 0x80
