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

forth_state: dq 0 ; 0: interpreter mode, 1: compiler mode
dict_last_word: dq 0 ; ptr to last word in dictionary list
heap_first_free: dq 0 ; ptr to first free byte in forth mem
dstack_start: dq 0 ; base ptr for data stack
prog_stub: dq 0 ; used in interpreter mode to mark next execution token
xt_interpreter: dq .interpreter
.interpreter: dq interpreter_loop

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

native 'exit', exit
    mov pc, [rstack]
    add rstack, 8
    jmp next

native  '+', plus
    pop rax
    add [rsp], rax
    jmp next

native '-', minus
    pop rax
    sub [rsp], rax
    jmp next

native '*', mul
    pop rax
    imul rax, [rsp]
    mov [rsp], rax
    jmp next

native '/', div
    pop rcx
    xor rdx, rdx
    mov rax, [rsp]
    idiv rcx
    mov [rsp], rax
    jmp next

native '=', eq
    pop rax
    mov rcx, [rsp]
    push rax
    xor rdx, rdx
    cmp rcx, rax
    sete dl
    push rdx
    jmp next

native '<', less
    mov rax, [rsp]
    mov rcx, [rsp+1]
    xor rdx, rdx
    cmp rax, rcx
    setl dl
    push rdx
    jmp next

native 'and', and
    pop rax
    pop rcx
    test rax, rax
    setnz dl
    xor rax, rax
    test rcx, rcx
    setnz al
    and rdx, rdx
    push rdx
    jmp next

native 'not', not
    pop rax
    xor rdx, rdx
    test rax, rax
    setz dl
    push rdx
    jmp next

native 'drop', drop
    add rsp, 8
    jmp next

native 'dup', dup
    mov rax, [rsp]
    push rax
    jmp next

native 'swap', swap
    mov rax, [rsp]
    mov rdx, [rsp+8]
    mov [rsp+8], rax
    mov [rsp], rdx
    jmp next

native 'rot', rot
    mov rax, rsp
    mov rdx, [dstack_start]
    add rax, 8
    sub rdx, 8
    cmp rax, rdx
    jge .ret
    mov r9, [rsp]
    sub rdx, 8
    mov r8, [rax]
    mov [rax-8], r8
.loop:
    mov r8, [rax+8]
    mov [rax], r8
    cmp rax, rdx
    jge .ret1
    add rax, 8
    jmp .loop
.ret1:
    mov [rdx+8], r9
.ret:
    jmp next

native '.', dot
    pop rdi
    call print_int
    call print_newline
    jmp next

native 'key', key
    call read_char
    push rax
    jmp next

native 'emit', emit
    pop rdi
    call print_char
    jmp next

native 'number', number
    mov rdi, input_buf
    mov rsi, input_buf_size_bytes
    call read_word
    mov rdi, input_buf
    call parse_int
    push rax
    jmp next

native 'bye', bye
    mov rax, 60
    xor rdi, rdi
    syscall

native 'mem', mem
    push qword heap_start
    jmp next

native '!', memsetq
    pop rdx
    pop rax
    mov [rax], rdx
    jmp next

native 'c!', memsetb
    pop rdx
    pop rax
    mov [rax], dl
    jmp next

native '@', memgetq
    mov rax, [rsp]
    mov rdx, [rax]
    mov [rsp], rdx
    jmp next

native 'c@', memgetb
    xor rdx, rdx
    mov rax, [rsp]
    mov dl, byte [rax]
    mov [rsp], rdx
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
    call print_int
    call print_newline
    pop rax
    add rax, 8
    jmp .loop
.end:
    pop rbx
    jmp next

native ':', col
    mov rdi, input_buf
    mov rsi, input_buf_size_bytes
    call read_word
    test rax, rax
    jz exit_error
    mov rdi, input_buf
    push rdi
    call string_length
    mov rsi, [heap_first_free]
    mov r8, dict_last_word
    mov r9, [r8]
    mov [rsi], r9 ; set ptr to prev word in dict list
    mov [r8], rsi ; update dict_last_word to this new word
    add rsi, 8
    pop rdi ; ptr to word in input_duf
    push rsi
    push rax
    mov rdx, rax ; length of word in input_buf
    inc rdx ; account for null char
    call string_copy ; copy the input word to new word entry in heap
    pop rax
    pop rsi
    add rsi, rax ; ptr to one past end of new word string
    mov qword [rsi], docol
    add rsi, 8
    mov qword [forth_state] , 1 ; set state to indicate 'compiler' mode
    mov [heap_first_free], rsi
    jmp next

native ';', semicol
    mov rdx, [forth_state] ; check state flag to see if we're in compile mode
    test rdx, rdx
    jz next ; do nothing if we're in interpreter mode
    mov rax, heap_first_free
    mov qword [rax], xt_exit
    add rax, 8
    mov [heap_first_free], rax
    mov qword [forth_state], 0
    jmp next

colon 'or', or
    dq xt_not
    dq xt_not
    dq xt_swap
    dq xt_not
    dq xt_not
    dq xt_plus
    dq xt_not
    dq xt_not
    dq xt_exit

colon '>', greater
    dq xt_swap
    dq xt_less
    dq xt_exit


section .text

interpreter_loop:
    mov rax, [forth_state] ; check state flag to see if we're in compile mode
    test rax, rax
    jnz compiler_loop
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
    jmp interpreter_loop
.unk_word:
    push rdi
    mov rdi, unk_word_msg
    call print_string
    call print_newline
    pop rdi
    call print_string
    call print_newline
    jmp interpreter_loop

compiler_loop:


exit_error:
    mov rdi, error_msg
    call print_string
    call print_newline
    mov rax, 60
    mov rdi, 1
    syscall
    
; This entry needs to be the last of the file so that the address
; of 'words_last' is properly set to the end of the dictionary list
native 'init', init
    mov qword [forth_state], 0
    mov qword [dict_last_word], words_last
    mov qword [heap_first_free], heap_start
    mov rstack, rstack_start
    mov [dstack_start], rsp
    mov rax, [xt_interpreter]
    mov qword [prog_stub], rax
    mov pc, prog_stub
    jmp next
