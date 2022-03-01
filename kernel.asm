org 0x7e00
jmp 0x0000:start

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    mov ah, 0   
    mov al, 13h ; modo VGA
    int 10h

    ; Colocando o Titulo
	mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 1    ; Linha
	mov dl, 14   ; Coluna
	int 10h
    mov si, time_to_rest
    call printf

    mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 5    ; Linha
	mov dl, 4    ; Coluna
	int 10h
    mov si, instruction_time
    call printf

    mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 9    ; Linha
	mov dl, 27   ; Coluna
	int 10h
    mov si, timer
    call printf

    mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 9    ; Linha
	mov dl, 4    ; Coluna
	int 10h
    mov si, time_3
    call printf

    mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 12    ; Linha
	mov dl, 4    ; Coluna
	int 10h
    mov si, time_5
    call printf

    mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 15    ; Linha
	mov dl, 4    ; Coluna
	int 10h
    mov si, time_10
    call printf

    mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 22   ; Linha
	mov dl, 11   ; Coluna
	int 10h
    mov si, obs
    call printf

    mov ah, 03h ; escolhe a funcao de ler o tempo do sistema
    mov ch, 0   ; horas
    mov cl, 0   ; minutos
    mov dh, 0   ; segundos
    mov dl, 1   ; seta o modo entre dia e noite do relogio do sistema(1 para dia)
    int 1aH     ; interrupcao que lida com o tempo do sistema

    call await

jmp $

putchar:
  mov ah, 0eh ;modo de imprmir na tela
  int 10h ;imprime o que tá em al
  ret

getchar:
  mov ah, 00h
  int 16h
  ret

good_job:
    mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 20   ; Linha
	mov dl, 4 
	int 10h

    mov si, work
    call printf

    mov ah, 86h
    mov cx, 500
    mov dx, 500
    int 15h
jmp start

await:
    mov ah, 02h ; escolhe a funcao de ler o tempo do sistema
    int 1aH     ; interrupcao que lida com o tempo do sistema
    
    cmp dh, 5h
    je good_job

    add dh, 48
    mov [time], dh

    mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 12   ; Linha
	mov dl, 29 
	int 10h

    mov si, time
    call printf

jmp await

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
    time_to_rest db 'Time to Rest', 0
    instruction_time db 'Quantos minutos deseja descansar?', 0
    obs db 'Minutos = Segundos', 0
    work db 'Acabou o descanso, bom trabalho!', 0
    timer db 'Timer', 0
    time db 8,0
    choice db 8, 0
    time_3 db '1. 3 minuto', 0
    time_5 db '2. 5 minutos', 0
    time_10 db '3. 10 minutos', 0