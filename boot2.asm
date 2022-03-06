org 0x500
jmp 0x0000:start

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

start:
	xor ax,ax
	mov ds,ax
	mov es, ax

	Reset_Disk_Drive:
		mov ah,0		;INT 13h AH=00h: Reset Disk Drive
		mov dl,0		;floppydisk 
		int 13h			;interrupção de acesso ao disco
	jc Reset_Disk_Drive		;se der erro CF é setado, daí voltaria para o Reset_Disk_Drive

	call initVideo

    call draw_logo

    mov ah, 02h  ; Setando o cursor
	mov bh, 0    ; Pagina 0
	mov dh, 15   ; Linha
	mov dl, 16   ; Coluna
	int 10h
    mov si, tchucoOS
    call print_string

	mov ah, 86h
	mov cx, 30
	mov dx, 500
	int 15h

	mov ax,0x07e0;mov ax,0x07e0
	mov es,ax ; 
	xor bx, bx ; 07e0:0000 -> 0x07e00

	Load_Kernel:
		mov ah, 0x02		;;INT 13h AH=02h: Read Sectors From Drive
		mov al, 30	;numero de setores ocupados pelo kernel
		mov ch, 0		;trilha 0
		mov cl, 3	;vai comecar a ler do setor 3
		mov dh, 0		;cabeca 0
		mov dl, 0		;drive 0
		int 13h			;interrupcao de disco
	jc Load_Kernel	;se der erro CF é setado, daí voltaria para o Load_Kernel	

jmp 0x7e00

print_string:
	mov bl,02h
loop_print_string:
    mov cx,1
    lodsb
    cmp al,0
    je end_print_string
    mov ah,0eh
    int 10h
    jmp loop_print_string
end_print_string:
    ret

jmp $

initVideo:
	mov ah, 00h
	mov al, 13h
	int 10h
ret

 tchucoOS db 'TchucoOS', 0
 lacoste db 35, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 2, 2, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 0, 0, 2, 2, 2, 2, 2, 2, 0, 0, 8, 2, 2, 0, 2, 2, 2, 2, 8, 8, 0, 0, 0, 0, 2, 2, 0, 2, 0, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 0, 2, 2, 2, 2, 0, 2, 2, 2, 2, 0, 2, 2, 2, 2, 0, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 0, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 6, 2, 2, 2, 2, 0, 0, 0, 2, 2, 2, 2, 0, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 4, 4, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 4, 4, 4, 4, 2, 2, 0, 8, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 8, 2, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
