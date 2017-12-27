section .text
%include "colon.inc"

section .rodata
%include "words.inc"

error: db "Word not found", 0

section .text

extern find_word
extern read_word
extern print_string
extern print_newline
extern string_length

global _start
_start:
    push rbp
    mov rbp, rsp
    sub rsp, 256
    mov rdi, rsp
    mov rsi, 256
    call read_word
    mov rdi, rax
    mov rsi, colon_last
    call find_word
    test rax, rax
    jz .error
    add rax, 8
    mov rdi, rax
    push rax
    call string_length
    pop rdi
    add rdi, rax
    inc rdi
    call print_string
    call print_newline
    ; exit
    mov rsp, rbp
    pop rbp
    mov rdi, 0
    mov rax, 60
    syscall
.error:
    mov rdi, error
    call print_string
    call print_newline
    ; exit
    mov rsp, rbp
    pop rbp
    mov rdi, 0
    mov rax, 60
    syscall
