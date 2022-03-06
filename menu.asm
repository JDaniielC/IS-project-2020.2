org 0x7e00
jmp 0x0000:start

%macro drawer 1
	mov ah, 0ch 
	mov al, %1
	mov bh, 0
%endmacro

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

%macro drawCursor 4
	mov cx, %1
	.draw_seg:
		mov dx, %3-1
		int 10h
		mov dx, %3
		int 10h
		inc cx
		cmp cx, %4
		je .end_column
		jmp .draw_seg
	.end_column:
		mov dx, %2
	.draw_columns:
		mov cx, %4-2
		int 10h
		mov cx, %4-1
		int 10h
		inc dx
		cmp dx, %3
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
	call first_cursor
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
	drawer 9
	call box_app1
ret

draw_square:
	drawer 9
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

cursor_app1: 
	drawCursor 85, 54, 67, 98
cursor_app2:
	drawCursor 85, 109, 122, 98
cursor_app3:
	drawCursor 85, 164, 177, 98
cursor_app4:
	drawCursor 265, 54, 67, 278
cursor_app5:
	drawCursor 265, 109, 122, 278
cursor_app6:
	drawCursor 265, 164, 177, 278
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

first_cursor:
	drawer 0
	call cursor_app2
	drawer 2
	drawCursor 85, 54, 67, 98

  mov ah, 0
	int 16h
  ; cmp al, 13 e jogar para o app

	cmp al, 'w'
  je third_cursor
	cmp al, 'a'
  je fourth_cursor
  cmp al, 's'
  je second_cursor
	cmp al, 'd'
  je fourth_cursor

  jmp first_cursor
ret

second_cursor:
	drawer 0
	call cursor_app1
	drawer 2
	drawCursor 85, 109, 122, 98

  mov ah, 0
	int 16h
  ; cmp al, 13 e jogar para o app
  
	cmp al, 'w'
  je first_cursor
	cmp al, 'a'
  je fifth_cursor
  cmp al, 's'
  je third_cursor
	cmp al, 'd'
  je fifth_cursor

  jmp second_cursor
ret

third_cursor:
	drawer 0
	call cursor_app1
	drawer 2
	drawCursor 85, 164, 177, 98

  mov ah, 0
	int 16h
  ; cmp al, 13 e jogar para o app
  
	cmp al, 'w'
  je second_cursor
	cmp al, 'a'
  je sixth_cursor
  cmp al, 's'
  je first_cursor
	cmp al, 'd'
  je sixth_cursor

  jmp third_cursor
ret

fourth_cursor:
	drawer 0
	call cursor_app1
	drawer 2
	drawCursor 265, 54, 67, 278

  mov ah, 0
	int 16h
  ; cmp al, 13 e jogar para o app
  
	cmp al, 'w'
  je sixth_cursor
	cmp al, 'a'
  je first_cursor
  cmp al, 's'
  je fifth_cursor
	cmp al, 'd'
  je first_cursor

  jmp fourth_cursor
ret

fifth_cursor:
	drawer 0
	call cursor_app1
	drawer 2
	drawCursor 265, 109, 122, 278

  mov ah, 0
	int 16h
  ; cmp al, 13 e jogar para o app
  
	cmp al, 'w'
  je fourth_cursor
	cmp al, 'a'
  je second_cursor
  cmp al, 's'
  je sixth_cursor
	cmp al, 'd'
  je second_cursor

  jmp fifth_cursor
ret

sixth_cursor:
	drawer 0
	call cursor_app1
	drawer 2
	drawCursor 265, 164, 177, 278

  mov ah, 0
	int 16h
  ; cmp al, 13 e jogar para o app
  
	cmp al, 'w'
  je fifth_cursor
	cmp al, 'a'
  je third_cursor
  cmp al, 's'
  je fourth_cursor
	cmp al, 'd'
  je third_cursor

  jmp sixth_cursor
ret


data:
	title db 'TchucoOS', 0
	app1 db 'Browser', 0
	app2 db 'Notes', 0
	app3 db 'Photos', 0
	app4 db 'RestTime', 0
	app5 db 'Terminal', 0
	app6 db 'About', 0

