bits 64
global _start

section .data

section .bss
asd: resb 1

section .text
_start:
	pushf
	pop rax
	xor rax, 0x80000
	push rax
	popf

	mov rax, 3
	mov rbx, 2
	mov rcx, asd
	mov edx, 1
	int 80h

	mov rax, 4
	mov rbx, 1
	mov rcx, asd
	mov rdx, 1
	int 80h

	mov rax, 1
	int 80h
