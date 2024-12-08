[org 0x0100]

jmp start

; Intro headings
intro_1: db 'Ping Pong Game', 0
intro_2: db 'Welcome to Ping Pong!', 0
intro_3: db '1. Press "1" for Moving Screen. ', 0
intro_4: db '2. Press "2" for Static Screen. ', 0
intro_5: db '3. Press "3" to Exit. ', 0
intro_6: db 'Waiting for your COMMAND.....', 0

; Pause and Restart Game Message
PauseGameMessage: db 'Game Paused! Press any key to continue.', 0
RestartGameMessage: db 'Press "R" to restart the game and "ESC" to exit.', 0

; some player required attributes 
Score: db 'Score: ', 0
player1: db 'Player 1', 0
player2: db 'Player 2', 0
player1Score: db 0x30
player2Score: db 0x30

; paddles and ball positions
leftPaddle: dw 1760
rightPaddle: dw 1918
ballPosition: dw 2000
direction: dw 164
directionFlag: db 0 

; clouds for moving screen
Clouds: db '***__***       *****__****       ****__***', 0
CloudsLocation: dw 680

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

    mov di, [rightPaddle]
    push di 
    call printPaddles

    call delay
    call delay
    mov di, [ballPosition]
    push di
    call printBall
    call delay
    call delay

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
    push bx
    push es
    push di

    mov ax, 0xb800
    mov es, ax
    xor di, di

    processKeyPress:
        mov ah, 1h 
        int 16h
        jz near doneMovements

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

    jmp processKeyPress

    MoveRightPaddleUp:
        mov bx, [rightPaddle]
        sub bx, 160
        cmp bx, 640
        jl doneMovements
        sub word [rightPaddle], 160
        jmp doneMovements

    MoveRightPaddleDown:
        mov bx, [rightPaddle]
        add bx, 160
        cmp bx, 3200
        jg doneMovements
        add word [rightPaddle], 160
        jmp doneMovements

    MoveLeftPaddleUp:
        mov bx, [leftPaddle]
        sub bx, 160
        cmp bx, 640
        jl doneMovements
        sub word [leftPaddle], 160
        jmp doneMovements

    MoveLeftPaddleDown:
        mov bx, [leftPaddle]
        add bx, 160
        cmp bx, 3190
        jg doneMovements
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
        pop di
        pop es
        pop bx
        ret 

; A subroutine to create a delay
delay:
    push cx
    push dx

    mov cx, 0xFFFF  ; Set the delay count (adjust for desired speed)
    mov dx, 0xFFFF
    delayLoop:
    loop delayLoop 

    pop dx
    pop cx
    ret

; A subroutine to move the ball and check for collision
moveBall:
    push ax
	push dx

    ; check left paddle collision
	check_left_paddle_collision:
		mov ax, [leftPaddle]
        add ax, 6
		cmp [ballPosition], ax
		jne check_left_paddle_middle_part_collision
		add word [direction], 8
		jmp boundary_crossing_checker

	check_left_paddle_middle_part_collision:
		add ax, 160 
		cmp [ballPosition], ax
		jne check_left_paddle_lower_part_collision
		add word [direction], 8
		jmp boundary_crossing_checker

	check_left_paddle_lower_part_collision:	
		add ax, 160 
		cmp [ballPosition], ax
		jne check_right_paddle_collision 
		add word [direction], 8
		jmp boundary_crossing_checker

    ; check right paddle collision
	check_right_paddle_collision:
		mov ax, [rightPaddle]
		cmp [ballPosition], ax
		jne check_right_paddle_middle_part_collision
		sub word [direction], 8
		jmp boundary_crossing_checker

	check_right_paddle_middle_part_collision:
		add ax, 160 
		cmp [ballPosition], ax
		jne check_right_paddle_lower_part_collision
		sub word [direction], 8
		jmp boundary_crossing_checker

	check_right_paddle_lower_part_collision:
        add ax, 160
		cmp [ballPosition], ax
		jne boundary_crossing_checker 
		sub word [direction], 8
		jmp boundary_crossing_checker

	boundary_crossing_checker:
		mov ax, [direction] 
		mov dx, [ballPosition] 
		add dx, ax
		mov ax, 320
		add ax, 160
		cmp dx, ax
		jge check_bottom_boundry

		add word [direction], 320 
		jmp move_ball_end

	check_bottom_boundry:
		mov ax, 3520
		sub ax, 160
		cmp dx, ax 
		jle move_ball_end

		sub word [direction], 320
		jmp move_ball_end

	move_ball_end:
		mov ax, [direction] 
		add [ballPosition], ax 
	
		pop dx
		pop ax
		ret

; A subroutine to check for left right corssing of border
checkLeftRightBorder:
    push ax
    push bx
    push dx

    xor dx, dx
    ; check for left boundry
    mov ax, [ballPosition]
    sub ax, 2
    mov bx, 160
    div bx
    cmp dx, 0
    jne checkForRightSide 

    cmp word[direction],164
    je addScoreForPlayer1

    cmp word[direction],-156
    je addScoreForPlayer1

    add byte [player2Score], 1
    call ResetEquipments
    jmp DoneChecking

    checkForRightSide:
        mov ax, [ballPosition]
        div bx
        cmp dx, 0
        jne DoneChecking

        addScoreForPlayer1:
        add byte [player1Score], 1
        call ResetEquipments

    DoneChecking:
    pop dx
    pop bx
    pop ax
    ret 

; A subroutine to reset the paddles and balls position
ResetEquipments:
    mov word [leftPaddle], 1760
    mov word [rightPaddle], 1918
    mov word [ballPosition], 1998
    ret

; A subroutine to print clouds
printClouds:
    push di

    mov di, [CloudsLocation]
    push di
    push word Clouds
    call printMessage

    add di, 160
    cmp di, 3520
    jl donePrintingClouds

    mov di, 680

    donePrintingClouds:
        mov [CloudsLocation], di
    pop di 
    ret 

; A subroutine to reset the game
resetGame:

    mov word [leftPaddle], 1760
    mov word [rightPaddle], 1918
    mov word [ballPosition], 1998
    mov byte [player1Score], 0x30
    mov byte [player2Score], 0x30
    ret

; A subroutine to decalre winner
declareWinner:
    
    mov ax, 3
    cmp byte [player1Score], 0x35
    je player1Won

    cmp byte [player2Score], 0x35
    jne EndRoutine

    mov ax, 2
    jmp EndRoutine

    player1Won:
        mov ax, 1

    EndRoutine:
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
        je near ExitOption
        jmp InValidInput

MovingScreen:
    call delay
    call clrScreen

    call printClouds

    push word Score
    push word player2
    push word player1
    call printGameEnvironment
    call playGame
    call moveBall
    call checkLeftRightBorder

    cmp ax, 0x011B
    je start

    call declareWinner
    cmp ax, 3
    jge MovingScreen
    
    jmp GameEnd

StaticScreen:
    call delay
    call clrScreen
    push word Score
    push word player2
    push word player1
    call printGameEnvironment
    call playGame
    call moveBall
    call checkLeftRightBorder
   
    cmp ax, 0x011B
    je start

    call declareWinner

    cmp ax, 3
    jge StaticScreen


GameEnd:
    call clrScreen
    cmp ax, 1
    je Player1Won

    mov di, 1956
    sub di, 320
    push di
    push word winner2
    call printMessage
    jmp printingin

    Player1Won: 
        mov di, 1956
        sub di, 320
        push di
        push word winner1
        call printMessage
    
    printingin:
        mov di, 1956
        sub di, 160
        push di
        push word RestartGameMessage
        call printMessage

        TakeInput:
        call getKey
        cmp ax , 0x011B
        je endGame

        cmp al, 'r'
        je start
        jmp TakeInput

    endGame:
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

