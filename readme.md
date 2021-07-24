# Vigenere

Vigenere is a program intended to encode and decode text via a Vigenère cipher system. It is a toy program, not intended for real use or public consumpyion. It is a Linux CLI program in x86-64 ASM, but it will require me the get the hang of parsing command line arguments and file IO using linux syscalls. 

It is my current work in progress, and, **at present, is not functioning.**

## The following have been implemented: 

- The program properly opens and begin read operations from the input file and the key file
- The program properly parses the encode/decode switch and controls flow accordingly
- Extremely crude error handling has been partially implemented 
- The program will generally exit gracefully, closing open files and returning 0 to the operating system. 

## The following need to be implemented or corrected: 

- Opening an output file results in file permission errors (thus, specifying an output file from the command line is irrelevant; the program can parse the argument, but will not actually attempt to open the file).
-  Encoding is not actually implemented yet
-  Decoding is not actually implemented yet
-  Error handling needs to be mae more thorough and robust

## Usage

**At present, the program does not function.** One could, in theory, still pass it arguments from the CLI and specify output redirection as such:

    $./vigenere -e input.txt key.txt > output.txt

The use of -e or -d will determine whether the program will go into encode mode, turning a plaintext input into a ciphertext output using the provided key, or decode mode, turning a ciphertext input into a plaintext output using the provided key. 

Eventually, the intent is that all necessary information will be provided during the CLI invocation (though, on *nix systems with output redirection, this is obviously redundant). Therefore, the eventual use would be as follows: 

    $./vigenere -e input.txt key.txt output.txt

thus, no longer relying on CLI input/output redirection and forcing me to learn more about file handling and linux syscalls. 