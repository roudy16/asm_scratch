%define colon_last 0

%macro colon 2
  %define colon_cur %%colon_last

colon_cur:
  dq colon_last
  db %1, 0
  xt_ %+ %2:

  %define colon_last colon_cur

%endmacro 
