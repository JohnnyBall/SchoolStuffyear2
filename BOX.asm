StackSegment SEGMENT STACK
        DW 256 DUP (?)         
StackSegment ENDS
;===========================================================================================================================
DataSegment SEGMENT

marStr		DB 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRS     ', 0

upperLftCrn DW	160*6+10	  ;For the Top LEFT CORNER OF BOX (DIFFERENT DEPENDING ON IF DOUBLE OR SINGLE LINED   ;LINE 13 of SCREEN
lnTyp       DB  1			  ;DECIDES IF DOUBLE OR SINGLE LINES

;Color Section & Width Section
foreColor   DB 00000010b      ; GREEEEEN text
backColor   DB 00000000b      ; black BACKGROUND 
boxWidth    DB 40			  ; Width of box

;Boolean check section
rSStatus	DB 0			  ; This helps with determining if RIGHT shift has been released.
lSStatus	DB 0 			  ; This helps with determining if LEFT shift has been released.

DataSegment ENDS
;===========================================================================================================================
CodeSegment SEGMENT
;---------------------------------------------------------------------------------------Main
Main  Proc
	ASSUME DS:DataSegment, CS: CodeSegment
	MOV AX,DataSegment
	MOV DS,AX
	
	MOV AX, 0B800h ; Sets up video ram
	MOV ES, AX     ; makes ES address video memory
	
	CALL DrawBox   ; Draws the box for the first time
	
Keyloop:
	Call CheckForKey
	JMP Keyloop	   ;Used to make sure that the key is continuously checked.

Main ENDP
;---------------------------------------------------------------------------------------Main ENDP
;
;
;---------------------------------------------------------------------------------------EraseBox
EraseBox Proc
	PUSH AX BX CX DX SI
	MOV SI, upperLftCrn			; sets SI to the top corner of the box
	MOV BH, 0         ; sets the high byte of BX to black so that the box can be erased (reset)
	MOV BL, 0		            ; also fills in any ascii values
	
	MOV CX, 5
ebLineLoop:
	MOV SI, upperLftCrn			; Sets SI to the upper left corner of the box
	MOV AL, CL					; Moves CL into AL for multiplication of DL (or 160) for setting up the correct line to write over
	MOV DL, 160					; See above	
	MUL DL						; AX:= AL*DL or LoopIteration* 160
	SUB AX, 160					; This line is necessary for getting put back into the proper position when doing the first iteration (160*1 skips first line)
	ADD SI, AX					; Sets SI to the now corrected position that was stored in AX
	PUSH CX                     ; SAVES OUTER LOOP NUMBER
	MOV CH, 0
	MOV CL, boxWidth			
	ADD CL, 2					;AMMOUNT OF ITTERATIONS HERE IS WIDTH OF BOX + 2 to grab the edges 
ebColLoop:
	MOV ES:[SI], BX				;Writes over values in current box Position.
	ADD SI, 2
LOOP ebColLoop
	POP CX
LOOP ebLineLoop

	POP SI DX CX BX AX
	RET
EraseBox ENDP
;---------------------------------------------------------------------------------------EraseBox ENDP
;
;---------------------------------------------------------------------------------------DrawBox
DrawBox Proc
	PUSH AX BX CX SI DI
	
	MOV SI, upperLftCrn         ;Sets SI to be the upper Left Corner of the BOX
	
	MOV DI, upperLftCrn         ;skips 3 rows for the
	ADD DI, 160*4
	
	MOV AL, lnTyp               ;Moves byte for line type into the register for comparing
	
	MOV BH, backColor	        ;sets the color of bl to the background color for the window
	OR  BH, foreColor	        ;sets the color of bl to the full color with forground and background 
 
	CMP AL, 1                   ;compare AL to 1
	JL  singleLine              ;if less jump single line
	JMP doubleLined				;else jump to double
;;__________________________________________________________________________________________________SINGLE LINE
singleLine:	
	MOV BL, 0DAh                ;Sets BL to top corner ascii 
	MOV ES:[SI], BX             
	MOV BL, 0C0h		        ;Sets BL to bottom corner single line ascii
	MOV ES:[DI], BX
	ADD SI, 2
	ADD DI, 2
	
	MOV CL, boxWidth
    MOV CH, 0	
widthLoopSLn:
	MOV BL, 0C4h         		; sets to single line for drawing the top and bottom edge of the box      
	MOV ES:[SI], BX
    MOV ES:[DI], BX
	ADD SI, 2
    ADD DI, 2	
LOOP widthLoopSLn

	MOV BL, 0BFh		       ;Moves top right corner ascii into BH
	MOV ES:[SI], BX            
	MOV BL, 0D9h		       ;Moves bottom right corner ascii into BH
	MOV ES:[DI], BX

	MOV BL, 0B3h
	MOV SI, upperLftCrn
	ADD SI, 160
	SUB DI, 160
	MOV CX, 3
heightLoopSLn:
	MOV ES:[SI], BX
    MOV ES:[DI], BX	
    ADD SI, 160
    SUB DI,	160
LOOP heightLoopSLn
JMP drawDone
;;__________________________________________________________________________________________________SINGLE LINE	
;;
;;==================================================================================================DOUBLE LINE	
doubleLined:
	MOV BL, 0C9h                ;Sets BL to top corner double line ascii 
	MOV ES:[SI], BX             
	MOV BL, 0C8h		        ;Sets BL to bottom corner double line ascii
	MOV ES:[DI], BX
	ADD SI, 2
	ADD DI, 2
	
	MOV CL, boxWidth
    MOV CH, 0	
widthLoopDLn:
	MOV BL, 0CDh                ; sets to Double line for drawing the top and bottom edge of the box      
	MOV ES:[SI], BX
    MOV ES:[DI], BX
	ADD SI, 2
    ADD DI, 2	
LOOP widthLoopDLn

	MOV BL, 0BBh		       ;Moves top right corner ascii into BH
	MOV ES:[SI], BX            
	MOV BL, 0BCh		       ;Moves bottom right corner ascii into BH
	MOV ES:[DI], BX

	MOV BL, 0BAh
	MOV SI, upperLftCrn
	ADD SI, 160
	SUB DI, 160
	MOV CX, 3
heightLoopDLn:
	MOV ES:[SI], BX
    MOV ES:[DI], BX	
    ADD SI, 160
    SUB DI,	160
LOOP heightLoopSLn
;;==================================================================================================DOUBLE LINE	
;;
;This last section below is to make sure that the center of the box is colored no matter what the line type
drawDone:
	MOV CX,3								; Gap between the box is 3 lines so we must iterate through 3 times.
paintInside:
	MOV SI, upperLftCrn						; sets SI to the top corner of the box
	MOV AL, CL								; Moves CL the current loop iteration (1-3) into AL
	MOV BL, 160								; Moves 160 into BL so that it can be multiplied by the Loop iteration.
	MUL BL									; Multiplies AL by BL
	ADD AX, 2
	ADD SI, AX								; Adds the new number IN AX to SI so that the pointer will now be in the correct position.
	PUSH CX									; CX is pushed so that it can be used to loop to the outside loop.
	MOV CH, 0										
	MOV CL, boxWidth						; CL is set to the box width so that it can iterate through the  lines coloring the console
paintLine:
	MOV BL, BYTE PTR ES:[SI]				; Moves the text from the window into BL so that it is not disturbed and can be replaced later
	MOV ES:[SI], BX							; Moves the now whole BX back into the screens memory space.
	ADD SI, 2
LOOP paintLine
	POP CX									; Pops old cx from the stack for the outside loop.
LOOP paintInside
;;END OF FUNCTION/DRAWDONE
	POP DI SI CX BX AX
	RET
DrawBox ENDP
;---------------------------------------------------------------------------------------DrawBox ENDP
;	
;MOV ES:[160*20+140], WORD PTR 'A' + 0C00h
;---------------------------------------------------------------------------------------CheckForKey
CheckForKey Proc
	PUSH AX BX
	MOV  AH, 12h 	     ; For checking Shift Status
	INT  16h
	TEST AX, 1
	JZ   ResetRight      ; if right shift not down then reset so it can be done again.
	
	MOV  BL, rSStatus	 ; Moves the status of right shift into BL to see if it has been pressed
	CMP  Bl, 0			 ; if shift pressed
	JG	 CheckOtherKeys	 ; Check other keys for input
	MOV  rSStatus, 1	 ; move true into the status of Right shift 
	Call MakeWider		 ; then call make wider to make the box wider
	JMP  done
	
skipRightshift:	
	MOV  AH, 12h 	     ; For checking Shift Status
	INT  16h
	TEST AX, 2
	JZ   ResetLeft       ; if left shift not down either then check other keys.
	
	MOV  BL, lSStatus	 ; if it is down move BL into the Left shift status
	CMP  Bl, 0			 ; compare the shift status to Zero
	JG	 CheckOtherKeys	 ; if the key has been press then we skip it
	MOV  lSStatus, 1	 ; Moves 1 into the left shift status since it has been pressed
	Call MakeNarrower
	JMP  done

ResetRight:
	MOV rSStatus, 0 ; moves
	JMP skipRightshift
ResetLeft:
	MOV lSStatus, 0
	
CheckOtherKeys:
	MOV AH, 11h      ; For checking key status to see if a key is ready
	INT 16h
	JZ  done         ; If no key in buffer then this would be done
	MOV AH, 10h		 ; else check key
	INT 16h
	
	CMP AL, 1Bh      ; Checks for escape key
	JE  terminate     ; if escape key in buffer then jump to terminate label and end prgm.
	CMP AX, 3B00h    ; Checks for F1 key
	JE  processF1     ; if F1 key in buffer then jump to process space
	CMP AL, 'B'      
	JE  processB   	 ; For all of the rest these should be pretty readable.
	CMP AL, 'b'  
	JE  processB  
	CMP AL, 'F'   
	JE  processF   
	CMP AL, 'f' 
	JE  processF 
	
	CMP AH, 4Dh 	; If Scan code is right then we will jump to the right label
	JE  right 
	CMP AH, 4Bh 	; If Scan code is left then we will jump to the left label
	JE  left 
	CMP AH, 48h		; if SC is UP then jmp to UP LABEL
	JE  up 
	CMP AH, 50h 	; if SC is down then jmp to down LABEL
	JE  down 
	
	JMP done        ; if none of these keys then jump to done to reloop

right:
	Call MoveRight
	JMP  done		;Makes sure that the rest of the selection is skiped, and something isn't done that shouldn't be.
left:
	Call MoveLeft
	JMP  done
up:
	Call MoveUp
	JMP  done
down:
	Call MoveDown
	JMP  done	
processB:
	CALL CycleBackColor
	JMP  done
processF:
	CALL CycleForeColor
	JMP  done
processF1:
	Call ToggleScroll
	JMP  done          
terminate:
	CALL EraseBox
    MOV  AH, 4Ch      
    INT  21h          
done:
	POP BX AX 
	RET
CheckForKey ENDP
;---------------------------------------------------------------------------------------CheckForKey ENDP
;
;---------------------------------------------------------------------------------------MakeNarrower
MakeNarrower Proc
	PUSH AX BX SI
	
	MOV AL, boxWidth 		; Movs boxWidth into AL for calculating
	CMP AL, 4				; Compares to AL, if its to small then it ignores the action
	JLE narrowerDone

	CALL EraseBox			; Else the box is erased
	SUB  AL, 2				; 2 is subtracted from the width (to make the box smaller)
	MOV  boxWidth, AL		; the new width is then moved into boxWidth in memory
	CALL DrawBox			; and the box is redrawn

narrowerDone:
	POP SI BX AX 
	RET
MakeNarrower ENDP
;---------------------------------------------------------------------------------------MakeNarrower ENDP
;
;---------------------------------------------------------------------------------------MakeWider
MakeWider Proc
	PUSH AX BX SI
	
	MOV AL, boxWidth
	CMP AL, 40
	JGE widerDone

	CALL EraseBox
	ADD  AL, 2
	MOV  boxWidth, AL
	CALL DrawBox
	
widerDone:	
	POP SI BX AX 
	RET
MakeWider ENDP
;---------------------------------------------------------------------------------------MoveRight ENDP
;		
;---------------------------------------------------------------------------------------MoveRight;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;not working correctly
MoveRight Proc
	PUSH AX BX CX
	MOV	 AX, upperLftCrn			; Moves the memorySpace of upperLftCrn into AX so that we can calculate if the box is off the page.					
	MOV BX, AX					; MOVS the now stored memory value of upperLftCrn in AX to BX for calculating the bottom right corner of the box.
	ADD BX, 160*5						
	MOV CH, 0					; Clears CH
	MOV CL, boxWidth			; MOVES the box width into CL for calculating the edge
	PUSH AX
	MOV AX, 0
	MOV AL, 2					; moves 2 into AL for multiplying cl
	MUL CL						; MULTIPLYS the width by 2
	MOV CX, AX					; MOVES the new value in AX into CX
	POP AX						; Restores AX
	ADD CX, 2					; Simulates the final edge
	ADD BX, CX			        ; Adds the width of the box(CX) to BX so that it will be able to simulate the bottom right corner of the box.
	CMP BX, 26*160-2		    ; Compares BX to 25*160
	JGE rightDone				; if the box is already on the bottom corner then it will skip
	
	ADD  AX, 2					; ADDS 2 to Simulate the box moving 2 to the right.
	CALL EraseBox
	MOV  upperLftCrn, AX
	CALL DrawBox
rightDone:
	POP  CX BX AX 
	RET
MoveRight ENDP
;---------------------------------------------------------------------------------------MoveRight ENDP
;
;---------------------------------------------------------------------------------------MoveLeft
MoveLeft Proc
	PUSH AX
	MOV	 AX, upperLftCrn			; Moves the memorySpace of upperLftCrn into AX so that we can calculate if the box is off the page.
	CMP  AX, 0					
	JE   leftDone				; if zero then almost off page so instructions below.
	SUB  AX, 2					; Subtracts 2 to from the AX to move into upperLftCrn data space so that it can be used to move the box around.
	CALL EraseBox
	MOV  upperLftCrn, AX
	CALL DrawBox
	
leftDone:
	POP AX
	RET
MoveLeft ENDP
;---------------------------------------------------------------------------------------MoveLeft ENDP
;
;---------------------------------------------------------------------------------------MoveUp
MoveUp Proc
	PUSH AX BX 
	MOV  AX, upperLftCrn		; Moves the cordinate of the upper left corner into AX
	CMP  AX, 160				; 
	JLE  upDone					; if AX is or the upper left corner is less then 160 then we will no longer move the box UP
								; Else we do below
	Call EraseBox				; Erases the box so that it can be repainted 
	SUB  AX, 160 				; SUBTRACTS 160 from AX(upperLftCrn) so that it will now be drawn up a space
	MOV  upperLftCrn, AX
	Call DrawBox				; Redraws the box with the updated cordinates 
upDone:
	POP  BX AX
	RET
MoveUp ENDP
;---------------------------------------------------------------------------------------MoveUp ENDP
;
;---------------------------------------------------------------------------------------MoveDown;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;not working correctly
MoveDown Proc
	PUSH AX BX CX

	MOV AX, upperLftCrn					
	MOV BX, AX							; MOVS the now stored memory value of upperLftCrn in AX to BX for calculating the bottom right corner of the box.
	ADD BX, 160*5						
	MOV CH, 0							; Clears CH
	MOV CL, boxWidth					; MOVES the box width into CL for calculating the edge
	PUSH AX
	MOV AX, 0
	MOV AL, 2							; moves 2 into AL for multiplying cl
	MUL CL								; MULTIPLYS the width by 2
	MOV CX, AX							; MOVES the new value in AX into CX
	POP AX								; Restores AX
	ADD CX, 2							; Simulates the final edge
	ADD BX, CX					        ; Adds the width of the box(CX) to BX so that it will be able to simulate the bottom right corner of the box.
	CMP BX, 25*160					    ; Compares BX to 25*160
	JGE downDone						; if the box is already on the bottom corner then it will skip
	
	ADD  AX, 160						; Adds 160 to AX to move the window down a line.
	Call EraseBox
	MOV  upperLftCrn, AX
	Call DrawBox
downDone:
	POP CX BX AX
	RET
MoveDown ENDP
;---------------------------------------------------------------------------------------MoveDown ENDP
;
;---------------------------------------------------------------------------------------ToggleScroll
ToggleScroll Proc
	PUSH AX
	POP AX
	RET
ToggleScroll ENDP
;---------------------------------------------------------------------------------------ToggleScroll ENDP
;
;---------------------------------------------------------------------------------------ScrollSpeed
ScrollSpeed Proc
	PUSH AX
	POP AX
	RET
ScrollSpeed ENDP
;---------------------------------------------------------------------------------------ScrollSpeed ENDP
;
;---------------------------------------------------------------------------------------CycleBackColor
CycleBackColor Proc
	PUSH AX
	MOV AL, backColor
	ADD AL, 16
	CMP AL, 112         ; compare AL to 113
	JLE bgDone		    ; IF less we are done and we set the new color to the memory space backColor	;NEVER FAILS????
	MOV AL, 0			; Else if it is greater than 113 we reset the color to 0
bgDone:
	MOV backColor, AL
	CALL DrawBox        ; Redraws box with updated colors.
	POP AX
	RET
CycleBackColor ENDP
;---------------------------------------------------------------------------------------CycleBackColor ENDP
;
;---------------------------------------------------------------------------------------CycleForeColor
CycleForeColor Proc
	PUSH AX
	MOV AL, foreColor
	INC AL
	CMP AL, 8           ; compare AL to 8
	JL fgDone		    ; IF less we are done and we set the new color to the memory space foreColor
	MOV AL, 0			; Else if it is greater than 8 we reset the color to 0
fgDone:
	MOV  foreColor, AL
	CALL DrawBox        ; Redraws box with updated colors.
	POP AX
	RET
CycleForeColor ENDP
;---------------------------------------------------------------------------------------CycleForeColor ENDP
;
CodeSegment ENDS
;===========================================================================================================================
END main 
