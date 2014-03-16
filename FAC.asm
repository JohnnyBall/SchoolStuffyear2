StackSegment SEGMENT STACK
        DW 256 DUP (?)          		;writes space for  interruption handling	
StackSegment ENDS
DataSegment SEGMENT
			;Nothing here yet
DataSegment ENDS
;=====================================
CodeSegment SEGMENT
Start:
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Main
Main  Proc ; set as a proc so information is more isolated in the source code
	ASSUME DS:DataSegment, CS: CodeSegment
	
	MOV AX,DataSegment; sets up data segment
	MOV DS,AX;see above line
	
	MOV AX, 0B800h ; Sets up video ram
	MOV ES, AX     ; makes ES address video memory
	
	MOV SI, 0	   ;Sets SI to top ROW
	MOV DI, 160*25 ;Sets DI to BOTTOM ROW
;************************************rowLoop
	MOV CX,12	   ; Sets CX incrementer for 12 (cause they will meet in the middle.)
rowLoop:
	CALL SwapArow
	;CALL NoneAlphaCol
	ADD SI,160
	SUB DI,160
Loop rowLoop
;************************************rowLoop ends
    MOV AH, 4Ch      ;ends the section/closes
    INT 21h          ;see above lines comment
Main ENDP
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<Main ends
;
;>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>SwapArow
SwapArow  Proc
	PUSH AX BX CX SI DI 
;********************************SwapLoop
	MOV CX, 80;
SwapLoop:
	MOV AX, ES:[SI]
	MOV BX, ES:[DI]
;AX////////////////AX COMPARISON
	CMP AL, 'A'
	JL notAlphaAX;If AX < A its not alphabetical
	CMP AL, 'Z' 
	JG lowercaseAX; if greater check if lowercase
	JMP isAlphaAX;else jmp to isAlphaAX to skip
lowercaseAX:
	CMP AL, 'a'
	JL notAlphaAX ;if AX < 'a' it is not alphabetical so we jump to the byte changer for da colors 
	CMP AL, 'z'
	JLE isAlphaAX; if AX <= 'z' then we skip the color thing and jump to the bx comparison
notAlphaAX:
	MOV AH, 01111100b 
isAlphaAX:;End of AX comparison
;BX////////////////BX COMPARISON
	CMP BL, 'A'
	JL notAlphaBX; if BL < 'A' it is not alphabetical
	CMP BL,  'Z'
	JG lowercaseBX; if greater check if lowercase
	JMP isAlphaBX;else jmp to is alpha to set the byte
lowercaseBX:
	CMP BL, 'a'
	JL notAlphaBX; if BL < 'a' then because of the above conditions it is not alphabetical
	CMP BL, 'z'
	JLE isAlphaBX; if BL is <= 'z' then it is alphabetical
notAlphaBX:
	MOV BH, 01111100b 
isAlphaBX:
;BX////////////////ends
	MOV ES:[SI], BX;swaps SI with BX
	MOV ES:[DI], AX;swaps DI with AX
	ADD SI, 2;goes to next column.
	ADD DI, 2
LOOP SwapLoop
;*******************************SwapLoop ends
	POP DI SI CX BX AX
	RET
SwapArow ENDP
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<SwapArow ends
CodeSegment ENDS
;---------------------------------------------------------------------------------------------------
END Start 
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;OLD CODE BELOW THIS																																								;
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<NoneAlphaCol 
;NoneAlphaCol  Proc
;	PUSH AX BX CX SI DI ;Pushes registers information
;********************************colorCheckloop
;	MOV CX, 80;Loop information 
;colorCheckloop:
;========================
;	CMP [SI], BYTE PTR 'A'
;	JL notAlphaSI
;	CMP [SI], BYTE PTR 'Z'
;	JG lowercaseSI; if greater check if lowercase
;	JMP isAlphaSI;else jmp to is alpha to set the byte
;lowercaseSI:
;	CMP [SI], BYTE PTR 'a'
;	JL notAlphaSI
;	CMP [SI], BYTE PTR 'z'
;	JLE isAlphaSI
;notAlphaSI:
;	MOV ES:[SI] + 1, BYTE PTR 01111100b 
;isAlphaSI:
;========================
;	CMP [DI], BYTE PTR 'A'
;	JL notAlphaDI
;	CMP [DI], BYTE PTR 'Z'
;	JG lowercaseDI
;	JMP isAlphaDI
;lowercaseDI:
;	CMP [DI], BYTE PTR 'a'
;	JL notAlphaDI
;	CMP [DI], BYTE PTR 'z'
;	JLE isAlphaDI
;notAlphaDI:
;	MOV ES:[DI] + 1, BYTE PTR 01111100b 
;isAlphaDI:
;	ADD SI, 2 ;ADDS 2 to SI MAKING IT POINT TO THE NEXT WORD/COLMN OF VIDEO MEMORY
;	ADD DI, 2;see above
;LOOP colorCheckloop
;*******************************colorCheckloop ends
;	POP DI SI CX BX AX ; pops registers information 
;	RET
;NoneAlphaCol ENDP
;<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<NoneAlphaCol ends