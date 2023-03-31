; 1 October 2021 - 
;
; Simple Tetris game written in NASM assembly, using Xlib, for 64 bit Linux

	; X11 functions
	extern 	XOpenDisplay			; serves as the connection to the X server and that contains all the information about that X server
	extern 	XDefaultScreen			; returns the screen number which is used in most xlib functions where you want to specify a screen e.g. DefaultGC
	extern 	XBlackPixel				; returns the black pixel value for the specified screen
	extern	XWhitePixel				; returns the white pixel value for the specified screen
	extern 	XDefaultRootWindow		; returns the root window for the default screen
	extern 	XCreateSimpleWindow		; creates a window that inherits its attributes from its parent window
	extern	XSelectInput			; requests that the X server report the events associated with the specified event mask
	extern 	XMapWindow				; maps the window and all of its subwindows that have had map requests
	extern	XDrawRectangle				; draws a single circular or elliptical arc	; extern 	XDrawRectangle			; draws the outlines of the specified rectangle as if a five-point PolyLine protocol request were specified for the rectangle
	extern	XCreateGC				; creates a graphics context and returns a GC (Graphics Context)
	extern	XDefaultColormap		; creates a colormap of the specified visual type for the screen on which the specified window resides and returns the colormap ID associated with it
	extern 	XCloseDisplay			; closes the connection to the X server for the display specified in the Display structure and destroys all windows, resource IDs (Window, Font, Pixmap, Colormap, Cursor, and GContext), or other resources that the client has created on this display, unless the close-down mode of the resource has been changed (see XSetCloseDownMode())
	; extern 	XKeycodeToKeysym		; uses internal Xlib tables and returns the KeySym defined for the specified KeyCode and the element of the KeyCode vector

	; libc functions
	extern	printf					; writes output to stdout, the standard output stream

; ========== bss ==========
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
; keysym:		resb 8
; together 10 bytes = 80 bits

; Xlib structures
xgcvals_white: 	resb 128
xgcvals_black:	resb 128
; xevent:		resb 192
; together 3 bytes = 24 bits

; bits together 200


; ========== data ==========
section .data

; Xlib constants
ExposureMask:	dw 32768
KeyPressMask:	db 1
gc_foreground:	db 4
; together 32 bytes = 256 bits

; Strings
start_string:	db "============================", 10, "========== Tetris ==========", 10, 10, 0
end_string:	db "============================", 10, 10, 0
; together 138 bytes = 1104 bits
; bits together 3128

; bits together at all 3328


; ========== text ==========
	section .text
	global	_start

_start:
	; Print start string
	mov	rdi, start_string
	sub	rsp, 8
	call	printf
	add	rsp, 8

	; Display* XOpenDisplay(NULL)
	mov	rdi, 0
	sub	rsp, 8
	call 	XOpenDisplay
	mov	[display], rax
	add	rsp, 8

	; int XDefaultScreen(display)
	mov	rdi, [display]
	sub	rsp, 8
	call	XDefaultScreen
	mov	[screen], eax
	add	rsp, 8

	; int XBlackPixel(display, screen)
	mov	rdi, [display]
	mov	rsi, [screen]
	sub	rsp, 8
	call	XBlackPixel
	mov	[black], eax
	add	rsp, 8

	; int XWhitePixel(display, screen)
	mov	rdi, [display]
	mov	rsi, [screen]
	sub	rsp, 8
	call	XWhitePixel
	mov	[white], eax
	add	rsp, 8

	; Window XDefaultRootWindow(display)
	mov	rdi, [display]
	sub	rsp, 8
	call	XDefaultRootWindow
	mov	[r_win], rax
	add	rsp, 8

	; Window XCreateSimpleWindow(display, r_win, 0, 0, width * tilelen, (height - 2) * tile_len, 0, black, black)
	mov	rdi, [display]
	mov	rsi, [r_win]
	mov	rdx, 0
	mov	rcx, 0

	mov	ebx, 60
	mov	eax, 10
	mul	ebx
	mov	r8d, eax
	mov	eax, 22
	sub	eax, 2
	mul	ebx
	mov 	r9d, eax

	mov	rax, 0
	push	rax
	mov	eax, [black]
	push	rax
	push 	rax

	call	XCreateSimpleWindow
	mov	[win], rax
	add	rsp, 24

	; GC XCreateGC(display, win, GCForeground, &values_white)
	mov	ecx, [white]
	mov	[xgcvals_white + 16], ecx	; offsetof(XGCValues, foreground) == 16
	mov	rdi, [display]
	mov	rsi, [win]
	mov	rdx, [gc_foreground]
	mov	rcx, xgcvals_white
	sub	rsp, 8
	call	XCreateGC
	mov	[gc_color], rax
	add	rsp, 8

	; GC XCreateGC(display, win, GCForeground, &values_black)
	mov	ecx, [black]
	mov	[xgcvals_black + 16], ecx	; offsetof(XGCValues, foreground) == 16
	mov	rdi, [display]
	mov	rsi, [win]
	mov	rdx, [gc_foreground]
	mov	rcx, xgcvals_black
	sub	rsp, 8
	call	XCreateGC
	mov	[gc_black], rax
	add	rsp, 8

	; Colormap XDefaultColormap(display, screen)
	mov	rdi, [display]
	mov	esi, [screen]
	sub	rsp, 8
	call	XDefaultColormap
	mov	[colormap], rax
	add	rsp, 8

	; void XSelectInput(display, win, ExposureMask | KeyPressMask)
	mov	rdi, [display]
	mov	rsi, [win]
	mov	rdx, [ExposureMask]
	or	rdx, [KeyPressMask]
	sub	rsp, 8
	call	XSelectInput
	add	rsp, 8
	
	; void XMapWindow(display, win)
	mov	rdi, [display]
	mov	rsi, [win]
	sub	rsp, 8
	call	XMapWindow
	add	rsp, 8
	
	
	; Game
	
	; void XDrawRectangle(display, window, gc, x_pxl, y_pxl, tile_len, tile_len)
	mov	rdi, [display]
	mov	rsi, [win]
	
	; Print start string
	mov	rdi, start_string
	sub	rsp, 8
	call	printf
	add	rsp, 8
	
	mov	rdx, 0
	mov	rcx, 0
	mov	r8, 0
	mov	r9, 60
	push	r9
	call	XDrawRectangle
	pop	r9
	

	; Quit the game
	
	; Print end string
	mov	rdi, end_string
	sub	rsp, 8
	call	printf
	add	rsp, 8

	; XCloseDisplay(display)
	mov	rdi, [display]
	sub	rsp, 8
	call	XCloseDisplay
	add	rsp, 8
	
	; return 0
	mov	rax, 0
	ret
