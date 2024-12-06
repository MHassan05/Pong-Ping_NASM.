[org 0x0100]

jmp start

msg1: db 'Under Development........ In Sha Allah we will complete it Soon!', 0
; Intro headings
intro_1: db 'Ping Pong Game', 0
intro_2: db 'Welcome to Ping Pong!', 0
intro_3: db '1. Press "1" for Moving Screen. ', 0
intro_4: db '2. Press "2" for Static Screen. ', 0
intro_5: db '3. Press "3" to Exit. ', 0
intro_6: db 'Waiting for your COMMAND.....', 0

; outro message for user 
Outro: db 'Thank you for playing the game! Allah Hafiz', 0

; A subroutine that will clear the whole screen
clrScreen:
    mov ah, 0x06
    mov al, 0x00
    mov bh, 0x07
    mov cx, 0
    mov dx, 0x184f
    int 0x10
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
    mov di, [bp + 6]

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
        ret 4

; A subroutine that will print the intro of the game
printIntro:
    call clrScreen

    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es

    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov di, 830

    mov ax, 0x072D
    mov cx, 47
    rep stosw 
    mov cx, 12
    RightSideBorder:
        stosw
        add di, 158
        loop RightSideBorder

    mov cx, 47
    LowerBorder:
        mov word [es:di], ax
        sub di, 2
        loop LowerBorder

    mov cx, 12
    LeftSideBorder:
        mov word [es:di], ax
        sub di, 160
        loop LeftSideBorder
    
    add di, 192
    push di
    push word intro_1
    call printMessage

    add di, 154
    push di
    push word intro_2
    call printMessage

    add di, 300
    push di
    push word intro_3
    call printMessage

    add di, 320
    push di
    push word intro_4
    call printMessage

    add di, 320
    push di
    push word intro_5
    call printMessage

    add di, 332
    push di
    push word intro_6
    call printMessage

    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret 

; A subroutine that will get the key press from user
getKey:
    mov ah, 0
    int 16h         ; taking input from user 
    ret

start:
    call printIntro

    InValidInput:
        call getKey
        cmp al, '1'
        je MovingScreen
        cmp al, '2'
        je StaticScreen
        cmp al, '3'
        je Exit
        jmp InValidInput

MovingScreen:
    call clrScreen
    mov ax, 1618
    push ax
    push word msg1
    call printMessage

    jmp Exit
StaticScreen:
    call clrScreen
    mov ax, 1618
    push ax
    push word msg1
    call printMessage

Exit:
    mov ax, 3710
    push ax
    push word Outro
    call printMessage
    mov ax, 4c00h
    int 21h
