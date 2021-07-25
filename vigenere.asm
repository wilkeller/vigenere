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

section .data ; section containing initialized data (i.e. variables)
    defswitch:  dw  0   ; switch for decode (642dh), encode (652dh), or format (662dh)
    argct:      db  0   ; argc value
    if:         dq  0   ; name of input file
    kf:         dq  0   ; name of key file
    of:         dq  0   ; name of output file
    id:         dq  0   ; input file descriptor
    od:         dq  0   ; output file descriptor
    kd:         dq  0   ; key file descriptor

section .bss ; Section containing UNinitialized data
    ib:        resb 1   ; input buffer
    kb:        resb 1   ; key buffer
    ob:        resb 1   ; output buffer

section .text ; section containing code

    global _start

_start:
    nop
; insert code between nops 

; commandline argument handling
        pop byte [argct]                ; pops argc from the stack to argct
        pop r15                         ; pops argv[0], the file execution path, to r15
        xor r15, r15                    ; clear r15
        cmp byte [argct], 3             ; see if at least 4 args were passed in
        jb  argclow                     ; if false, jump to error argclow:
        pop word [defswitch]            ; pops argv[1], the mode switch, to defswitch
        pop qword [if]                  ; pop argv[2], the input filename, to if
        cmp word [defswitch], 662dh     ; see if mode switch is set to format
        je  format                      ; if yes, jump to format mode, else, continue
        cmp byte [argct], 4             ; check to see if all 5 arguments are present
        jbe argclow                     ; if not enough args, jump to error argclow:
        pop qword [kf]                  ; pop argv[3], the keyfile name, to kf
        pop qword [of]                  ; pop argv[4], the output file name, to of
        jmp open                        ; jump to open: section
        
; handle file formatting functions
    format: cmp byte [argct], 3         ; check to see how many args were passed
            ja  argchi                  ; if too many, jump to error argchi:      
            pop qword [of]              ; pop argv[3], the output file name, to of

            mov rax, 2                  ; specify sys_open syscall
            mov rdi, qword [if]         ; specify input file for sys_open call
            mov rsi, 0                  ; specify read-only
            syscall
            cmp rax, 0                  ; check for file open success
            jb  operr                   ; if failure, jump to error operr:
            mov qword [id], rax         ; store input file descriptor
            
            mov rax, 85                 ; specify sys_create syscall
            mov rdi, qword [of]         ; create output file
            mov rsi, 2                  ; specify read-write permission
            syscall
            cmp rax, 0                  ; check for success
            jb  operr                   ; if failure, jump to error operr:
            mov qword [od], rax         ; save output file descriptor

    fread:  mov rax, 0                  ; specify sys_read syscall
            mov rdi, qword [id]         ; specify input file descriptor
            mov rsi, ib                 ; pass address of input buffer to sys_read
            mov rdx, 1                  ; read one byte (one ASCII character)
            syscall
            cmp rax, 0                  ; check for empty input file
            je  exit                    ; if input file = empty, jump to exit
            cmp rax, 0                  ; check for read errors
            jb  rerr                    ; if rax < 0, jump to error rerr: else proceed
    inform: ; ALL ACTUAL FORMATTING HAPPENS HERE
            ; check for lowercase chars (ASCII 97d - 122d)
            ; if lower, -20h / 32d to convert to upper
            ; check for uppercase chars (ASCII 65d - 90d)
            ; if upper, jmp to fwrite:
            ; if anything else, skip fwrite and loop back to read
    fwrite: mov rax, 1                  ; specify sys_write syscall
            mov rdi, qword [of]         ; specify file output descriptor
            mov rsi, ib                 ; pass address of character to write
            mov rdx, 1                  ; write one byte (one ASCII character)
            syscall
            cmp rax, 0                  ; check for error
            jb  wrerr                   ; if rax < 0, jump to error wrerr:
            jmp fread                   ; else, pick up next char for formatting

; handle -d/-e file open/read operations
    open:   mov rax, 2                  ; specify sys_open syscall
            mov rdi, qword [if]         ; specify input file for sys_open call
            mov rsi, 0                  ; specify read-only
            syscall
            cmp rax, 0                  ; check for file open success
            jb  operr                   ; if failure, jump to error operr:
            mov qword [id], rax         ; store input file descriptor

            mox rax, 2                  ; specify sys_open syscall
            mov rdi, qword [kf]         ; specify key file for sys_open call
            mov rsi, 0                  ; specify read-only
            syscall
            cmp rax, 0                  ; check for file open success
            jb  operr                   ; if failure, jump to error operr:
            mov qword [kd], rax         ; store key file descriptor

            mov rax, 85                 ; specify sys_create syscall
            mov rdi, qword [of]         ; create output file
            mov rsi, 2                  ; specify read-write permission
            syscall
            cmp rax, 0                  ; check for success
            jb  operr                   ; if failure, jump to error operr:
            mov qword [od], rax         ; save output file descriptor
    deread: mov rax, 0                  ; specify sys_read syscall
            mov rdi, qword [id]         ; specify input file descriptor
            mov rsi, ib                 ; pass address of input buffer to sys_read
            mov rdx, 1                  ; read one byte (one ASCII character)
            syscall
            cmp rax, 0                  ; check for empty input file
            je  exit                    ; file empty; jump to exit
            cmp rax, 0                  ; check for read error
            jb  rerr                    ; jump to error rerr:
            ; include uppercase checking here, throwing errors on unexpected chars
    reread: mov rax, 0                  ; specify sys_rad syscall
            mov rdi, qword [kd]         ; specify keyfile descriptor
            mov rsi, kb                 ; specify key file descriptor
            mov rdx, 1                  ; specify one byte read (one ASCII character)
            syscall                     
            cmp rax, 0                  ; check for read error
            jb  rerr                    ; if rax < 0, jump to error rerr:
            ; include uppercase checking here, throwing errors on unexpected chars
            cmp rax, 0                  ; if rax > 0, jump to swchk
            mov rax, 8                  ; specify lseek sys_call
            mov rdi, qword [kd]         ; specify key file descriptor
            mov rsi, 0                  ; move read pt zero bytes from origin
            mov rdx, 0                  ; set origin pt (0=begin, 1=current, 2=EOF)
            syscall
            jmp reread                  ; jump to reread, start key read from beginning 

; switch check
    swchk:  cmp word [defswitch], 642dh ; check if defswitch = -d
            je  decode                  ; jump to decode section
            cmp word [defswitch], 652dh ; check if defswitch = -e
            je  encode                  ; jump to encode section
            cmp word [defswitch], 662dh ; check if defswitch = -f
            je  format                  ; jump to format section
            jmp swerr                   ; else, jump to error swerr:
  
; handle file encode operations
    encode: mov bl, 65d                 ; move the ASCII offset into BL 
            sub byte [ib], bl           ; subtract the offset from the input buffer
            sub byte [kb], bl           ; subtract the offset from the key buffer
            xor rax, rax                ; clear register rax
            mov al, 26d                 ; move 26d (number of ASCII upper characters) into AL
            mov bh, byte [kb]           ; move key char to BH
            add byte [ib], bh           ; add key char to input char 
           idiv byte [ib]               ; apply modulo
            add ah, bl                  ; add ASCII offset to modulo result
            mov byte [ob], ah           ; move encoded char to output buffer
            jmp write                   ; proceed to write operations

; handle file decode functions
    decode: 

; handle -d/-e file ouput operations
    write:  mov rax, 1                  ; specify x64 sys_write call
            mov rdi, qword [of]         ; specify output file descriptor 
            mov rsi, outbuf             ; pass memory address of character to write
            mov rdx, 1                  ; specify number of characters to write
            syscall                     
            cmp rax, 0                  ; compare result of sys_write against 0
            jl wrerr                    ; jump to write error 0 if negative code returned
            jmp deread                  ; pickup next character for encoding
 
         
; exit program gracefully
    exit:   mov rax, 3                  ; specify close file sys_call
            mov rdi, qword [if]         ; specify file to close
            syscall
            mov rax, 3                  ; specify file close sys_call
            mov rdi, qword [kf]         ; specify file to close
            syscall
            mov rax, 3                  ; specify file close sys_call
            mov rdi, qword [of]         ; specify file to close
            syscall
            mov rax, 60                 ; specify terminate sys_call
            mov rdi, 0                  ; pass 0 code ("success") to OS.
            syscall                     ; call sys_exit 

; error exit
    errex:  mov rax, 3                  ; specify close file sys_call
            mov rdi, qword [if]         ; specify file to close
            syscall
            mov rax, 3                  ; specify file close sys_call
            mov rdi, qword [kf]         ; specify file to close
            syscall
            mov rax, 3                  ; specify file close sys_call
            mov rdi, qword [of]         ; specify file to close
            syscall
            mov rax, 60                 ; specify terminate sys_call
            mov rdi, 1                  ; pass 1 code ("error") to OS.
            syscall                     ; call sys_exit 

; error handling
            argclow:   ; print message "error: insufficient arguments"
                        jmp errex   ; jump to error exit routine
            argchi:     ; print message "error: too many arguments"
                        jmp errex       ; jump to error exit routine
            operr:      ; ideally, be able to parse failure code in RAX and print apropos msg
                        jmp errex       ; jump to error exit routine
            rerr:       ; ideally, be able to parse failure code in RAX and print apropos msg
                        jmp errex       ; jump to error exit routine
            swerr:      ; print message "switch error: unrecognized switch value"
                        jmp errex       ; jump to error exit routine
            wrerr:      ; ideally, be able to parse error code in RAX and print apropos msg
                        jmp errex       ; jump to error exit routine

; insert code between nops
    nop

; error codes: argchi = too many args; argclow = not enough args; operr = file open error; rerr = read error; swerr = def switch error (mode switch error); wrerr = file write error
