bits 64
global _start
section .text
_start:

l_open:
  push "key"
  pop rdi
  push rbx
  mov rbx, rcx
  mov eax, 2
  syscall
  
 mov rdi, "key"
 xor rsi, rsi ; flags = O_RDONLY
 mov rdx, rsi ; mode = NULL
 xor rax, rax
 mov al, 2	; = 2
 syscall
  
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
