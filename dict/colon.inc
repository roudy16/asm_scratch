%define colon_last 0

%macro colon 2

%%colon_last:
  dq colon_last
  db %1, 0
  xt_ %+ %2:

  %define colon_last %%colon_last

%endmacro 

