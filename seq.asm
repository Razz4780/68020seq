; System calls codes.
SYS_EXIT equ 60
SYS_READ equ 0
SYS_OPEN equ 2
SYS_CLOSE equ 3

; File access flag.
O_RDONLY equ 0

; Buffer size.
BUF_LEN equ 4096

; Magical constant.
MAGIC_CONST equ 68020


global _start

section .bss
  buf resb BUF_LEN             ; Buffer to hold data read from file.

section .text

_start:
  mov r12, -1                  ; r12 contains file descriptor.
  xor r13, r13                 ; Second to last r13 bit informs whether a number from range (68020, 2^31) has occurred
                               ; Last r13 bit program contains return code.
  xor r14d, r14d               ; r14d contains sum of all read numbers mod 2^32.
  mov r15, 2                   ; r15 contains current DFA state.

  cmp qword [rsp], 2
  jne exit_with_failure
  mov rax, SYS_OPEN
  mov rdi, qword [rsp + 16]
  mov rsi, O_RDONLY
  syscall
  cmp rax, 0
  jl exit_with_failure
  mov r12, rax

loop:
  mov rax, SYS_READ
  mov rdi, r12
  mov rsi, buf
  mov rdx, BUF_LEN
  syscall
  cmp rax, 0
  jl exit_with_failure
  je processing_finished
  test rax, 3
  jnz exit_with_failure
  mov rdi, buf

inner_loop:
  mov esi, dword [rdi]
  add r14d, esi
  cmp esi, MAGIC_CONST
  je exit_with_failure
  jl automaton
  or r13, 2

automaton:
  test r15, 64
  jnz continue_inner_loop
  mov r10, 6
  test r15, 2
  jnz change_automaton_state
  mov r10, 8
  test r15, 4
  jnz change_automaton_state
  xor r10, r10
  test r15, 8
  jnz change_automaton_state
  mov r10, 2
  test r15, 16
  jnz change_automaton_state
  xor r10, r10

change_automaton_state:
  test r10, rsi
  je next_state
  mov r15, 1

next_state:
  shl r15, 1

continue_inner_loop:
  add rdi, 4
  sub rax, 4
  jnz inner_loop
  jmp loop

processing_finished:
  cmp r14d, MAGIC_CONST
  jne exit_with_failure
  test r15, 64
  jz exit_with_failure
  test r13, 2
  jnz cleanup_and_exit

exit_with_failure:
  or r13, 1
  cmp r12, 0
  jl exit

cleanup_and_exit:
  mov rax, SYS_CLOSE
  mov rdi, r12
  syscall
  cmp rax, 0
  je exit
  or r13, 1

exit:
  mov rax, SYS_EXIT
  and r13, 1
  mov rdi, r13
  syscall

