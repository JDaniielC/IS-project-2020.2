org 0x7e00
jmp 0x0000:start

data:
	
	;Dados do projeto...

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    ;Código do projeto...
    mov ah, 0   
    mov al, 13h ; modo VGA
    int 10h

jmp $