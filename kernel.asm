org 0x7e00
jmp 0x0000:start

data:

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

    call set_video
    mov si, bloco_de_notas
    call printf

    mov ah, 02h ; Setando o cursor
    mov dh, 2   ; Linha
	mov dl, 1   ; Coluna
	int 10h

    jmp teclado

jmp $

delay: 
    mov dx, 0
	.delay_print:
        inc dx
        mov cx, 0
    .time:
        inc cx
        cmp cx, 100000
        jne .time

	cmp dx, 100000
	jne .delay_print
    ret

set_video:
    mov ah, 0
    mov al, 2h
    int 10h

    mov ah, 0Bh
    mov bh, 0
    mov bl, 1
    int 10h

    mov ah, 02h  ;Setando o cursor
	mov bh, 0    ;Pagina 0
	mov dh, 1    ;Linha
	mov dl, 33   ;Coluna
	int 10h
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
    mov bl, 15  ; seta a cor do caractere, nesse caso, branco
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
    mov bl, 15  ; seta a cor do caractere, nesse caso, branco
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
    je start

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

bloco_de_notas db 'Bloco de notas', 0