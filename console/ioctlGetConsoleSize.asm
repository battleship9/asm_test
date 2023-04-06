[bits 64]
global _start

section .data
textY: db " X: "
textYLen: equ $ - textY
textX: db "Y: "
textXLen: equ $ - textX
printFormat equ 100

section .bss
sz: RESQ 1
tmp: resq 1

section .text
_start:
	mov rax, 54
	mov rbx, 1
	mov rcx, 0x5413
	mov rdx, sz
	int 80h

	mov rax, 4
	mov rbx, 1
	mov rcx, textX
	mov rdx, textXLen
	int 80h

	xor rax, rax
	mov ax, word [sz + 0]
	call print

	mov rax, 4
	mov rbx, 1
	mov rcx, textY
	mov rdx, textYLen
	int 80h

	xor rax, rax
	mov ax, word [sz + 2]
	call print

	jmp exit

print:
	mov rcx, printFormat

.loop:
	xor rdx, rdx

	div rcx
	add rax, '0'
	mov [tmp], rax

	push rdx
	push rcx

	mov rax, 4
	mov rbx, 1
	mov rcx, tmp
	mov rdx, 8
	int 80h

	pop rcx

	xor rdx, rdx

	mov rax, rcx
	mov rbx, 10
	div rbx
	mov rcx, rax

	pop rdx

	mov rax, rdx

	cmp rcx, 1
	jg .loop

	add rax, '0'
	mov [tmp], rax

	mov rax, 4
	mov rbx, 1
	mov rcx, tmp
	mov rdx, 8
	int 80h

	ret

exit:
	mov rax, 1
	mov rbx, 0
	int 80h
