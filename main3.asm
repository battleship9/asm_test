; nasm -felf64 main3.asm -o main.o
; ld main.o -o main -lX11 -dynamic-linker /lib64/ld-linux-x86-64.so.2

[bits 64]
global _start

section .data
; Xlib constants
ExposureMask:	dw 32768
KeyPressMask:	db 1
gc_foreground:	db 4

section .bss
; Xlib handles and ints
display:	resb 8
screen: 	resb 4
black:		resb 4
white:		resb 4
r_win:		resb 8
win:		resb 8
gc_black:	resb 8
gc_color:	resb 8
colormap:	resb 8

; Xlib structures
xgcvals_white: 	resb 128
xgcvals_black:	resb 128

section .text

extern 	XOpenDisplay
extern 	XDefaultScreen
extern 	XBlackPixel
extern	XWhitePixel
extern 	XDefaultRootWindow
extern 	XCreateSimpleWindow
extern	XSelectInput
extern 	XMapWindow
extern	XDrawRectangle
extern	XCreateGC
extern	XDefaultColormap
extern 	XCloseDisplay

_start:
	; Display *XOpenDisplay(char *display_name)
	mov	rdi, 0
	call XOpenDisplay
	mov	[display], rax

	; int XDefaultScreen(Display *display)
	mov	rdi, [display]
	call XDefaultScreen
	mov	[screen], rax

	; unsigned long XBlackPixel(Display *display, int screen_number)
	mov	rdi, [display]
	mov	rsi, [screen]
	call XBlackPixel
	mov	[black], rax

	; unsigned long XWhitePixel(Display *display, int screen_number)
	mov	rdi, [display]
	mov	rsi, [screen]
	call XWhitePixel
	mov	[white], rax

	; Window XCreateSimpleWindow(display, r_win, 0, 0, width * tilelen, (height - 2) * tile_len, 0, black, black)
	; Window XCreateWindow(Display display,
	;                      Window parent,
	;                      int x,
	;                      int y,
	;                      unsigned int width,
	;                      unsigned int height,
	;                      unsigned int border_width,
	;                      int depth,
	;                      unsigned int class,
	;                      Visual *visual,
	;                      unsigned long valuemask,
	;                      XSetWindowAttributes *attributes)
	mov	rdi, [display]
	mov	rsi, [r_win]
	mov	rdx, 0
	mov	rcx, 0

	mov	rbx, 60
	mov	rax, 10
	mul	rbx
	mov	r10, rax
	mov	rax, 22
	sub	rax, 2
	mul	rbx
	mov r10, rax

	mov	rax, 0
	push rax
	mov	rax, [black]
	push rax
	push rax

	call XCreateSimpleWindow
	mov	[win], rax

	; GC XCreateGC(display, win, GCForeground, &values_white)
	mov	rcx, [white]
	mov	[xgcvals_white + 16], rcx	; offsetof(XGCValues, foreground) == 16
	mov	rdi, [display]
	mov	rsi, [win]
	mov	rdx, [gc_foreground]
	mov	rcx, xgcvals_white
	call XCreateGC
	mov	[gc_color], rax

	; GC XCreateGC(display, win, GCForeground, &values_black)
	mov	rcx, [black]
	mov	[xgcvals_black + 16], rcx	; offsetof(XGCValues, foreground) == 16
	mov	rdi, [display]
	mov	rsi, [win]
	mov	rdx, [gc_foreground]
	mov	rcx, xgcvals_black
	call XCreateGC
	mov	[gc_black], rax

	; Colormap XDefaultColormap(display, screen)
	mov	rdi, [display]
	mov	rsi, [screen]
	call XDefaultColormap
	mov	[colormap], rax

	; void XSelectInput(display, win, ExposureMask | KeyPressMask)
	mov	rdi, [display]
	mov	rsi, [win]
	mov	rdx, [ExposureMask]
	or	rdx, [KeyPressMask]
	call XSelectInput

	; void XMapWindow(display, win)
	mov	rdi, [display]
	mov	rsi, [win]
	call XMapWindow

	; Game

	; void XDrawRectangle(display, window, gc, x_pxl, y_pxl, tile_len, tile_len)
	mov	rdi, [display]
	mov	rsi, [win]

	mov	rdx, 0
	mov	rcx, 0
	mov	r8, 0
	mov	r9, 60
	push r9
	;call XDrawRectangle
	pop r9


	; Quit the game

	; XCloseDisplay(display)
	mov	rdi, [display]
	; call XCloseDisplay

	mov rax, 1
	mov rbx, 0
	int 80h