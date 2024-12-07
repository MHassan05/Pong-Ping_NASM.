[org 0x0100]

jmp start

; Intro headings
intro_1: db 'Ping Pong Game', 0
intro_2: db 'Welcome to Ping Pong!', 0
intro_3: db '1. Press "1" for Moving Screen. ', 0
intro_4: db '2. Press "2" for Static Screen. ', 0
intro_5: db '3. Press "3" to Exit. ', 0
intro_6: db 'Waiting for your COMMAND.....', 0

; Pause Game Message
PauseGameMessage: db 'Game Paused! Press any key to continue.', 0

; some player required attributes 
Score: db 'Score: ', 0
player1: db 'Player 1', 0
player2: db 'Player 2', 0
player1Score: db 0x30
player2Score: db 0x30

; paddles and ball positions
leftPaddle: dw 1760
rightPaddle: dw 1918
ballPosition: dw 1998

; clouds for moving screen
Clouds: db '***__***   *****__****   ****__***', 0

; winning headings
winner1: db 'Congratulations! Player 1 won the game.', 0
winner2: db 'Congratulatons! Player 2 won the game.', 0

; outro headings
Outro: db 'Thank you for playing the game! Allah Hafiz', 0

; Credits
Credits: db 'Developed By:  Rizwan Mustafa Khan(23F-0709)   AND   Muhammad Hassan (23F-0676)', 0

; A subroutine that will clear the whole screen
clrScreen:
    push ax
    push bx
    push cx
    push dx

    mov ah, 0x06
    mov al, 0x00
    mov bh, 0x07
    mov cx, 0
    mov dx, 0x184f
    int 0x10

    pop dx
    pop cx
    pop bx
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

; A subroutine that will print the gaming screen
printGameEnvironment:
    push bp
    mov bp, sp
    push ax
    push cx 
    push es
    push di
    push si

    mov ax, 0xb800
    mov es, ax
    xor di, di
    mov di, 320
    
    push di
    push word [bp + 4]
    call printMessage

    add di, 40
    push di
    push word [bp + 8]
    call printMessage

    add di, 14
    mov al, [player1Score]
    mov ah, 0x07
    mov word [es:di], ax

    add di, 26
    push di
    push word [bp + 6]
    call printMessage

    add di, 40
    push di
    push word [bp + 8]
    call printMessage

    add di, 14
    mov al, [player2Score]
    mov ah, 0x07
    mov word [es:di], ax

    mov di, 480
    mov cx, 80
    mov ax, 0x072D
    GameHeader:
        mov word [es:di], ax
        cmp cx, 42
        jne Continue

        mov si, di
        sub si, 160
        mov word [es:si], 0x077C

        sub si, 160
        mov word [es:si], 0x077C

        sub si, 160
        mov word [es:si], 0x077C
            
        Continue:
        add di, 2
        loop GameHeader

    mov di, 3520
    mov cx, 80
    GameFooter:
        mov word [es:di], ax
        add di, 2
        loop GameFooter

    push di
    push word Credits
    call printMessage

    mov di, [leftPaddle]
    push di
    call printPaddles

    mov di, [ballPosition]
    push di
    call printBall

    mov di, [rightPaddle]
    push di 
    call printPaddles

    pop si
    pop di
    pop es 
    pop cx
    pop ax 
    pop bp
    ret 6

; A subroutine that will get the key press from user
getKey:
    mov ah, 0
    int 16h         ; taking input from user 
    ret

; A subroutine that will print the paddles
printPaddles:
    push bp
    mov bp, sp
    push cx
    push es
    push di

    mov di, 0xb800
    mov es, di

    mov di, [bp + 4]
    mov cx, 3
    printPaddle:
        mov word [es:di], 0x077C
        add di, 160
        loop printPaddle

    pop di
    pop es
    pop cx
    pop bp
    ret 2

; A subroutine that will print the ball
printBall:
    push bp
    mov bp, sp
    push di

    mov di, [bp + 4]
    mov word [es:di], 0x076F              ; ascii code for ball

    pop di
    pop bp
    ret 2

; A subroutine to play the game 
playGame:
    push bp
    mov bp, sp
    push bx
    push cx
    push dx
    push es
    push di
    push si

    mov ax, 0xb800
    mov es, ax
    xor di, di

    reTakeInput:
    mov ah, 0
    int 16h

    cmp al, 'w'
    je MoveLeftPaddleUp

    cmp al, 's'
    je MoveLeftPaddleDown

    cmp al, 'p'
    je PauseGame

    cmp ax, 0x4800
    je MoveRightPaddleUp

    cmp ax, 0x5000
    je MoveRightPaddleDown

    cmp ax, 0x011B
    je doneMovements

    jmp reTakeInput

    MoveRightPaddleUp:
        sub word [rightPaddle], 160
        jmp doneMovements

    MoveRightPaddleDown:
        add word [rightPaddle], 160
        jmp doneMovements

    MoveLeftPaddleUp:
        sub word [leftPaddle], 160
        jmp doneMovements

    MoveLeftPaddleDown:
        add word [leftPaddle], 160
        jmp doneMovements

    PauseGame:
        mov di, 1956
        push di
        push word PauseGameMessage
        call printMessage
        mov ah, 0
        int 16h

    doneMovements:
    pop si
    pop di
    pop es
    pop dx
    pop cx
    pop bx
    pop bp
    ret 

resetGame:
    mov word [leftPaddle], 1760
    mov word [rightPaddle], 1918
    mov word [ballPosition], 1998
    mov byte [player1Score], 0x30
    mov byte [player2Score], 0x30
    ret

start:
    call printIntro
    call resetGame
    InValidInput:
        call getKey
        cmp al, '1'
        je MovingScreen
        cmp al, '2'
        je StaticScreen
        cmp al, '3'
        je ExitOption
        jmp InValidInput

MovingScreen:

    call clrScreen
    push word Score
    push word player2
    push word player1
    call printGameEnvironment
    
    mov di, 680
    push di
    push word Clouds
    call printMessage
    call playGame

    cmp ax, 0x011B
    je start
    jmp MovingScreen

StaticScreen:
    call clrScreen
    push word Score
    push word player2
    push word player1
    call printGameEnvironment
    call playGame

    cmp ax, 0x011B
    je start

    jmp StaticScreen

GameEnd:
    mov ax, 1956
    jmp Exit

ExitOption:
    mov ax, 3710

Exit:
    push ax
    push word Outro
    call printMessage
    mov ax, 4c00h
    int 21h
