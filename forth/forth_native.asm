%include "macros.inc"

%define pc r15
%define w r14
%define rstack r13

section .bss
resq 1023
rstack_start: resq 1
input_buf: resb 1024

section .data

xt_main:
    dq docol_impl
    dq xt_inbuf
    dq xt_word
    dq xt_drop
    dq xt_inbuf
    dq xt_prints
    dq xt_bye

prog_stub: dq xt_main

section .text

extern string_length
extern print_string
extern print_char
extern print_newline
extern print_uint
extern print_int
extern read_char
extern read_word
extern parse_uint
extern parse_int
extern string_equals
extern string_copy
extern find_word
extern cfa

global _start
global next
next:
    mov w, [pc]
    add pc, 8
    jmp [w]
    
native  '+', plus
    pop rax
    add [rsp], rax
    jmp next

native 'init', init
    mov rstack, rstack_start
    mov pc, prog_stub
    jmp next

native 'drop', drop
    add rsp, 8
    jmp next

native 'exit', exit
    mov pc, [rstack]
    add rstack, 8
    jmp next

native 'bye', bye
    mov rax, 60
    xor rdi, rdi
    syscall

native 'inbuf', inbuf
    push qword input_buf
    jmp next

native 'word', word
    pop rdi
    mov rsi, 1024
    call read_word
    push rax
    jmp next

native 'prints', prints
    pop rdi
    call print_string
    jmp next

native 'docol', docol
    sub rstack, 8
    mov [rstack], pc
    add w, 8
    mov pc, w
    jmp next

_start:
    jmp init_impl
