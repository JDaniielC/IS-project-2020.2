org 0x500
jmp 0x0000:start

start:
	xor ax,ax
	mov ds,ax
	mov es, ax

	Reset_Disk_Drive:
		mov ah,0		;INT 13h AH=00h: Reset Disk Drive
		mov dl,0		;floppydisk 
		int 13h			;interrupção de acesso ao disco
	jc Reset_Disk_Drive		;se der erro CF é setado, daí voltaria para o Reset_Disk_Drive

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

jmp $