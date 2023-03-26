bits 64
global _start

section .data
timeval:
    tv_sec  dd 1
    tv_usec dd 0

gpMsg db "grandparent", 0xa
gpLen equ $ - gpMsg

pMsg db "parent", 0xa
pLen equ $ - pMsg

cMsg db "child", 0xa
cLen equ $ - cMsg

section .text
_start:
	mov rax, 2
	int 80h

	cmp rax, 0
	jz p

gp:
	mov rax, 162
	mov rbx, timeval
	mov rcx, 0
	int 80h

	mov rcx, gpMsg
	mov rdx, gpLen

	call print
	jmp exit

p:
	mov rax, 2
	int 80h

	cmp rax, 0
	jz c

.p:
	mov rcx, pMsg
	mov rdx, pLen

	call print
	jmp exit

c:
	mov rcx, cMsg
	mov rdx, cLen

	call print
	jmp exit

print:
	mov rbx, 1
	mov rax, 4
	int 80h
	ret

exit:
	mov rax, 1
	mov rbx, 0
	int 80h
