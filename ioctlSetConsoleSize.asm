[bits 64]
global _start

struc TIOCSWINSZ
	ws_row: resw 1
	ws_col: resw 1
	ws_xpixel: resw 1
	ws_ypixel: resw 1
endstruc

section .data
resizerMsg: db 27, "[8;"
sizeY: db "40"
db ";"
sizeX: db "100"
db "t"
resizerMsgLen: equ $ - resizerMsg
errorMsg: db "Error"
errorMsgLen: equ $ - errorMsg
size:
	istruc TIOCSWINSZ
		at ws_row, dw 50
		at ws_col, dw 50
		at ws_xpixel, dw 10
		at ws_ypixel, dw 10
	iend

section .bss

section .text
_start:
	mov rax, 54
	mov rbx, 1
	mov rcx, 0x5414
	mov rdx, size
	int 80h

	mov rax, 4
	mov rbx, 1
	mov rcx, resizerMsg
	mov rdx, resizerMsgLen
	int 80h

exit:
	mov rax, 1
	mov rbx, 0
	int 80h
