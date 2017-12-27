section .text

global find_word
extern string_equals

find_word:
    push rbx
.loop:
    mov rbx, [rsi]
    test rbx, rbx
    jz .final
    push rsi
    add rsi, 8
    push rdi
    call string_equals
    pop rdi
    pop rsi
    cmp rax, 1
    je .found
    mov rsi, rbx
    jmp .loop
.final:
    mov rbx, rsi
    add rsi, 8
    call string_equals
    test rax, rax
    jz .ret
.found:
    mov rax, rsi
.ret:
    pop rbx
    ret
