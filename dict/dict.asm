section .text

global find_word
extern string_equals

find_word:
    push rbx
.loop:
    mov rbx, [rsi]
    test rbx, rbx
    jz .final
    lea rsi, [rbx+8]
    push rdi
    call string_equals
    cmp rax, 1
    je .found
    pop rdi
    mov rsi, [rbx]
    jmp .loop
.final:
    mov rbx, rsi
    add rsi, 8
    call string_equals
    test rax, rax
    jz .ret
.found:
    mov rax, rbx
.ret:
    pop rbx
    ret
