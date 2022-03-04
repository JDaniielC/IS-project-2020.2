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

start:
	xor ax, ax
	mov ds, ax
	mov es, ax
	
	;Código do projeto...
	mov ah, 0   
	mov al, 13h ; modo VGA
	int 10h

	setText 1, 10, spec
	setText 4, 3, nomePc
	setText 7, 3, organizacao
	setText 10, 3, edicao
	setText 13, 3, compilacao
	setText 16, 3, processador
	setText 19, 3, ram
	setText 22, 3, sistema

	setText 13, 22, JDaniel
	setText 16, 22, Pedro
	setText 19, 22, LK
	setText 22, 22, tchucoOS

	call draw_square

jmp $

draw_square:
	mov ah, 0ch 
	mov al, 0fh
	mov bh, 0
	mov cx, 0
	.draw_seg:
		mov dx, 0
		int 10h
		mov dx, 198
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
		cmp dx, 198
		jne .draw_columns
	ret

printf:
	lodsb
	cmp al,0
	je .end

	mov ah, 0eh
	mov bl, 15
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
	spec db 'Especificacoes do SO', 0
	nomePc db 'Nome do PC ', 0
	organizacao db 'Organizacao', 0
	edicao db 'Edicao', 0
	compilacao db 'Compilacao do SO', 0
	processador db 'Processador', 0
	ram db 'RAM instalada', 0
	sistema db 'Tipo de sistema', 0
	tchucoOS db 'TchucoOS', 0
	JDaniel db 'Jose Daniel', 0
	LK db 'Lucas Emmanuel-LK', 0
	Pedro db 'Pedro Rogrigues', 0
