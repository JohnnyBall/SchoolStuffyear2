StackSegment SEGMENT STACK
        DW 256 DUP (?)         
StackSegment ENDS
;===========================================================================================================================
DataSegment SEGMENT

upperLftCrn DW	160*6+10		  ;For the Top LEFT CORNER OF BOX (DIFFERENT DEPENDING ON IF DOUBLE OR SINGLE LINED   ;LINE 13 of SCREEN
lnTyp       DB  1			  ;DECIDES IF DOUBLE OR SINGLE LINES

;Color Section & Width Section
foreColor   DB 00000010b      ;  GREEEEEN text
backColor   DB 00000000b      ; RED BACKGROUND 
boxWidth    DB 60			  ; Width of box
;;
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
	MOV BL, 32		            ; also fills in any ascii values
	
	MOV CX, 5
ebLineLoop:
	MOV SI, upperLftCrn			; Sets SI to the upper left corner of the box
	MOV AL, CL					; Moves CL into AL for multiplication of DL (or 160) for setting up the correct line to write over
	MOV DL, 160					; See above	
	MUL DL						; AX:= AL*DL or LoopIteration* 160
	SUB AX, 160					; This line is necessary for getting put back into the proper position when doing the first iteration (160*1 skips first line)
	ADD SI, AX					; Sets SI to the now corrected position that was stored in AX
	PUSH CX                     ;SAVES OUTER LOOP NUMBER
	MOV CH, 0
	MOV CL, boxWidth			
	ADD CL, 2					;AMMOUNT OF ITTERATIONS HERE IS WIDTH OF BOX + 2 to grab the edges 
ebColLoop:
	MOV ES:[SI], BX				;Writes over values in current box Position.
	ADD SI, 2
LOOP ebColLoop
	POP CX
LOOP ebLineLoop
;;DURN

	POP SI DX CX BX AX
	RET
EraseBox ENDP
;---------------------------------------------------------------------------------------EraseBox ENDP
;
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
;;
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
	;MOV BH,00100100b;inverse  of original for debug
	MOV CX,3								;Gap between the box is 3 lines so we must iterate through 3 times.
paintInside:
	MOV SI, upperLftCrn						; sets SI to the top corner of the box
	MOV AL, CL								; Moves CL the current loop iteration (1-3) into AL
	MOV BL, 160								; Moves 160 into BL so that it can be multiplied by the Loop iteration.
	MUL BL									; Multiplies AL by BL
	ADD AX, 2
	ADD SI, AX								; Adds the new number IN AX to SI so that the pointer will now be in the correct position.
	PUSH CX									;CX is pushed so that it can be used to loop to the outside loop.
	MOV CH, 0										
	MOV CL, boxWidth						;CL is set to the box width so that it can iterate through the  lines coloring the console
paintLine:
	MOV BL, BYTE PTR ES:[SI]				;Moves the text from the window into BL so that it is not disturbed and can be replaced later
	MOV ES:[SI], BX							;Moves the now whole BX back into the screens memory space.
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
;
;---------------------------------------------------------------------------------------CheckForKey
CheckForKey Proc
	PUSH AX
	
	MOV AH, 11h      ;For checking key status to see if a key is ready
	INT 16h
	JZ done          ; If no key in buffer then this would be done
	MOV AH,10h		 ;else check key
	INT 16h
	
	CMP AL, 1Bh      ; Checks for escape key
	JE terminate     ; if escape key in buffer then jump to terminate label and end prgm.
	CMP AX, 3B00h    ; Checks for F1 key
	JE processF1     ; if F1 key in buffer then jump to process space
	CMP AL, 'B'      
	JE processB   	 ;For all of the rest these should be pretty readable.
	CMP AL, 'b'  
	JE processB  
	CMP AL, 'F'   
	JE processF   
	CMP AL, 'f' 
	JE processF 
	
	CMP AH, 4Dh 	; If Scan code is right then we will jump to the right label
	JE right 
	CMP AH, 4Bh 	; If Scan code is left then we will jump to the left label
	JE left 
	CMP AH, 48h		; if SC is UP then jmp to UP LABEL
	JE up 
	CMP AH, 50h 	; if SC is down then jmp to down LABEL
	JE down 
	
	JMP done        ;if none of these keys then jump to done to reloop



right:
	Call MoveRight
	JMP done
left:
	Call MoveLeft
	JMP done
up:
	Call MoveUp
	JMP done
down:
	Call MoveDown
	JMP done	
processB:
	CALL CycleBackColor
	JMP done
processF:
	CALL CycleForeColor
	JMP done
processF1:
	Call ToggleScroll
	JMP done          ;Makes sure that the rest of the selection is skiped, and something isnt done that shouldnt be.
terminate:
	CALL EraseBox
    MOV AH, 4Ch      
    INT 21h          
done:
	POP AX
	RET
CheckForKey ENDP

;---------------------------------------------------------------------------------------CheckForKey ENDP
;
;
;---------------------------------------------------------------------------------------MoveRight
MoveRight Proc
	PUSH AX
	POP AX
	RET
MoveRight ENDP
;---------------------------------------------------------------------------------------MoveRight ENDP
;
;
;---------------------------------------------------------------------------------------MoveLeft
MoveLeft Proc
	PUSH AX
	POP AX
	RET
MoveLeft ENDP
;---------------------------------------------------------------------------------------MoveLeft ENDP
;
;
;---------------------------------------------------------------------------------------MoveUp
MoveUp Proc
	PUSH AX
	POP AX
	RET
MoveUp ENDP
;---------------------------------------------------------------------------------------MoveUp ENDP
;
;
;---------------------------------------------------------------------------------------MoveDown
MoveDown Proc
	PUSH AX
	POP AX
	RET
MoveDown ENDP
;---------------------------------------------------------------------------------------MoveDown ENDP
;
;
;---------------------------------------------------------------------------------------ToggleScroll
ToggleScroll Proc
	PUSH AX
	POP AX
	RET
ToggleScroll ENDP
;---------------------------------------------------------------------------------------ToggleScroll ENDP
;
;
;---------------------------------------------------------------------------------------ScrollSpeed
ScrollSpeed Proc
	PUSH AX
	POP AX
	RET
ScrollSpeed ENDP
;---------------------------------------------------------------------------------------ScrollSpeed ENDP
;
;
;---------------------------------------------------------------------------------------CycleBackColor
CycleBackColor Proc
	PUSH AX
	MOV AL, backColor
	ADD AL, 16
	CMP AL, 112         ; compare AL to 113
	JLE bgDone		    ; IF less we are done and we set the new color to the memory space backColor	;NEVER FAILS????
	MOV AL, 0			; Else if it is greater than 113 we reset the color to 0
	MOV ES:[160*20+140], WORD PTR 'A'+0C00h
bgDone:
	MOV backColor, AL
	CALL DrawBox      ;Redraws box with updated colors.
	POP AX
	RET
CycleBackColor ENDP
;---------------------------------------------------------------------------------------CycleBackColor ENDP
;
;
;---------------------------------------------------------------------------------------CycleForeColor
CycleForeColor Proc
	PUSH AX
	MOV AL, foreColor
	INC AL
	CMP AL, 8         ; compare AL to 113
	JL fgDone		    ; IF less we are done and we set the new color to the memory space backColor
	MOV AL, 0			; Else if it is greater than 113 we reset the color to 0
fgDone:
	MOV foreColor, AL
	CALL DrawBox      ;Redraws box with updated colors.
	POP AX
	RET
CycleForeColor ENDP
;---------------------------------------------------------------------------------------CycleForeColor ENDP
;
;
CodeSegment ENDS
;===========================================================================================================================
END main 
