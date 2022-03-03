org 0x7e00
jmp 0x0000:start

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
  jmp show_fotos
jmp $


getchar:
 	mov ah, 0x00
 	int 16h
ret

hold:
	call getchar
    cmp al, 27
    je start
	cmp al, ' '
	jne hold
ret

video:
    mov ah, 0 ; Set video mode
	mov al, 12h
	int 10h
ret

%macro loadPhotos 1
  call video
  call %1
  call hold
%endmacro

%macro setColor 1
  mov ah, 0ch
	mov bh, 0
	mov al, %1 ; cor
	int 10h
%endmacro

%macro setBackground 1
	mov ah, 0xb
	mov bh, 0
	mov bl, %1
	int 10h
%endmacro

%macro filled_circle 3
	push cx
	push dx

	mov ax, -%1
	push ax

	.loop_circle:
		pop ax
		cmp ax, %1
		je .done
		inc ax
		push ax

		mov bx, -%1
		push bx
		jmp .loop_circle2

	.loop_circle2:
		pop bx
		cmp bx, %1
		je .loop_circle
		inc bx
		push bx

		jmp .check

	.check:
		pop bx
		pop ax
		push ax
		push bx

		mov cx, ax
		mov dx, bx

		mul ax
		xchg ax, bx
		mul ax
		add ax, bx

		cmp ax, %2
		jg .loop_circle2

		pop bx
		pop ax
		pop dx
		pop cx
		push cx
		push dx
		push ax
		push bx

		add cx, ax
		add dx, bx

		setColor %3

		jmp .loop_circle2

	.done:
		pop dx
		pop cx
%endmacro

japan:
	mov dx, 0

	.jp_white:
		cmp dx, 480
		jg .jp_red
		mov cx, 0
		.jp_loop_white:
			setColor 15
			inc cx
			cmp cx, 640
			jl .jp_loop_white
			inc dx
			jmp .jp_white
	.jp_red:
		mov cx, 320
		mov dx, 240
		filled_circle 125, 15625, 4

	.jp_end:
		ret

france:
	setBackground 4

	mov dx, 0

	.fr_blue:
	cmp dx, 480
	jg .fr_next
	mov cx, 0 ; inicio da linha 
	.fr_loop_blue:
		setColor 1
		inc cx
		cmp cx, 214
		jl .fr_loop_blue
		inc dx
		jmp .fr_blue

	.fr_next:
		mov dx, 0

	.fr_white:
		cmp dx, 480
		jg .fr_end
		mov cx, 214
		.fr_loop_white:
			setColor 15
			inc cx
			cmp cx, 427
			jl .fr_loop_white
			inc dx
			jmp .fr_white

	.fr_end:
		ret

italy:
	setBackground 4

	mov dx, 0

	.it_green:
	cmp dx, 480
	jg .it_next
	mov cx, 0 ; inicio da linha 
	.it_loop_green:
		setColor 2
		inc cx
		cmp cx, 214
		jl .it_loop_green
		inc dx
		jmp .it_green

	.it_next:
		mov dx, 0

	.it_white:
		cmp dx, 480
		jg .it_end
		mov cx, 214
		.it_loop_white:
			setColor 15
			inc cx
			cmp cx, 427
			jl .it_loop_white
			inc dx
			jmp .it_white

	.it_end:
		ret

germany:
	mov dx, 160

	.gr_red:
		cmp dx, 320
		jg .gr_yellow
		mov cx, 0
		.gr_loop_red:
			setColor 4
			inc cx
			cmp cx, 640
			jl .gr_loop_red
			inc dx
			jmp .gr_red

	.gr_yellow:
		cmp dx, 480
		jg .gr_end
		mov cx, 0
		.gr_loop_yellow:
			setColor 14
			inc cx
			cmp cx, 640
			jl .gr_loop_yellow
			inc dx
			jmp .gr_yellow
	
	.gr_end:
		ret

russia:
	setBackground 4

	mov dx, 0

	.rs_white:
		cmp dx, 160
		jg .rs_blue
		mov cx, 0
		.rs_loop_white:
			setColor 15
			inc cx
			cmp cx, 640
			jl .rs_loop_white
			inc dx
			jmp .rs_white

	.rs_blue:
		cmp dx, 320
		jg .rs_end
		mov cx, 0
		.rs_loop_blue:
			setColor 1
			inc cx
			cmp cx, 640
			jl .rs_loop_blue
			inc dx
			jmp .rs_blue
	
	.rs_end:
		ret

england:
	mov dx, 0

	.en_white:
		cmp dx, 480
		jg .en_next
		mov cx, 0
		.en_loop_white:
			setColor 15
			inc cx
			cmp cx, 640
			jl .en_loop_white
			inc dx
			jmp .en_white

	.en_next:
		mov dx, 0

	.en_red_vertical:
		cmp dx, 480
		jg .en_next1
		mov cx, 280
		.en_loop_red1:
			setColor 4
			inc cx
			cmp cx, 360
			jl .en_loop_red1
			inc dx
			jmp .en_red_vertical

	.en_next1:
		mov dx, 200

	.en_red_horizontal:
		cmp dx, 280
		jg .en_end
		mov cx, 0
		.en_loop_red2:
			setColor 4
			inc cx
			cmp cx, 640
			jl .en_loop_red2
			inc dx
			jmp .en_red_horizontal

	.en_end:
		ret

brasil:
    setBackground 2

	mov dx, 0

	push cx
	push ax

	mov dx, 80
	mov cx, 320 ; Salva o inicio da linha amarela
	mov ax, 322 ; Salva o final  da linha amarela 

	.br_yellow:
		cmp dx, 240
		jg .br_yellowBottom
		push cx
		.br_loopLine:
			push ax
			setColor 14
			pop ax
			inc cx
			cmp cx, ax
			jl .br_loopLine
			inc dx
			add ax, 2
			pop cx
			sub cx, 2
			jmp .br_yellow

	.br_yellowBottom:
		cmp dx, 400
		jg .br_next
		push cx
		.br_loopLine1:
			push ax
			setColor 14
			pop ax
			inc cx
			cmp cx, ax
			jl .br_loopLine1
			inc dx
			sub ax, 2
			pop cx
			add cx, 2
			jmp .br_yellowBottom

	.br_next:
		pop ax
		pop cx

	mov cx, 320
	mov dx, 240
	call filled_circle 110, 12100, 1

	mov dx, 235
	mov cx, 225

	.br_white:
		cmp dx, 245
		jg .br_end
		push cx
		.loopLine4:
			setColor 15
			inc cx
			cmp cx, 420
			jl .loopLine4
			inc dx
			pop cx
			jmp .br_white

	.br_end:
		ret


show_fotos:
    loadPhotos japan
    loadPhotos france
    loadPhotos england
    loadPhotos brasil
    loadPhotos italy
    loadPhotos russia
    loadPhotos germany
jmp show_fotos