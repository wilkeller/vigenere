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
;   reserve buffers for input data, key data, and output data
    BUFFLEN equ 1024        ; specify buffer size
    Inp:    resb BUFFLEN    ; implement input buffer
    key:    resb BUFFLEN    ; implement keytext buffer
    out:    resb BUFFLEN    ; implement output buffer

section .text ; Section containing code 

    global _start
    
_start:
    nop
; insert code between nops

; store CLI arguments for use
;   I need to be able to handle four distinct arguments:
;   -e or -d for decode, inp filename, key filename, out filename
; remember that if Jorgensen isn't a liar (again), I'll need rax, rdi, rsi, and rdx for file I/O.
            pop r11         ; pops argc from the stack to r11
            pop r15         ; pops argv[0] to r15
            pop r15         ; pops argv[1], the encode/decode switch, to r15
            pop r12         ; pops argv[2], the input filename, to r12
            pop r14         ; pops argv[3], the key filename, to r13
            pop r13         ; pops argv[4], the output filename, to r12


;           cmp ???         ; control to prevent processing too many arguments 
; I intend the above line as a placeholder to be followed with a jmp as appropriate
            jmp exit

; exit program gracefully
    exit:   mov rax, 60    ; specify terminate sys_call
            mov rdi, 0      ; pass 0 code ("success") to OS.
            syscall         ; call sys_exit 
; insert code between nops
    nop


