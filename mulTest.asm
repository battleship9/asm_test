bits 64
global _start

section .data
asd: db "it's working"
asdLen: equ $ - asd

section .text
_start:
	not rax
	not rbx
	mul rbx

	cmp rax, 0xFFFFFFFFFFFFFFFF
	jne .skip

	mov rax, 4
	mov rbx, 1
	mov rcx, asd
	mov rdx, asdLen
	int 80h

.skip:

	mov rax, 1
	int 80h
