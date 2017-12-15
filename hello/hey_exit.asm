section .data
message: db 'hey, Earth', 10

section .text
global _start

_start:
    mov rax, 1
    mov rdi ,1
    mov rsi, message
    mov rdx, 14
    syscall

    mov rax, 60
    mov rdi, 66
    syscall
