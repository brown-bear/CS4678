bits 64
global _start

_start:
section .text

l_open:
; registers carry through l_open call...
  push rbx
  mov rbx, rcx
  mov eax, 2
  syscall
  cmp rax, 0
  jge .end

.end:
  ; rax already holds good fd
  xor r11, r11
  mov r11, dword 0
  mov [rbx], r11  ; set stderr to 0
  pop rbx
  ret
  
  
