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
; nasm -f elf64 -g -F dwarf vigenere.asm
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
    inpbuf:    resb 1          ; implement input buffer
    keybuf:    resb 1          ; implement keytext buffer
    outbuf:    resb 1          ; implement output buffer
    switchbuf: resw 1          ; implement encode/decode buffer

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

; save filenames to variables in order to free registers
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
            jl  errex                   ; exit if failure
            mov qword [inDesc], rax     ; save input file descriptor

            mov rax, 2                  ; specify sys_open call in rax
            mov rdi, qword [keyFile]    ; specify keyfile for sys_open call
            mov rsi, 000000q            ; ensure rsi is still set for read-only
            syscall
            cmp rax, 0                  ; check for success/fail
            jl  errex                   ; exit if failure
            mov qword [keyDesc], rax    ; save key file decriptor

;            mov rax, 85                 ; specify sys_create call in rax
 ;           mov rdi, qword [outFile]    ; create output file
  ;          mov rsi, 000001q            ; specify write-only
   ;         syscall
    ;        cmp rax, 0                  ; check for success/fail
     ;       jl  errex                   ; exit if failure
      ;      mov qword [outDesc], rax    ; save output file descriptor
            jmp read                    ; jump to read

; construct file I/O errors. Consider each of the cmp rax, jl sequences above. 
; File I/O errors also need to cover return <0 rax from read operations below and above
    serr0:  jmp exit                    ; placeholder, error is unexpected switch value (not -e or -d)

; read input file and key file into buffers. 
    read:   mov rax, 0                  ; specify x64 sys_read call
            mov rdi, qword [inDesc]     ; specify input file descriptor to read from
            mov rsi, inpbuf             ; pass address of input buffer to read to
            mov rdx, 1                  ; specify one byte to read (i.e. one ASCII char)
            syscall
            cmp rax, 0                  ; compare sys_call read value to 0
            je  exit                    ; if rax==0, jump to exit, else proceed
    reread: mov rax, 0                  ; specify x64 sys_read call
            mov rdi, qword [keyDesc]    ; specify key file descriptor to read from
            mov rsi, keybuf             ; pass address of key buffer to read to
            mov rdx, 1                  ; specify one byte to read (i.e. one ASCII char)
            syscall                     
; need to rework flow control somewhere hereabouts to bypass edcheck on subsequent (re)reads
            cmp rax, 0                  ; compare sys_call read value to 0
            jne edcheck                 ; if sys_call NOT 0, go to edcheck, else proceed
            mov rax, 8                  ; specify sys_lseek call 
            mov rdi, qword [keyDesc]    ; specify keyfile file descriptor
            mov rsi, 0                  ; move read point zero bytes from origin
            mov rdx, 0                  ; set origin point as begin [values: begin=0, current=1, EOF=2]
            syscall
            jmp reread                  ; jump to reread and acquire new key character

; check encode/decode status, jmp as appropriate
   edcheck: mov rdi, switchbuf          ; pass buffer address to rdi
            mov rsi, r15                ; pass encode/decode address to rsi
            mov rcx, 0                  ; move 0 into rcx... just in case
            movsw                       ; move argv[1] to switchbuf
            cmp word [switchbuf], 652dh ; compare the switch buffer contents to ASCII -e
            je encode                   ; if equal to -e, jump to encode
            cmp word [switchbuf], 642dh ; compare contents of switchbuf to ASCII -d
            je  decode                  ; if equal, jump to decode 
            jmp serr0                   ; else jump to switch error 0 
            

; encode operations
    encode: jmp exit                    ; placeholder

; decode operations
    decode: jmp exit                    ; placeholder

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

; error exit
    errex:  mov rax, 3                  ; specify close file sys_call
            mov rdi, qword [inFile]     ; specify file to close
            syscall
            mov rax, 3                  ; specify file close sys_call
            mov rdi, qword [keyFile]    ; specify file to close
            syscall
            mov rax, 3                  ; specify file close sys_call
            mov rdi, qword [outFile]    ; specify file to close
            syscall
            mov rax, 60                 ; specify terminate sys_call
            mov rdi, 1                  ; pass 1 code ("error") to OS.
            syscall                     ; call sys_exit 

; insert code between nops
    nop


