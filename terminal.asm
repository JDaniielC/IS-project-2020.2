bits 16 
org 0x8e00
jmp 0x0000:start

%define WHITE 0x000f
%define BLACK 0x0000

;OUTPUT
stringTCK db 'ThucOS@',0
stringpc db '-PC: ',0
stringaskname db 'User name: ',0
stringnocommand db 'No command ',39,0
stringfound db 39,' found.',10,13,0
stringcommandlist db 'Command List:',10,13,0
stringsecreta32 db 'Secret Commands:',13,0
stringsecret2 db 'Secret para comandos incrivelmente secretos',10,13,0
stringtab db '  ',0
stringdan db '  Daniel ta ouvindo um pagodinho',10,13,0
stringlk db '  Inimigo do Trabalho',10,13,0
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

;comanditos
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


stringname times 16 db 0
stringinput times 40 db 0

%macro setprint 1
	mov si,stringtab
	call print_string
	mov si, %1 ;string a ser printada
	call print_string	
	call endl
%endmacro
%macro setcommand 1
	mov bx,WHITE
	mov si, %1
	call print_string
%endmacro

%macro printuname 1
	mov si,%1
	call print_string
%endmacro

%macro funcao 2
	mov si,stringinput
	mov di, %1
	call strcmp 
	cmp al,1
	je %2
%endmacro
start:
	xor ax,ax
	mov ds,ax

	mov bx,WHITE
	xor dx,dx
	mov dl,'0'
	mov dh,'4'
		system_loop:
			call print_user
			mov bx, 14
			mov di,stringinput
			call get_input

            mov bx, 15
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
			

			jmp invalid

			invalid:
				mov si,stringnocommand
				call print_string
				mov si,stringinput
				call print_string
				mov si,stringfound
				call print_string
			jmp system_loop


	jmp $


print_string:
	loop_print_string:
		lodsb
		cmp al,0
		je end_print_string
		mov ah,0eh
		int 10h
		jmp loop_print_string
	end_print_string:
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
	
print_user:
	mov bx,WHITE
	mov si,stringTCK
	call print_string
	mov si,stringname
	call print_string
	mov si,stringpc
	call print_string
	ret

endl:
	mov ax,0x0e0a
	int 10h
	mov al,0x0d
	int 10h
	ret

clean:
;; Codigo para limpar a tela
mov dx, 0 ; Set the cursor to top left-most corner of screen
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
			je loop_get_input ;n faz sentido apagar string vazia

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

	command_ls:
		mov bx,WHITE
		mov si,stringcommandlist
		call print_string
		setprint touch
        setprint rm
        setprint ping
		setprint cd
		setprint sudo
		setprint uname
		setprint hello
		setprint df
		setprint clear
		mov bx, 7
		setprint stringsecret2
		jmp system_loop
	command_dan:
		setcommand stringdan
        jmp system_loop
    command_lk:
		setcommand stringlk
        jmp system_loop
    command_prds:
		setcommand stringprds
        jmp system_loop
    command_touch:
		setcommand stringtouch
        jmp system_loop
    command_rm:
        setcommand stringrm
        jmp system_loop
    command_ping:
		setcommand stringping
        jmp system_loop
	command_cd:
		setcommand stringcd
        jmp system_loop
	command_sudo:
		setcommand stringsudo
		jmp system_loop
	command_uname:
		mov bx, 10 ;verde = lacoste
		printuname stringuname
		printuname stringuname2
		printuname stringuname3
		printuname stringuname4
		printuname stringuname5
		jmp system_loop
	command_secret:
		setprint stringsecreta32
		setprint dan
		setprint lk
		setprint prds
		jmp system_loop

	command_hello:
		setprint helloword
		jmp system_loop
	
	command_clear:
		call clean
		jmp system_loop
	
	command_df:
		setcommand sdf
		jmp system_loop

;final