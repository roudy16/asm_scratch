section .text
%include "colon.inc"

section .rodata
%include "words.inc"

myword: db "first word", 0

section .text

extern find_word

global _start
_start:
    mov rdi, colon_last
    mov rsi, myword
    call find_word
    
    ; exit
    mov rdi, 0
    mov rax, 60,
    syscall
