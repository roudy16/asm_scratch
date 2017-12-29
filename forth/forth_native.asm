%include "macros.inc"

%define pc r15
%define w r14
%define rstack r13

%define heap_size_cells 65536
%define heap_size_bytes (heap_size_cells * 8)
%define stack_size_cells 1024
%define stack_size_bytes (1024 * 8)
%define input_buf_size_bytes 1024

section .rodata

error_msg: db "An error occurred", 0
unk_word_msg: db "Unknown word", 0

section .bss

heap_start: resq heap_size_cells
resq (stack_size_cells - 1)
rstack_start: resq 1
input_buf: resb input_buf_size_bytes

section .data

dstack_start: dq 0
prog_stub: dq 0
xt_interpreter: dq .interpreter
.interpreter: dq interp_loop

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
_start:
    jmp init_impl

global next
next:
    mov w, [pc]
    add pc, 8
    jmp [w]
    
global docol
docol:
    sub rstack, 8
    mov [rstack], pc
    add w, 8
    mov pc, w
    jmp next

global exit
exit:
    mov pc, [rstack]
    add rstack, 8
    jmp next

native  '+', plus
    pop rax
    add [rsp], rax
    jmp next

native 'init', init
    mov rstack, rstack_start
    mov [dstack_start], rsp
    mov rax, [xt_interpreter]
    mov qword [prog_stub], rax
    mov pc, prog_stub
    jmp next

native 'drop', drop
    add rsp, 8
    jmp next

native 'bye', bye
    mov rax, 60
    xor rdi, rdi
    syscall

native 'mem', mem
    push qword heap_start
    jmp next

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

native '.S', .S
    mov rax, rsp
    push rbx
    mov rbx, [dstack_start]
.loop:
    cmp rax, rbx
    jge .end
    push rax
    mov rdi, [rax]
    call print_uint
    call print_newline
    pop rax
    inc rax
    jmp .loop
.end:
    pop rbx
    jmp next
    

interp_loop:
    mov rdi, input_buf
    mov rsi, input_buf_size_bytes
    call read_word
    test rax, rax
    jz exit_error
    mov rdi, rax
    push rdi
    call string_length
    pop rdi
    test rax, rax
    jz bye_impl ; normal exit
    push rdi
    mov rsi, words_last
    call find_word
    pop rdi
    test rax, rax
    jz .get_num
    mov rdi, rax
    call cfa
    mov [prog_stub], rax
    mov pc, prog_stub
    jmp next
.get_num:
    push rdi
    call parse_int
    pop rdi
    test rdx, rdx
    jz .unk_word
    push rax ; push integer to forth data stack
    jmp interp_loop
.unk_word:
    push rdi
    mov rdi, unk_word_msg
    call print_string
    call print_newline
    pop rdi
    call print_string
    call print_newline
    jmp interp_loop


exit_error:
    mov rdi, error_msg
    call print_string
    call print_newline
    mov rax, 60
    mov rdi, 1
    syscall
    