org 0x500
jmp 0x0000:start

start:
    xor ax, ax
    mov ds, ax
    mov es, ax

reset:
    mov ah, 00h ;reseta o controlador de disco
    mov dl, 0   ;floppy disk
    int 13h

    jc reset    ;se o acesso falhar, tenta novamente

    jmp load_kernel

load_kernel:
    ;Setando a posição do disco onde kernel.asm foi armazenado(ES:BX = [0x7E00:0x0])
    mov ax,0x7E0	;0x7E0<<1 + 0 = 0x7E00
    mov es,ax
    xor bx,bx		;Zerando o offset

    mov ah, 0x02 ;le o setor do disco
    mov al, 20  ;porção de setores ocupados pelo kernel.asm
    mov ch, 0   ;track 0
    mov cl, 3   ;setor 3
    mov dh, 0   ;head 0
    mov dl, 0   ;drive 0
    int 13h

    jc load_kernel ;se o acesso falhar, tenta novamente

    jmp 0x7e00  ;pula para o setor de endereco 0x7e00, que é o kernel
    

times 510-($-$$) db 0 ;512 bytes
dw 0xaa55	