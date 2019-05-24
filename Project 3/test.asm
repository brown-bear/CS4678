bits 64
global _start
section .text
_start:

xor r15, r15 ; for the fd

;open
  push 0x79656b
  mov rdi, rsp
  xor rsi, rsi ; flags = O_RDONLY
  mov rdx, rsi ; mode = NULL
  xor rax, rax
  mov rax, 2	; = 2
  syscall
  mov r15, rax
  
loop_in: 
  ; read syscall args
  mov rdi, r15 ;fd from open
  lea rsi, [rsp-1] ;store a byte at [rsp-1]
  mov rdx, 1
  mov rax, 0 
  syscall

  ; check for input
  cmp rax, 1
  jne end

loop_out:
  ; write syscall args
  mov rdi, 1 ;write to stdout
  lea rsi, [rsp-1]
  mov rdx, 1
  mov rax, 1 
  syscall

  cmp rax, 1
  jne end

  jmp loop_in ; start over

end:
  ; exit
  mov edi, 0
  mov eax, 60
  syscall
