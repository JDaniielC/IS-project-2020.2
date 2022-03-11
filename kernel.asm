org 0x7e00
jmp 0x0000:start

%define blackColor 0
%define blueColor 1
%define darkGreenColor 2
%define blue 3
%define redColor 4
%define lightGrayColor 7
%define greenColor 10
%define yellowColor 14
%define whiteColor 15

%macro setText 4
	mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, %1   ; Linha
	mov dl, %2   ; Coluna
	int 10h
	mov bx, %4
	mov si, %3
	call printf_color
%endmacro

%macro simplePrintf 2
	mov bx, %2
	mov si, %1
	call printf_color
%endmacro

start:
	call initVideo
	call login
	system:
	call initVideo
	setText 15, 16, title, greenColor
	call draw_logo
	call delay
	call menu
jmp $

get_password:
	xor cl,cl ;zera variavel cl (sera usada como contador)
	loop_get_password:
		mov ah,0
		int 16h
		cmp al,08h ;backspace teclado?
		je key_backspace_password
		cmp al,0dh ;enter teclado?
		je key_enter_password
		cmp cl,0fh ;15 valores ja teclados?
		je loop_get_password ;só aceita backspace ou enter

		mov byte [di],al
		inc di
		mov al,'*'
		mov ah,0eh
		int 10h
		inc cl
	jmp loop_get_password

	key_backspace_password:
		cmp cl,0
		je loop_get_password ;n faz sentido apagar string vazia

		dec di ;volta dl pra o caractere anterior
		mov byte [di],0 ;zera o valor daquela posicao
		dec cl ;diminui o contador em 1

		mov ah,0eh
		mov al,08h ;imprime backspace(volta o cursor)
		int 10h

		mov al,' '
		int 10h

		mov al,08h 
		int 10h
	jmp loop_get_password

	key_enter_password:
		mov al,0
		mov byte[di],al

		mov ah,0eh
		mov al,0dh
		int 10h
		mov al,0ah
		int 10h
	ret

login:
	getspassword:
		simplePrintf stringusuario, whiteColor
		mov di, stringname
		call get_input
		simplePrintf string_senha, whiteColor
		mov di,password
		call get_password
		
		jmp comp_pass
	comp_pass:
		simplePrintf String_senha2, whiteColor
		mov di, stringpassword
		call get_password
		mov si, stringpassword
		mov di, password
		call strcmp
		cmp al,1
		jne wrong
		jmp system
	wrong:
		simplePrintf stringwrongpassword, whiteColor
		call endl
	jmp comp_pass

%macro drawer 1
	mov ah, 0ch 
	mov al, %1
	mov bh, 0
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

%macro startTimer 1
	mov al, %1+48
	mov bx, whiteColor
	mov ah, 0eh ; modo de imprmir na tela
	int 10h     ; imprime o que tá em al
	mov ah, 03h 
	mov ch, 0   
	mov cl, 0  
	mov dh, 0   
	mov dl, 1   
	int 1aH 
	.loop:
		mov ah, 02h ;
		int 1aH     
		cmp dh, %1h
		je good_job
		add dh, 48
		mov [time], dh
		setText 12, 29, time, yellowColor
	jmp .loop
%endmacro

cursorApp:
	drawer blackColor
	call cursor_app1
	drawer darkGreenColor
ret

getchar:
  mov ah, 00h
  int 16h
ret

initVideo:
	mov ah, 00h
	mov al, 13h
	int 10h
ret

printf_color:
	loop_print_string:
		lodsb
		cmp al,0
		je end_print_string
		mov ah,0eh
		int 10h
		jmp loop_print_string
	end_print_string:
ret

menu:
	call initVideo
	call draw_logo ; Desenha a borda
	call draw_border ; Escreve nome de cada APP
	setText 1, 16, title, darkGreenColor
	setText 6, 4, app1, darkGreenColor
	setText 6, 26, app2, darkGreenColor
	setText 13, 4, app3, darkGreenColor
	setText 13, 26, app4, darkGreenColor
	setText 20, 4, app5, darkGreenColor
	setText 20, 26, app6, darkGreenColor
	call draw_box_app ; Desenha os retangulos
	call first_cursor ; Inicia a aplicação

delay:
	mov ah, 86h
	mov cx, 30
	mov dx, 500
	int 15h
ret

fast_delay:
	mov ah, 86h
	mov dx, 3000
	int 15h
ret

endline:
	mov ah, 02h ; setar o cursor
	mov bh, 0   ; pagina
	mov dl, 1
	inc dh
	int 10h
jmp teclado

delete_endline:
	cmp dh, 2 ;Linha inicial
	je teclado

	mov al, ' '
	mov ah, 09h ; codigo para printar caractere apenas onde esta o cursor
	mov bh, 0   ; seta a pagina
	mov bl, whiteColor  ; seta a cor do caractere, nesse caso, branco
	int 10h

	mov ah, 02h ; setar o cursor
	mov bh, 0   ; pagina
	dec dh
	mov dl, 100
	int 10h

jmp teclado

backspace:
	cmp dl, 1
	je delete_endline

	mov al, ' '
	mov cx, 1
	mov ah, 09h ; codigo para printar caractere apenas onde esta o cursor
	mov bh, 0   ; seta a pagina
	mov bl, whiteColor  ; seta a cor do caractere, nesse caso, branco
	int 10h

	mov ah, 02h ; setar o cursor
	dec dl ; coluna --
	mov bh, 0   ; pagina
	int 10h

jmp teclado


teclado:
	mov ah, 0   ; prepara o ah para a chamada do teclado
	int 16h     ; interrupcao para ler o caractere e armazena-lo em al

	cmp al, 8
	je backspace
	cmp al, 27
	je menu
	cmp dl, 100
	je endline
	
	mov ah, 02h ; setar o cursor
	mov bh, 0   ; pagina
	inc dl
	int 10h

	mov ah, 09h ; codigo para printar caractere apenas onde esta o cursor
	mov bh, 0   ; seta a pagina
	int 10h

jmp teclado

draw_logo:
	mov si, lacoste
	mov dx, 0            ; Y
	mov bx, si
	add si, 2
	.for1:
		cmp dl, byte[bx+1]
		je .endfor1
		mov cx, 0        ; X
	.for2:
		cmp cl, byte[bx]
		je .endfor2
		lodsb
		push dx
		push cx
		mov ah, 0ch
		add dx, 70
		add cx, 140
		int 10h
		pop cx
		pop dx
		inc cx
		jmp .for2
	.endfor2:
		inc dx
		jmp .for1
	.endfor1:
ret

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
	drawer blue
	call box_app1
ret

draw_border:
	drawer whiteColor
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

draw_white_border:
	mov ah, 0ch 
	mov al, whiteColor
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

bad_input:
	setText 15, 20, error, whiteColor
	call delay
jmp menu

good_job:
	setText 20, 4, work, whiteColor
	call delay
jmp menu

loading_app:
	call initVideo
	call draw_logo
	call loading_limit
	call loading
ret

background_white:
	; Set background white
	mov ah, 0ch 
	mov al, whiteColor
	mov bh, 0
	mov cx, 0
	mov dx, 0
	.draw_seg:
		int 10h
		inc cx
		cmp cx, 320
		je .jump_row
		jne .draw_seg
	.back_column:
		mov cx, 0
		jmp .draw_seg
	.jump_row:
		inc dx
		cmp dx, 200
		jne .back_column
ret

first_cursor:
	call cursorApp
	drawCursor 85, 54, 67, 98

  call getchar

  cmp al, 13
	je init_browser
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

init_browser:
	call loading_app
	call initVideo
	call background_white
	call draw_dino
	setText 11, 13, offline, whiteColor
	setText 14, 3, text_fun1, whiteColor
	setText 15, 3, text_fun2, whiteColor
	setText 18, 12, try, whiteColor
	call draw_esc_button

	exitBrowser:
		call getchar
		cmp al, 27
	je menu
jmp exitBrowser

second_cursor:
	call cursorApp
	drawCursor 85, 109, 122, 98

  call getchar

  cmp al, 13
	je initPhotos
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

%macro loadPhotos 1
  call video
  call %1
  call hold
%endmacro

initPhotos:
	call loading_app
	loadPhotos japan
	loadPhotos france
	loadPhotos england
	loadPhotos brasil
	loadPhotos italy
	loadPhotos russia
	loadPhotos germany
ret

third_cursor:
	call cursorApp
	drawCursor 85, 164, 177, 98

  call getchar
  
	cmp al, 13
  je prompt_command
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

%macro setprint 2
	simplePrintf	stringtab, blackColor
	simplePrintf %1, %2 ;string a ser printada
	call endl
%endmacro

%macro funcao 2
	mov si,stringinput
	mov di, %1
	call strcmp 
	cmp al,1
	je %2
%endmacro

prompt_command:
	xor ax,ax
	mov ds,ax
	call video
	mov bx, whiteColor
	xor dx,dx
	mov dl,'0'
	mov dh,'4'
	system_loop:
		call print_user
		mov bx, yellowColor
		mov di, stringinput
		call get_input

		funcao ls, command_ls
		funcao dan, command_dan
		funcao lk, command_lk
		funcao prds, command_prds
		funcao touch, command_touch
		funcao rm, command_rm
		funcao ping, command_ping
		funcao cd, command_cd
		funcao sudo, command_sudo
		funcao uname, command_uname
		funcao secret, command_secret
		funcao hello, command_hello
		funcao clear, command_clear
		funcao df, command_df
		funcao exit, command_exit
		
	jmp invalid	

	invalid:
		simplePrintf stringnocommand, whiteColor
		simplePrintf stringinput, whiteColor
		simplePrintf stringfound, whiteColor
	jmp system_loop
jmp $

print_user:
	simplePrintf stringTCK, whiteColor
	simplePrintf stringname, whiteColor
	simplePrintf stringpc, whiteColor
ret

endl:
	mov ax,0x0e0a
	int 10h
	mov al,0x0d
	int 10h
ret

clean:
	mov dx, 0 
	mov bh, 0      
	mov ah, 0x2
	int 0x10
	mov cx, 4000 ; print 2000 chars
	mov bh, 0
	mov bl, 10 
	mov al, 0x20 ; blank char
	mov ah, 0x9
	int 0x10
	mov dx, 0 ; Set cursor to top left-most corner of screen
	mov bh, 0      
	mov ah, 0x2
	int 0x10
ret

strcmp:;di é a constante
	strcmp_loop:
		mov al,byte [di]
		inc di
		mov ah,byte [si]
		inc si
		cmp al,0
		je eq
		cmp ah,al
		jne dif
		jmp strcmp_loop
	eq:
		mov al,1
		jmp strcmp_end
	dif:
		xor al,al
	strcmp_end:
	ret

get_input:
	xor cl,cl ;zera variavel cl (sera usada como contador)
	loop_get_input:
		mov ah,0
		int 16h
		cmp al,08h ;backspace teclado?
		je key_backspace_input
		cmp al,0dh ;enter teclado?
		je key_enter_input
		cmp cl,28h ;40 valores ja teclados?
		je loop_get_input ;só aceita backspace ou enter

		mov ah,0eh
		int 10h
		mov byte [di],al
		inc di
		inc cl
	jmp loop_get_input

	key_backspace_input:
		cmp cl,0
		je loop_get_input ; n faz sentido apagar string vazia

		dec di ; volta dl pra o caractere anterior
		mov byte [di],0 ; zera o valor daquela posicao
		dec cl ; diminui o contador em 1

		mov ah,0eh
		mov al,08h ; imprime backspace(volta o cursor)
		int 10h

		mov al,' '
		int 10h

		mov al,08h 
		int 10h
	jmp loop_get_input

	key_enter_input:
		mov al,0
		mov byte[di],al

		mov ah,0eh
		mov al,0dh
		int 10h
		mov al,0ah
		int 10h
	ret

; ------ Commands -------

command_ls:
	simplePrintf stringcommandlist, whiteColor
	setprint touch, whiteColor
	setprint rm, whiteColor
	setprint ping, whiteColor
	setprint cd, whiteColor
	setprint sudo, whiteColor
	setprint uname, whiteColor
	setprint hello, whiteColor
	setprint df, whiteColor
	setprint clear, whiteColor
	setprint exit, whiteColor
	setprint stringsecret2, lightGrayColor
jmp system_loop

command_dan:
	simplePrintf stringdan, whiteColor
jmp system_loop

command_lk:
	simplePrintf stringlk, whiteColor
jmp system_loop

command_prds:
	simplePrintf stringprds, whiteColor
jmp system_loop

command_touch:
	simplePrintf stringtouch, whiteColor
jmp system_loop

command_rm:
	simplePrintf stringrm, whiteColor
jmp system_loop

command_ping:
	simplePrintf stringping, whiteColor
jmp system_loop

command_cd:
	simplePrintf stringcd, whiteColor
jmp system_loop

command_sudo:
	simplePrintf stringsudo, whiteColor
jmp system_loop

command_uname:
	simplePrintf stringuname, greenColor
	simplePrintf stringuname2, greenColor
	simplePrintf stringuname3, greenColor
	simplePrintf stringuname4, greenColor
	simplePrintf stringuname5, greenColor
jmp system_loop

command_secret:
	setprint stringsecreta32, whiteColor
	setprint dan, greenColor
	setprint lk, greenColor
	setprint prds, greenColor
jmp system_loop

command_hello:
	setprint helloword, whiteColor
jmp system_loop

command_clear:
	call clean
jmp system_loop

command_df:
	simplePrintf sdf, whiteColor
jmp system_loop
command_exit
jmp menu

; ---------------//------------

fourth_cursor:
	call cursorApp
	drawCursor 265, 54, 67, 278

  call getchar
  
	cmp al, 13
	je notes_app
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

notes_app:
	call loading_app
	; Init Video
	mov ah, 0
  mov al, 2h
  int 10h
	; Set background Color
  mov ah, 0Bh
  mov bh, 0
  mov bl, 1
  int 10h

	setText 1, 1, ESC, whiteColor
	setText 1, 33, bloco_de_notas, whiteColor
	mov ah, 02h ; Setando o cursor
  mov dh, 2   ; Linha
	mov dl, 1   ; Coluna
	int 10h

  jmp teclado

fifth_cursor:
	call cursorApp
	drawCursor 265, 109, 122, 278

  call getchar

  cmp al, 13
	je time_app
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

await_3: startTimer 3
await_5: startTimer 5
await_9: startTimer 9

time_app:
	call loading_app
	call initVideo
	call draw_border
	setText 1, 14, time_to_rest, whiteColor
	setText 5, 4, instruction_time, whiteColor
	setText 9, 27, timer, whiteColor
	setText 9, 4, time_3, whiteColor
	setText 12, 4, time_5, whiteColor
	setText 15, 4, time_9, whiteColor
	setText 22, 11, obs, whiteColor
	call draw_esc_button

	mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 15   ; Linha
	mov dl, 29   ; Coluna
	int 10h

	call getchar
	cmp al, '1'
	je await_3
	cmp al, '2'
	je await_5
	cmp al, '3'
	je await_9
	cmp al, 27
	je menu
	call bad_input
jmp time_app

sixth_cursor:
	call cursorApp
	drawCursor 265, 164, 177, 278

  call getchar
  cmp al, 13
	je about_app
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

about_app:
	call initVideo
	setText 1, 10, spec, blue
	setText 4, 3, nomePc, blue
	setText 7, 3, organizacao, blue
	setText 10, 3, edicao, blue
	setText 13, 3, compilacao, blue
	setText 16, 3, processador, blue
	setText 19, 3, ram, blue
	setText 22, 3, sistema, blue
	setText 10, 22, spcs, blue
	setText 7, 22, org_sp, blue

	setText 13, 22, JDaniel, blue
	setText 16, 22, Pedro, blue
	setText 19, 22, LK, blue
	setText 22, 22, tchucoOS, blue
	setText 4, 22, stringname, blue

	call draw_white_border
	call draw_esc_button
	call getchar
	cmp al, 27
	je menu
jmp about_app

draw_dino: 
	mov si, dino
	mov dx, 0           
	mov bx, si
	add si, 2
	.for1:
		cmp dl, byte[bx+1]
		je .endfor1
		mov cx, 0       
		.for2:
			cmp cl, byte[bx]
			je .endfor2
			lodsb
			push dx ; Draw pixel
			push cx
			mov ah, 0ch
			add dx, 50
			add cx, 130
			int 10h
			pop cx
			pop dx
			inc cx
			jmp .for2
		.endfor2:
		inc dx
		jmp .for1
	.endfor1:
	ret

draw_esc_button:
	mov si, esc_button
	mov dx, 0            ; Y
	mov bx, si
	add si, 2
	.for1:
		cmp dl, byte[bx+1]
		je .endfor1
		mov cx, 0        ; X
	.for2:
		cmp cl, byte[bx]
		je .endfor2
		lodsb
		push dx
		push cx
		mov ah, 0ch
		add dx, 2
		add cx, 2
		int 10h
		pop cx
		pop dx
		inc cx
		jmp .for2
	.endfor2:
		inc dx
		jmp .for1
	.endfor1:
ret

data:
	; SO interface
	title db 'TchucoOS', 0
	app1 db 'Browser', 0
	app2 db 'Notes', 0
	app3 db 'Photos', 0
	app4 db 'RestTime', 0
	app5 db 'Terminal', 0
	app6 db 'About', 0
	; Browser APP
	offline db "Sem internet", 0
	text_fun1 db "Retire os cabos de rede e roteador", 0
	text_fun2 db "Desconecte de sua rede Wi-Fi", 0
	try db "Tente novamente", 0
	; Time to Rest APP
	time_to_rest db 'Time to Rest', 0
	instruction_time db 'Quantos minutos deseja descansar?', 0
	obs db 'Minutos = Segundos', 0
	work db 'Acabou o descanso, bom trabalho!', 0
	error db 'Digite 1, 2 ou 3', 0
	timer db 'Timer', 0
	time db 8,0
	choice db 8, 0
	time_3 db '1. 3 minuto', 0
	time_5 db '2. 5 minutos', 0
	time_9 db '3. 9 minutos', 0
	; About
	spec db 'Especificacoes do SO', 0
	org_sp db 'ThucosSA',0
	nomePc db 'Nome do PC ', 0
	organizacao db 'Organizacao', 0
	edicao db 'Edicao', 0
	spcs db 'Edicao da realeza',0
	compilacao db 'Compilacao do SO', 0
	processador db 'Processador', 0
	ram db 'RAM instalada', 0
	sistema db 'Tipo de sistema', 0
	tchucoOS db 'TchucoOS', 0
	JDaniel db 'Jose Daniel', 0
	LK db 'Lucas Emmanuel-LK', 0
	Pedro db 'Pedro Rogrigues', 0
	; Notes app
	bloco_de_notas db 'Bloco de notas', 0
	ESC db 'ESC', 0
	; Login
	stringusuario db 'Username:', 0
	string_senha db 'Create Password:',0
	String_senha2 db 'Confirm password:',0
	stringwrongpassword db 'Incorrect Password.',0
	stringpassword times 16 db 0
	password times 16 db 0
	
	; Command prompt
	stringTCK db 'ThucOS@',0
	stringpc db '-PC: ',0
	stringaskname db 'User name:',0
	stringnocommand db 'No command ',39,0
	stringfound db 39,' found.',10,13,0
	stringcommandlist db 'Command List:',10,13,0
	stringsecreta32 db 'Secret Commands:',13,0
	stringsecret2 db 'Secret para comandos incrivelmente secretos',10,13,0
	stringtab db '  ',0
	stringdan db '  Daniel ta ouvindo um pagodinho',10,13,0
	stringlk db '  Lk considera Eduardo o melhor professor',10,13,0
	stringprds db '  Eu Amo Bitcoin e provavelmente neste momento to dando uma cagada', 10,13,0
	stringtouch db '  lista de calouras mais lindas.c',10,13,0
	stringrm db '  Voce perdeu as calouras',10,13,0
	stringping db '  Nao esta conectado a internet :(',10,13,0
	stringcd db '  Voce trocou para ciencia da computacao',10,13,0
	stringsudo db '  Voce acaba de baixar um virus parabens',10,13,0
	stringuname db '  Sistema: thucOS muito melhor que qualquer linux :D',10,13,0
	stringuname2 db '  Ram: Lk disse que a ram era segredo',10,13,0
	stringuname3 db '  Processador: Pedro vendeu pra comprar Bitcoin',10,13,0
	stringuname4 db '  Memoria livre: daniel Gastou a memoria toda baixando pagode',10,13,0
	stringuname5 db '  Quem usa ThucOS faz uma grande favor ao meio ambiente :)',10,13,0
	helloword db ' Hello world pq aqui a gente programa very good ',13,0
	sdf db '  8mb livre amigao bora comprar um hd novo',13,10
	
	;commands
	ls db 'ls',0
	dan db 'dan',0
	prds db 'prds',0
	lk db 'lk',0
	touch db 'touch',0
	rm db 'rm',0
	ping db 'ping',0
	cd db 'cd',0
	sudo db 'sudo',0
	uname db 'uname',0
	secret db 'secret',0
	hello db 'hello',0
	clear db 'clear',0
	df db 'df',0
	exit db 'exit',0

	stringname times 16 db 0
	stringinput times 40 db 0

lacoste db 35, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 2, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 8, 2, 2, 0, 2, 2, 2, 2, 8, 8, 0, 0, 0, 0, 2, 2, 0, 2, 0, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 0, 2, 2, 2, 2, 0, 2, 2, 2, 2, 0, 2, 2, 2, 2, 0, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 6, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 2, 2, 0, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 8, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

dino db 30, 31, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 7, 7, 7, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 7, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 7, 15, 15, 15, 15, 15, 15, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 8, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 7, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 15, 7, 0, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 15, 15, 15, 7, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 15, 15, 15, 15, 15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 15, 15, 15, 15, 15, 0, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 15, 15, 15, 15, 0, 0, 7, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15

esc_button db 15, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 4, 15, 15, 15, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 4, 15, 12, 4, 4, 15, 15, 15, 4, 15, 15, 15, 4, 0, 0, 4, 15, 15, 15, 4, 15, 12, 4, 4, 15, 4, 4, 4, 0, 0, 4, 15, 4, 4, 4, 15, 15, 15, 4, 15, 4, 4, 4, 0, 0, 4, 15, 4, 4, 4, 4, 4, 15, 4, 15, 4, 4, 4, 0, 0, 12, 15, 15, 15, 4, 15, 15, 15, 4, 15, 15, 15, 12, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0

; ------- Código inspirado por -----------

hold:
	call getchar
	cmp al, 27
	je menu
	cmp al, ' '
	jne hold
ret

video:
	mov ah, 0 ; Set video mode
	mov al, 12h
	int 10h
ret

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
			setColor whiteColor
			inc cx
			cmp cx, 640
			jl .jp_loop_white
			inc dx
			jmp .jp_white
	.jp_red:
		mov cx, 320
		mov dx, 240
		filled_circle 125, 15625, redColor

	.jp_end:
		ret

france:
	setBackground redColor

	mov dx, 0

	.fr_blue:
	cmp dx, 480
	jg .fr_next
	mov cx, 0 ; inicio da linha 
	.fr_loop_blue:
		setColor blueColor
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
			setColor whiteColor
			inc cx
			cmp cx, 427
			jl .fr_loop_white
			inc dx
			jmp .fr_white

	.fr_end:
		ret

italy:
	setBackground redColor

	mov dx, 0

	.it_green:
	cmp dx, 480
	jg .it_next
	mov cx, 0 ; inicio da linha 
	.it_loop_green:
		setColor darkGreenColor
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
			setColor whiteColor
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
			setColor redColor
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
			setColor yellowColor
			inc cx
			cmp cx, 640
			jl .gr_loop_yellow
			inc dx
			jmp .gr_yellow
	
	.gr_end:
		ret

russia:
	setBackground redColor

	mov dx, 0

	.rs_white:
		cmp dx, 160
		jg .rs_blue
		mov cx, 0
		.rs_loop_white:
			setColor whiteColor
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
			setColor blueColor
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
			setColor whiteColor
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
			setColor redColor
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
			setColor redColor
			inc cx
			cmp cx, 640
			jl .en_loop_red2
			inc dx
			jmp .en_red_horizontal

	.en_end:
		ret

brasil:
	setBackground darkGreenColor

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
			setColor yellowColor
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
			setColor yellowColor
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
	call filled_circle 110, 12100, blueColor

	mov dx, 235
	mov cx, 225

	.br_white:
		cmp dx, 245
		jg .br_end
		push cx
		.loopLine4:
			setColor whiteColor
			inc cx
			cmp cx, 420
			jl .loopLine4
			inc dx
			pop cx
			jmp .br_white

	.br_end:
		ret

; ------- Lucas Cavalcanti Calabria 
; ------- Maria Eduarda Barros Mota 
; ------- José Maycon Lima Cunegundes

; ------ Código inspirador por ------
loading:
	mov cx, 50
	loop_loading:
		call loading_unit
		inc cx
		push cx
		xor cx, cx
		call fast_delay
		pop cx
		cmp cx, 250
		jne loop_loading
		mov ah, 86h; INT 15h / AH = 86h
		mov cx, 1	
		xor dx, dx ;CX:DX = interval in microseconds
		mov dx, 5	
		int 15h
	ret

loading_unit_off:
	mov ax,0x0c00 ;Write graphics pixel, preto
	mov bh,0x00
	mov dx, 160
	loop_loading_unit_off:
		int 10h
		inc dx
		cmp dx, 170
		jne loop_loading_unit_off
	ret 

loading_limit:
	mov ax,0x0c0f ;Write graphics pixel,white
	mov bh,0x00
	mov dx, 160
	loop_loading_limit:
		mov cx, 49
		int 10h
		mov cx, 250
		int 10h
		inc dx
		cmp dx, 170
		jne loop_loading_limit
	ret

loading_unit:
	mov ax,0x0c02 ;Write graphics pixel, verde
	mov bh,0x00
	mov dx, 160
	loop_loading_unit:
		int 10h	
		inc dx
		cmp dx, 170
		jne loop_loading_unit
	ret 
; ------- Mikahel Leal Dias 
; ------- Igor Eduardo Mascarenhas 
; ------- André Luiz Figueirôa de Barros