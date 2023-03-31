[bits 64]
global _start

section .text
_start:
	mov rax, 1
	int 80h
