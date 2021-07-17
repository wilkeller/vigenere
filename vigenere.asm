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

section .text ; Section containing code 

    global _start
    
_start:
    nop
; insert code between nops

; store CLI arguments for use
;   I need to be able to handle four distinct arguments:
;   -e or -d for decode, inp filename, key filename, out filename
;   ATM, use 4 distinct registers for argv, +1 for argc
            pop rdi         ; pops argc from the stack to rdi
; I should be able to keep right on popping; pop increments RSP. 
; If my understanding of the stack is correct, the first "item"
; should be argc, the next should be argv[0], which is the name
; and path of the executable, and each subsequent item should argv[]++.
; I'll have to monkey with this, though, and see if these are being stored
; as 64-bit values or not. 
            pop r15         ; pops argv[0] to r15
            pop r14         ; pops argv[1], the encode/decode switch, to r14
            pop rsi         ; pops argv[2], the input filename, to rsi
            pop r13         ; pops argv[3], the key filename, to r13
            pop r12         ; pops argv[4], the output filename, to r12
; A'ight. Back from a brief test. This DOES work as intended. Done for the night, though.


;            mov r11, rdi    ; move argc to r11 for later
;            mov r12, rsi    ; should move argv[0] to r12
;            mov rax, 1      ; use rax as a step counter thru r12 memory
;            mov r13, qword [r12+r10*8]  ; should move argv[1] to r13
;            inc rax         ; increment step counter
;            mov r14, qword [r12+r10*8]  ; should move argv[2] to r14
;            inc rax        ; increment step counter
;            mov r15, qword [r12+r10*8]  ; should move argv[3] to r15
;            cmp rax, r11    ; compare current argv position against # of argv[]
; I intend the above line as a placeholder to be followed with a jmp as appropriate
; for error handling or other such. 
            jmp exit

; exit program gracefully
    exit:   mov rax, 60    ; specify terminate sys_call
            mov rdi, 0      ; pass 0 code ("success") to OS.
            syscall         ; call sys_exit 
; insert code between nops
    nop


