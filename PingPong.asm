[org 0x0100]

jmp start

msg1: db 'We will start this project soon! IN SHA ALLAH.', 0

; A subroutine that will clear the whole screen
clrScreen:
    push ax
    push es
    push di
    push cx

    mov ax, 0xb800                       ; store address of video memory in ax register
    mov es, ax                          ; now move that address to es register

    xor di, di                          ; clear the stored value in di register
    mov ax, 0720h                       ; store ascii(hex) value of space in ax register
    mov cx, 2000 

    rep stosw 

    pop cx
    pop di
    pop es
    pop ax
    ret

; A subroutine that will calculate the length of string
strLen:
    push bp
    mov bp, sp
    push es
    push di
    push cx

    les di, [bp + 4]
    mov cx, 0xFFFF
    xor al, al
    repne scasb
    mov ax, 0xFFFF
    sub ax, cx
    dec ax

    pop cx
    pop di
    pop es 
    pop bp
    ret 4

; A subroutine that will print the message on console
printMessage:
    push bp
    mov bp, sp
    push ax
    push cx
    push es
    push di
    push si 

    push ds 
    push word [bp + 4]
    call strLen
    cmp ax, 0
    jz EXIT
    mov cx, ax

    mov ax, 0xb800
    mov es, ax
    xor di, di

    mov si, [bp + 4]
    mov ah, 0x07

    cld 
    printNextChar:
        lodsb
        stosw
        loop printNextChar

    EXIT:
        pop si 
        pop di
        pop es
        pop cx
        pop ax
        pop bp
        ret 2

start:
    call clrScreen

    push word msg1
    call printMessage

    mov ax, 4c00h
    int 21h