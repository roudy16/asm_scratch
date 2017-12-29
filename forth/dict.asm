section .text

global find_word
global cfa
extern string_equals
extern string_length

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
    push rsi
    add rsi, 8
    call string_equals
    pop rsi
    test rax, rax
    jz .ret
.found:
    mov rax, rsi
.ret:
    pop rbx
    ret

cfa:
    push rbx
    add rdi, 8
    mov rbx, rdi
    call string_length
    add rbx, rax
    add rbx, 2
    mov rax, rbx
    pop rbx
    ret
