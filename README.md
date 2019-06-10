# 68020 sequence

This program checks whether a file contains a secret message.
If a file does contain a secret message, program exit code is ```0```. If a file does not or an error occurred, program exit code is ```1```.
Filename must be provided as a command line argument.

## Secret message

A file contains a secret message if all of following statements are true:
- the file contains a sequence of 32-bit integers;
- the file does not contain a number 68020;
- the file contains a sequence 6, 8, 0, 2, 0;
- sum of all numbers in the file mod 2^32 equals 68020.

## Compilation

```
nasm -f elf64 -o seq.o seq.asm
ld --fatal-warnings -o seq seq.o
```

## Usage

```file1``` contains a secret message. ```file2``` does not. ```file3``` does not exist.

```
# ./seq file1
# echo $?
0
# ./seq file2
# echo $?
1
# ./seq file3
# echo $?
1
```

