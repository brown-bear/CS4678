bits 64
global _start
section .text
_start:

;open
 push 0x79656b
 mov rdi, rsp
 xor rsi, rsi ; flags = O_RDONLY
 mov rdx, rsi ; mode = NULL
 xor rax, rax
 mov al, 2	; = 2
 syscall
  
loop_in:
  ; read syscall args
  mov rdi, rax ;fd from open
  lea rsi, [rsp-1] ;store a byte at [rsp-1]
  mov rdx, 1
  mov rax, 0 
  syscall

  ; check for input
  cmp rax, 1
  jne end

loop_out:
  ; write syscall args
  mov rdi, 1
  lea rsi, [rsp-1]
  mov rdx, 1
  mov rax, 1  ; write to stdout
  syscall

  cmp rax, 1
  jne end

  jmp loop_in ; start over

end:
  ; exit
  mov edi, 0
  mov eax, 60
  syscall
