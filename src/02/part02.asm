; advent of code 2021 - day 2, part 2
; https://adventofcode.com/2021/day/2
;
; run:
; nasm -f elf32 part02.asm -o part02.o && gcc -m32 part02.o -o part02.out && ./part02.out

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
out_str db "fwd: %d, depth: %d, mult: %d", 0x0a, 0
len equ 8000 ; 02.txt fits into 8kb
str_forward db "forward", 0
str_up db "up", 0
str_down db "down", 0
str_test db "cmd: %d, val: %d", 0x0a, 0

section .bss
buffer resb len
ptr_buff resd 1
depth_counter resd 1
forward_counter resd 1
aim_counter resd 1
ptr_command resd 1
cmd_num resb 0

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

    mov dword [depth_counter], 0
    mov dword [aim_counter], 0
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

        ; save command number before
        ; the ptr gets freed by strtok
        push dword [ptr_command]
        push str_forward
        call strcmp
        add esp, 8
        cmp eax, 0
        jne .end_cmd_forward
        mov byte [cmd_num], 0
        jmp .end_cmd_down
        .end_cmd_forward:

        push dword [ptr_command]
        push str_up
        call strcmp
        add esp, 8
        cmp eax, 0
        jne .end_cmd_up
        mov byte [cmd_num], 1
        jmp .end_cmd_down
        .end_cmd_up:

        push dword [ptr_command]
        push str_down
        call strcmp
        add esp, 8
        cmp eax, 0
        jne .end_cmd_down
        mov byte [cmd_num], 2
        .end_cmd_down:

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

        ; handle commands
        cmp byte [cmd_num], 0
        jne .end_forward
        add dword [forward_counter], eax
        mul dword [aim_counter]
        add dword [depth_counter], eax
        jmp .end_down
        .end_forward:

        cmp byte [cmd_num], 1
        jne .end_up
        sub dword [aim_counter], eax
        jmp .end_down
        .end_up:

        cmp byte [cmd_num], 2
        jne .end_down
        add dword [aim_counter], eax
        .end_down:

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

    ; fwd * depth
    mov eax, [forward_counter]
    mul dword [depth_counter]

    ; printf(out_str, fwd, depth, mult)
    push eax
    push dword [depth_counter]
    push dword [forward_counter]
    push out_str
    call printf
    add esp, 16

    ; exit
    mov eax, 1
    mov ebx, 0
    int 0x80
