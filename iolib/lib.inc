section .data
_word: db 'anus ', 10, 0

global _start 
_start:
    mov rdi, word_buffer
    mov rsi, 10
    call read_word
    mov rdi, rax
    call print_string
    call print_newline
    mov rdi, word_buffer
    mov rsi, 10
    call read_word
    mov rdi, rax
    call print_string
    call print_newline

    mov rdi, 0
    mov rax, 60
    syscall

section .text

string_length:
    xor rax, rax
loop:
    mov rsi, [rdi + rax]
    and rsi, 0xff
    test rsi, rsi
    jz done
    inc rax
    jmp loop
done:
    ret

print_string:
    push rdi
    call string_length
    pop rdi
    mov rsi, rdi
    mov rdx, rax
    mov rax, 1
    mov rdi, 1
    syscall
    xor rax, rax
    ret

print_char:
    and rdi, 0xff
    push rdi
    mov rax, 1
    mov rdi, 1
    mov rsi, rsp
    mov rdx, 1
    syscall
    pop rdi
    xor rax,rax
    ret

print_newline:
    mov rdi, 0xA
    call print_char
    xor rax, rax
    ret

print_uint:
    mov rax, rdi
    xor r8, r8
    cmp rax, 0
    je .zero
    mov rcx, 10
.loop:
    xor rdx, rdx
    div rcx
    add rdx, 0x30
    push rdx
    inc r8
    test rax, rax
    jz .dump
    jmp .loop
.zero:
    mov rdi, '0'
    push rdi
    inc r8
.dump:
    pop rdi
    dec r8
    call print_char
    test r8, r8
    jnz .dump
.ret:
    xor rax, rax
    ret

print_int:
    cmp rdi, 0
    jg .uint
    push rdi
    mov rdi, '-'
    call print_char 
    pop rdi
    neg rdi
.uint:
    call print_uint
.ret:
    xor rax, rax
    ret

string_equals:
    xor rax, rax
    ret

read_char:
    mov rax, 0
    mov rdi, 0
    push rax
    mov rsi, rsp
    mov rdx, 1
    syscall 
    pop rdi
    test rax, rax
    jz .ret
    mov rax, [rsi]
.ret:
    ret 

section .data
word_buffer times 256 db 0

section .text

read_word:
    test rsi, rsi
    jz .ret
    push rbx
    push r12
    push r13
    xor r12, r12
    mov r13, rdi
    mov rbx, rsi
    dec rbx

.skip:
    cmp r12, rbx
    jge .oret
    call read_char
    test rax, rax
    jz .oret
    cmp rax, 0x20
    je .skip
    cmp rax, 0x9
    je .skip
    cmp rax, 0xA
    je .skip
    mov byte [r13 + r12], al
    inc r12

.loop:
    cmp r12, rbx
    jge .oret
    call read_char
    test rax, rax
    jz .oret
    cmp rax, 0x20
    je .oret
    cmp rax, 0x9
    je .oret
    cmp rax, 0xA
    je .oret
    mov byte [r13 + r12], al
    inc r12
    jmp .loop

.oret:
    mov byte [r13 + r12], 0
    mov rax, r13
    mov rdx, r12
    pop r13
    pop r12
    pop rbx
.ret:
    ret

; rdi points to a string
; returns rax: number, rdx : length
parse_uint:
    xor rax, rax
    ret

; rdi points to a string
; returns rax: number, rdx : length
parse_int:
    xor rax, rax
    ret 


string_copy:
    ret