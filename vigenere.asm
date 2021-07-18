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
    inFile:     dq  0 
    keyFile:    dq  0 
    outFile:    dq  0
    keyST:      dq  0
    inDesc:     dq  0
    keyDesc:    dq  0
    outDesc:    dq  0

section .bss ; Section containing UNinitialized data
;   reserve buffers for input data, key data, and output data
    inp:    resb 1          ; implement input buffer
    key:    resb 1          ; implement keytext buffer
    out:    resb 1          ; implement output buffer

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
            pop r13         ; pops argv[3], the key filename, to r13
            pop r14         ; pops argv[4], the output filename, to r14

; implement argument handling checks; error if too few or too many args in argc
;           cmp ???         ; control to prevent processing too many arguments 
;           jmp ???         ; jump as appropriate based on error handling checks

; save filenames to variables to free registers
            mov qword [inFile], r12
            mov qword [keyFile], r13
            mov qword [outFile], r14
            mov qword [keyST], r13  ; to ensure the start of the keyfile can be found later if sysread==0

; open input and key files; initialize output file
            mov rax, 2                  ; specify sys_open call in rax
            mov rdi, qword [inFile]     ; specify infile for sys_open call
            mov rsi, 000000q            ; specify read-only
            syscall
            cmp rax, 0                  ; check for success/fail
            jl  exit                    ; exit if failure
            mov qword [inDesc], rax     ; save input file descriptor

            mov rax, 2                  ; specify sys_open call in rax
            mov rdi, qword [keyFile]    ; specify keyfile for sys_open call
            mov rsi, 000000q            ; ensure rsi is still set for read-only
            syscall
            cmp rax, 0                  ; check for success/fail
            jl  exit                    ; exit if failure
            mov qword [keyDesc], rax    ; save key file decriptor

            mov rax, 85                 ; specify sys_create call in rax
            mov rdi, qword [outFile]    ; create output file
            mov rsi, 000001q            ; specify write-only
            syscall
            cmp rax, 0                  ; check for success/fail
            jl  exit                    ; exit if failure
            mov qword [outDesc], rax    ; save output file descriptor

; construct file I/O errors. Consider each of the cmp rax, jl sequences above. 


; read input file and key file into buffers. 

; check encode/decode status, jmp as appropriate

; encode operations

; decode operations

; exit program gracefully
    exit:   mov rax, 3                  ; specify close file sys_call
            mov rdi, qword [inFile]     ; specify file to close
            syscall
            mov rax, 3                  ; specify file close sys_call
            mov rdi, qword [keyFile]    ; specify file to close
            syscall
            mov rax, 3                  ; specify file close sys_call
            mov rdi, qword [outFile]    ; specify file to close
            syscall
            mov rax, 60                 ; specify terminate sys_call
            mov rdi, 0                  ; pass 0 code ("success") to OS.
            syscall                     ; call sys_exit 


; insert code between nops
    nop


