all: obj/postfix.o
	
	gcc -m32 main.c obj/postfix.o -o test/prova


obj/postfix.o:
	as -32 src/postfix.s -o obj/postfix.o 
	ld -m elf_i386 -dynamic-linker /lib/ld_linux.so.2 obj/postfix.o -o bin/postfix

	

clear:
	rm  -f test/prova
	rm -r -f bin/*
	rm -r -f obj/*

exec:
	
	test/./prova in_1.txt out_1.txt
	
all2:
	gcc -c main.c -o obj/main.o
	gcc -m32 -elf_i386 obj/main.o obj/postfix.o -o bin/prova

run: clear all exec

all3:
	gcc -m32 -g main.c src/postfix.s -o test/postfix