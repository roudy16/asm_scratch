AFLAGS=-felf64
ASM=nasm

all: forth

forth: lib.o dict.o forth.o
	ld -o forth forth.o dict.o lib.o

forth.o: forth_native.asm macros.inc
	$(ASM) $(AFLAGS) forth_native.asm -o forth.o

main: main.o dict.o lib.o
	ld -o main main.o dict.o lib.o

main.o: main.asm macros.inc
	$(ASM) $(AFLAGS) main.asm

lib.o: lib.asm 
	$(ASM) $(AFLAGS) lib.asm

dict.o: dict.asm 
	$(ASM) $(AFLAGS) dict.asm


clean:
	rm -f main.o lib.o dict.o main forth.o forth
