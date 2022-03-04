org 0x7e00
jmp 0x0000:start

%macro setText 3
    mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, %1   ; Linha
	mov dl, %2   ; Coluna
	int 10h

    mov si, %3
    call printf
%endmacro

%macro drawSquare 4
	mov cx, %1
	.draw_rows:
		mov dx, %2
		int 10h
		mov dx, %4
		int 10h
		inc cx
		cmp cx, %3
		je .end_column
		jmp .draw_rows
	.end_column:
		mov dx, %2
	.draw_columns:
		mov cx, %1
		int 10h
		mov cx, %3
		int 10h
		inc dx
		cmp dx, %4
    jne .draw_columns
%endmacro

start:
    mov ah, 0   
	mov al, 13h ; modo VGA
	int 10h

    call draw_square
	setText 1, 16, title
	setText 6, 4, app1
	setText 6, 26, app2
	setText 13, 4, app3
	setText 13, 26, app4
	setText 20, 4, app5
	setText 20, 26, app6

    call draw_box_app
jmp $


box_app1: 
    drawSquare 20, 145, 100, 180
box_app2:
    drawSquare 200, 35, 280, 70
box_app3:
    drawSquare 200, 90, 280, 125
box_app4:
    drawSquare 200, 145, 280, 180
box_app5:
    drawSquare 20, 35, 100, 70
box_app6:
    drawSquare 20, 90, 100, 125
ret

draw_box_app:
	mov ah, 0ch 
	mov al, 06h
	mov bh, 0
    call box_app1
ret
; 09h é bom tb (azul claro)
draw_square:
	mov ah, 0ch 
	mov al, 06h
	mov bh, 0
	mov cx, 0
	.draw_seg:
		mov dx, 0
		int 10h
		mov dx, 199
		int 10h
		inc cx
		cmp cx, 319
		je .end_column
		jmp .draw_seg
	.end_column:
		mov dx, 0
	.draw_columns:
		mov cx, 0
		int 10h
		mov cx, 319
		int 10h
		inc dx
		cmp dx, 199
		jne .draw_columns
	ret

printf:
	lodsb
	cmp al,0
	je .end

	mov ah, 0eh
	mov bl, 0ah
	int 10h

	mov dx, 0
	jmp printf

    .end:
    mov ah, 0eh
    mov al, 0xd
    int 10h
    mov al, 0xa
    int 10h
ret

data:
    title db 'TchucoOS', 0
	app1 db 'Browser', 0
    app2 db 'Notes', 0
    app3 db 'Photos', 0
    app4 db 'RestTime', 0
    app5 db 'Terminal', 0
    app6 db 'About', 0

