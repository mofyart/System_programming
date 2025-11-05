AS=fasm
CC=gcc

all: main

main: main.c DZ1.o
	$(CC) main.c DZ1.o -o main

DZ1.o: DZ1.asm
	$(AS) DZ1.asm DZ1.o

clean:
	rm -f main DZ1.o
