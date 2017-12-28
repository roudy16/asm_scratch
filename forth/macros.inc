%define words_last 0

%macro native 3
section .data
w_ %+ %2:
    dq words_last
    db %1, 0
    db %3
xt_ %+ %2:
    dq %2 %+ _impl

section .text
%2 %+ _impl:

%define words_last w_ %+ %2
%endmacro

%macro native 2
native %1, %2, 0
%endmacro

%macro colon 3
section .data
w_ %+ %2:
    dq words_last
    db %1, 0
    db %3
xt_ %+ %2:
    dq docol

%define words_last w_ %+ %2
%endmacro

%macro colon 2
colon %1, %2, 0
%endmacro
