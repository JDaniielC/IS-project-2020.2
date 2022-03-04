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

%macro startTimer 1
    mov al, %1+48
    call putchar

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
        mov ah, 02h  ; Setando o cursor
        mov bh, 0    ; Pagina 0
        mov dh, 12   ; Linha
        mov dl, 29 
        int 10h
        mov si, time
        call printf
    jmp .loop
%endmacro

start:
    mov ah, 0   
    mov al, 13h ; modo VGA
    int 10h

    setText 1, 14, time_to_rest
    setText 5, 4, instruction_time
    setText 9, 27, timer
    setText 9, 4, time_3
    setText 12, 4, time_5
    setText 15, 4, time_9
    setText 22, 11, obs

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
    cmp al, 27 ; Esq = exit
    je start
    call bad_input
jmp $

await_3: startTimer 3
await_5: startTimer 5
await_9: startTimer 9

putchar:
  mov ah, 0eh ;modo de imprmir na tela
  int 10h ;imprime o que tá em al
  ret

getchar:
  mov ah, 00h
  int 16h
ret

delay:
    mov ah, 86h
    mov cx, 10
    mov dx, 500
    int 15h
ret

bad_input:
    setText 15, 20, error
    call delay
jmp start

good_job:
    setText 20, 4, work
    call delay
jmp start

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
    error db 'Digite 1, 2 ou 3', 0
    timer db 'Timer', 0
    time db 8,0
    choice db 8, 0
    time_3 db '1. 3 minuto', 0
    time_5 db '2. 5 minutos', 0
    time_9 db '3. 9 minutos', 0