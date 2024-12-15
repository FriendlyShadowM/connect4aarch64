.include "debug.s"
.global main

.data
arr: .fill 42, 4, 0
playerState: .word 2

.text
main:
    
showboard:
    ldr x0, =arr
    bl printArray
    b checkPlayer
    
input:
    bl inputCol
    ldr x19, =arr
    mov x8, #1             //resets horizontal counter to 1 to count player's current token
    
checkValid:
    mov x1, x0    //x1 = index
    add x1, x1, 35    //set index at bottom

validCheckLoop:
    ldrsw x2, [x19, x1, lsl#2]    //element at index
    cmp x2, #0            //check token at index
    b.eq valid
    
    cmp x1, #0            //check if index has reached top
    b.lt notValid
    
    sub x1, x1, #7            //move index up row
    b validCheckLoop

notValid:
    printStr full_column
    b input

valid:
    ldr x3, playerState
    ldr x0, =arr
    str w3, [x0, x1, lsl#2]        //store register in arr
    
winCheck:
    mov x5, x1            //copy index
    mov x6, x3            //player #
    
    mov x7, #0            //vertical counter
    mov x9, #0            //left diag counter
    mov x10, #0           //right diag counter
    b vertCheck           //check vertical first
    
checkPlayer:
    ldr x4, =playerState
    ldr x3, playerState
    cmp x3, #1
    b.eq swapPlayer
    
    add x3, x3, #-1
    str x3, [x4]
    bl player1
    b input
    
swapPlayer:
    add x3, x3, #1
    str x3, [x4]
    bl player2
    b input

vertCheck:
    mov x20, x5            //store position
    mov x21, x6            //store player number
    mov x8, #0             //reset consecutive counter
    
scanColumn:
    cmp x20, #42           //check if past board bottom
    b.ge endVertical       //if past bottom no win found
    
    ldrsw x24, [x19, x20, lsl#2]  //load value at position
    
    cmp x24, x21           //compare with player number
    b.ne resetVertCount    //if not match reset counter
    
    add x8, x8, #1         //increment counter
    cmp x8, #4             //check for win
    b.eq win             //if 4 in row exit
    b nextVertPos         //check next position
    
resetVertCount:
    mov x8, #0             //reset counter
    
nextVertPos:
    add x20, x20, #7       //move down one row
    b scanColumn          //continue scan
    
endVertical:
    mov x8, #0             //reset counter
    b diagRightCheck      //check diagonal right next

diagRightCheck:
    mov x20, x5            //store position
    mov x21, x6            //store player number
    mov x8, #0             //reset consecutive counter
    
scanDiagRight:
    cmp x20, #42           //check if past board bottom
    b.ge endDiagRight      //if past bottom no win found
    
    //check if at right edge
    mov x24, #7            //divisor for column check
    mov x25, x20           //copy position
    add x25, x25, #1       //look ahead one position
    udiv x26, x25, x24     //divide by 7 to get next row
    udiv x27, x20, x24     //divide by 7 to get current row
    cmp x26, x27          //compare rows
    b.ne endDiagRight     //if different rows stop checking
    
    ldrsw x24, [x19, x20, lsl#2]  //load value at position
    
    cmp x24, x21           //compare with player number
    b.ne resetDiagRight    //if not match reset counter
    
    add x8, x8, #1         //increment counter
    cmp x8, #4             //check for win
    b.eq win             //if 4 in row exit
    b nextDiagRight       //check next position
    
resetDiagRight:
    mov x8, #0             //reset counter
    
nextDiagRight:
    add x20, x20, #8       //move down-right (down 7 + right 1)
    b scanDiagRight       //continue scan
    
endDiagRight:
    mov x8, #0             //reset counter
    b diagLeftCheck       //check diagonal left next

diagLeftCheck:
    mov x20, x5            //store position
    mov x21, x6            //store player number
    mov x8, #0             //reset consecutive counter
    
scanDiagLeft:
    cmp x20, #42           //check if past board bottom
    b.ge endDiagLeft       //if past bottom no win found
    
    //check if at left edge
    mov x24, #7            //divisor for column check
    mov x25, x20           //copy position
    sub x25, x25, #1       //look back one position
    udiv x26, x25, x24     //divide by 7 to get prev row
    udiv x27, x20, x24     //divide by 7 to get current row
    cmp x26, x27          //compare rows
    b.ne endDiagLeft      //if different rows stop checking
    
    ldrsw x24, [x19, x20, lsl#2]  //load value at position
    
    cmp x24, x21           //compare with player number
    b.ne resetDiagLeft     //if not match reset counter
    
    add x8, x8, #1         //increment counter
    cmp x8, #4             //check for win
    b.eq win             //if 4 in row exit
    b nextDiagLeft        //check next position
    
resetDiagLeft:
    mov x8, #0             //reset counter
    
nextDiagLeft:
    add x20, x20, #6       //move down-left (down 7 - left 1)
    b scanDiagLeft        //continue scan
    
endDiagLeft:
    mov x8, #0             //reset counter
    b horiCheck           //check horizontal next
    
horiCheck:
    mov x20, x5            //store position where piece placed
    mov x21, x6            //store player number
    
    //calculate start of row where piece placed
    mov x22, x20           //copy position
    mov x24, #7            //divisor for row calculation
    udiv x23, x22, x24     //divide by 7 to get row number
    mul x23, x23, x24      //multiply by 7 to get start of row
    mov x22, x23           //x22 now points to start of row
    
    mov x8, #0             //counter for consecutive pieces
    
scanRow:
    add x24, x23, #7       //end of row = start + 7
    cmp x22, x24          //check if past end of row
    b.ge endLeft          //if past end no win found
    
    ldrsw x24, [x19, x22, lsl#2]  //load value at position
    
    cmp x24, x21           //compare with player number
    b.ne resetCount        //if not match reset counter
    
    add x8, x8, #1         //increment counter
    cmp x8, #4             //check for win
    b.eq win             //if 4 in row exit
    b nextPos             //check next position
    
resetCount:
    mov x8, #0             //reset counter
    
nextPos:
    add x22, x22, #1       //move to next position
    b scanRow             //continue scan
    
endLeft:
    mov x8, #0             //reset counter before returning
    b showboard

win:
	bl printArray
	ldr x4, =playerState
    	ldr x0, playerState
	bl printWin

exit:
    mov x0, #0
    mov x8, #93
    svc 0
