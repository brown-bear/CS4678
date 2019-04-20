; Lucas Burke
; 11 April 2019
; CS4678 - Assn1, modified from my CS3140 - Assignment 3
; Assembly (bin): nasm -f bin -g assn1.asm
; [Not Required] Assembly: nasm -f elf64 -g assn1.asm
; [Not Required] Linker: ld -o assn1 -m elf_x86_64 assn1.o
; Comments: Removed .bss; adjusted via stack pointer instead.

BITS 64
global _start
section .text

_start:

loop_in:
  ; read syscall args
  mov edi, 0
  lea rsi, [rsp-1]
  mov rdx, 1
  mov eax, 0 
  syscall

  ; check for input
  cmp rax, 1
  jne end

loop_out:
  ; write syscall args
  mov edi, 1
  lea rsi, [rsp-1]
  mov rdx, 1

  mov eax, 1  ; write to stdout
  syscall

  cmp rax, 1
  jne end

  jmp loop_in ; start over

end:
  ; exit
  mov edi, 0
  mov eax, 60
  syscall

