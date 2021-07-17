; Author: Wil Keller
; File: vigenere.asm
; Description: an x86-64 program to encode/decode text from a user
; specified input file using key data from a user specified keyfile, and
; outputting the result into a user specified output file. This is my
; 2nd ASM program, and, at the start of this, seems a little over my
; head. The way I want to implement this will require argument parsing
; and file I/O handling, as a minimum. This will take some doing. 
; Date started: 16 JUL 21
; Assembler: Netwide (NASM)

; Build using these commands: 
; nasm -f elf -g -F dwarf vigenere.asm
; ld -o vigenere vigenere.o
;

section .data ; Section containing initialized data (i.e. variables)
section .bss ; Section containing UNinitialized data
section .text ; Section containing code 

    global _start
    
_start:
    nop
; insert code between nops


; exit program gracefully
    exit:   mov rax, 60    ; specify terminate sys_call
            mov rdi, 0      ; pass 0 code ("success") to OS.
            syscall         ; call sys_exit 
; insert code between nops
    nop


