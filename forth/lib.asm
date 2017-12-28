section .data
_word0: db 'smells', 0
_word1: db 'smellss', 0
_num: db '-143',0
word_buffer times 256 db 0

global string_length:
global print_string:
global print_char:
global print_newline:
global print_uint:
global print_int:
global read_char:
global read_word:
global parse_uint:
global parse_int:
global string_equals:
global string_copy:

section .text

string_length:
    xor rsi, rsi
    xor rax, rax
.loop:
    mov sil, byte [rdi + rax]
    test rsi, rsi
    jz .done
    inc rax
    jmp .loop
.done:
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
    jge .uint
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
    xor rsi, rsi
    mov rcx, 10
.loop:
    mov r8, [rdi + rsi]
    and r8, 0xff
    cmp r8, 0x30 ; '0'
    jl .ret
    cmp r8, 0x39 ; '9'
    jg .ret
    sub r8, 0x30
    mul rcx
    add rax, r8
    inc rsi
    jmp .loop
.ret:
    lea rdx, [rsi]
    ret

; rdi points to a string
; returns rax: number, rdx : length
parse_int:
    xor rax, rax
    xor rsi, rsi
    mov rcx, 10
    mov r8, [rdi + rsi]
    and r8, 0xff
    cmp r8, 0x2b ; '+'
    je .skip
    cmp r8, 0x2d ; '-'
    je .nskip
    sub r8, 0x30
    mul rcx
    add rax, r8
.skip:
    inc rsi
.ploop:
    mov r8, [rdi + rsi]
    and r8, 0xff
    cmp r8, 0x30 ; '0'
    jl .ret
    cmp r8, 0x39 ; '9'
    jg .ret
    sub r8, 0x30
    mul rcx
    add rax, r8
    inc rsi
    jmp .ploop
.nskip:
    inc rsi
.nloop:
    mov r8, [rdi + rsi]
    and r8, 0xff
    cmp r8, 0x30 ; '0'
    jl .ret
    cmp r8, 0x39 ; '9'
    jg .ret
    sub r8, 0x30
    mul rcx
    sub rax, r8
    inc rsi
    jmp .nloop
.ret:
    lea rdx, [rsi]
    ret 

string_equals:
    xor rax, rax
    xor rcx, rcx
.loop:
    mov r8, [rdi + rcx]
    mov r9, [rsi + rcx]
    and r8, 0xff
    and r9, 0xff
    cmp r8, r9
    jne .ret0
    test r8, r8
    jz .ret1
    inc rcx
    jmp .loop
.ret1:
    mov rax, 1
.ret0:
    ret

string_copy:
    xor r8, r8
    xor rax, rax
.loop:
    mov r8b, byte [rdi + rax]
    test r8, r8
    jz .done
    inc rax
    jmp .loop
.done:
    inc rax
    cmp rax, rdx
    jg .ret0
    xor rax, rax
.loop2:
    mov r8b, byte [rdi + rax]
    mov byte [rsi + rax], r8b
    test r8, r8
    jz .ret
    inc rax
    jmp .loop2
.ret0:
    xor rax, rax
.ret:
    ret

