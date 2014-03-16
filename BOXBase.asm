StackSegment SEGMENT STACK
        DW 256 DUP (?)         
StackSegment ENDS
;===========================================================================================================================
DataSegment SEGMENT

upperLftCrn DW	160*13		  ;For the Top LEFT CORNER OF BOX (DIFFERENT DEPENDING ON IF DOUBLE OR SINGLE LINED   ;LINE 13 of SCREEN
lnTyp       DB  1			  ;DECIDES IF DOUBLE OR SINGLE LINES

;Color Section & Width Section
forColor    DB 00000010b      ; INTENSE GREEEEEN (for ascii) 05h
backColor   DB 00000000b      ; BLACK BACKGROUND 07h
boxWidth    DB 75			  ; Width of box
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

	CALL DrawBox
	
    MOV AH, 4Ch      ;Moves 
    INT 21h          ;see above lines comment
Main ENDP
;---------------------------------------------------------------------------------------Main ENDP
;
;---------------------------------------------------------------------------------------DrawBox
DrawBox Proc
	PUSH AX BX CX SI DI
	
	MOV SI, upperLftCrn         ;Sets SI to be the upper Left Corner of the BOX
	
	MOV DI, upperLftCrn         ;skips 3 rows for the
	ADD DI, 160*4
	
	MOV AL, lnTyp               ;Moves byte for line type into the register for comparing
	
	MOV BH, backColor	        ;sets the color of bl to the background color for the window
	OR  BH, forColor	        ;sets the color of bl to the full color with forground and background 
 
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
JMP drawDONE
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
drawDONE:
	POP DI SI CX BX AX
	RET
DrawBox ENDP
;---------------------------------------------------------------------------------------DrawBox ENDP
;

CodeSegment ENDS
;===========================================================================================================================
END main 
