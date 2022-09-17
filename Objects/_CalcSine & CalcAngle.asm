; ---------------------------------------------------------------------------
; Subroutine to convert an angle (0 to $FF) to sine and cosine (-$100 to $100)

; input:
;	d0 = angle

; output:
;	d0 = sine
;	d1 = cosine
; ---------------------------------------------------------------------------

CalcSine:
		andi.w	#$FF,d0					; read low byte of angle only
		add.w	d0,d0
		move.w	Sine_Data(pc,d0.w),d1			; get sine
		addi.w	#$80,d0					; start 90 degrees later for cosine
		move.w	Sine_Data(pc,d0.w),d0			; get cosine
		exg	d0,d1					; d0 = sine; d1 = cosine
		rts

Sine_Data:	dc.w      0,      6,     $C,    $12,    $19,    $1F,    $25,    $2B,    $31,    $38,    $3E,    $44,    $4A,    $50,    $56,    $5C
		dc.w    $61,    $67,    $6D,    $73,    $78,    $7E,    $83,    $88,    $8E,    $93,    $98,    $9D,    $A2,    $A7,    $AB,    $B0
		dc.w    $B5,    $B9,    $BD,    $C1,    $C5,    $C9,    $CD,    $D1,    $D4,    $D8,    $DB,    $DE,    $E1,    $E4,    $E7,    $EA
		dc.w    $EC,    $EE,    $F1,    $F3,    $F4,    $F6,    $F8,    $F9,    $FB,    $FC,    $FD,    $FE,    $FE,    $FF,    $FF,    $FF
		dc.w   $100,    $FF,    $FF,    $FF,    $FE,    $FE,    $FD,    $FC,    $FB,    $F9,    $F8,    $F6,    $F4,    $F3,    $F1,    $EE
		dc.w    $EC,    $EA,    $E7,    $E4,    $E1,    $DE,    $DB,    $D8,    $D4,    $D1,    $CD,    $C9,    $C5,    $C1,    $BD,    $B9
		dc.w    $B5,    $B0,    $AB,    $A7,    $A2,    $9D,    $98,    $93,    $8E,    $88,    $83,    $7E,    $78,    $73,    $6D,    $67
		dc.w    $61,    $5C,    $56,    $50,    $4A,    $44,    $3E,    $38,    $31,    $2B,    $25,    $1F,    $19,    $12,     $C,      6
		dc.w      0,     -6,    -$C,   -$12,   -$19,   -$1F,   -$25,   -$2B,   -$31,   -$38,   -$3E,   -$44,   -$4A,   -$50,   -$56,   -$5C
		dc.w   -$61,   -$67,   -$6D,   -$75,   -$78,   -$7E,   -$83,   -$88,   -$8E,   -$93,   -$98,   -$9D,   -$A2,   -$A7,   -$AB,   -$B0
		dc.w   -$B5,   -$B9,   -$BD,   -$C1,   -$C5,   -$C9,   -$CD,   -$D1,   -$D4,   -$D8,   -$DB,   -$DE,   -$E1,   -$E4,   -$E7,   -$EA
		dc.w   -$EC,   -$EE,   -$F1,   -$F3,   -$F4,   -$F6,   -$F8,   -$F9,   -$FB,   -$FC,   -$FD,   -$FE,   -$FE,   -$FF,   -$FF,   -$FF
		dc.w  -$100,   -$FF,   -$FF,   -$FF,   -$FE,   -$FE,   -$FD,   -$FC,   -$FB,   -$F9,   -$F8,   -$F6,   -$F4,   -$F3,   -$F1,   -$EE
		dc.w   -$EC,   -$EA,   -$E7,   -$E4,   -$E1,   -$DE,   -$DB,   -$D8,   -$D4,   -$D1,   -$CD,   -$C9,   -$C5,   -$C1,   -$BD,   -$B9
		dc.w   -$B5,   -$B0,   -$AB,   -$A7,   -$A2,   -$9D,   -$98,   -$93,   -$8E,   -$88,   -$83,   -$7E,   -$78,   -$75,   -$6D,   -$67
		dc.w   -$61,   -$5C,   -$56,   -$50,   -$4A,   -$44,   -$3E,   -$38,   -$31,   -$2B,   -$25,   -$1F,   -$19,   -$12,    -$C,     -6
		dc.w      0,      6,     $C,    $12,    $19,    $1F,    $25,    $2B,    $31,    $38,    $3E,    $44,    $4A,    $50,    $56,    $5C
		dc.w    $61,    $67,    $6D,    $73,    $78,    $7E,    $83,    $88,    $8E,    $93,    $98,    $9D,    $A2,    $A7,    $AB,    $B0
		dc.w    $B5,    $B9,    $BD,    $C1,    $C5,    $C9,    $CD,    $D1,    $D4,    $D8,    $DB,    $DE,    $E1,    $E4,    $E7,    $EA
		dc.w    $EC,    $EE,    $F1,    $F3,    $F4,    $F6,    $F8,    $F9,    $FB,    $FC,    $FD,    $FE,    $FE,    $FF,    $FF,    $FF

; ---------------------------------------------------------------------------
; Subroutine to calculate the square root of a number (0 to $FFFF)

; input:
;	d0 = number

; output:
;	d0 = square root of number
; ---------------------------------------------------------------------------

CalcSqrt:
		movem.l	d1-d2,-(sp)				; preserve d1 and d2 in stack
		move.w	d0,d1
		swap	d1					; copy input to high word of d1
		moveq	#0,d0
		move.w	d0,d1					; clear low word of d1
		moveq	#8-1,d2					; number of loops

	.loop:
		rol.l	#2,d1
		add.w	d0,d0
		addq.w	#1,d0
		sub.w	d0,d1
		bcc.s	.loc_2C9A
		add.w	d0,d1
		subq.w	#1,d0
		dbf	d2,.loop
		lsr.w	#1,d0
		movem.l	(sp)+,d1-d2				; retrieve d1 and d2 from stack
		rts	
; ===========================================================================

	.loc_2C9A:
		addq.w	#1,d0
		dbf	d2,.loop
		lsr.w	#1,d0
		movem.l	(sp)+,d1-d2
		rts

; ---------------------------------------------------------------------------
; Subroutine to convert x/y distance to an angle

; input:
;	d1 = x-axis distance
;	d2 = y-axis distance

; output:
;	d0 = angle
; ---------------------------------------------------------------------------

CalcAngle:
		moveq   #0,d0                           ; Default to bottom right quadrant
		tst.w   d1                              ; Is the X value negative?
		beq.s   CalcAngle_XZero                 ; If the X value is zero, branch
		bpl.s   CalcAngle_CheckY                ; If not, branch
		not.w   d1                              ; If so, get the absolute value
		moveq   #4,d0                           ; Shift to left quadrant
 
CalcAngle_CheckY:
		tst.w   d2                              ; Is the Y value negative?
		beq.s   CalcAngle_YZero                 ; If the Y value is zero, branch
		bpl.s   CalcAngle_CheckOctet            ; If not, branch
		not.w   d2                              ; If so, get the absolute value
		addq.b  #2,d0                           ; Shift to top quadrant
 
CalcAngle_CheckOctet:
		cmp.w   d2,d1                           ; Are we horizontally closer to the center?
		bcc.s   CalcAngle_Divide                ; If not, branch
		exg.l   d1,d2                           ; If so, divide Y from X instead
		addq.b  #1,d0                           ; Use octant that's horizontally closer to the center
 
CalcAngle_Divide:
		move.w  d1,-(sp)                        ; Shrink X and Y down into bytes
		moveq   #0,d3
		move.b  (sp)+,d3
		move.b  WordShiftTable(pc,d3.w),d3
		lsr.w   d3,d1
		lsr.w   d3,d2
	 
		lea     Log2Table(pc),a2                ; Perform logarithmic division
		move.b  (a2,d2.w),d2
		sub.b   (a2,d1.w),d2
		bne.s   CalcAngle_GetAtan2Val
		move.w  #$FF,d2                         ; Edge case where X and Y values are too close for the division to handle
 
CalcAngle_GetAtan2Val:
		lea     Atan2Table(pc),a2               ; Get atan2 value
		move.b  (a2,d2.w),d2
		move.b  OctantAdjust(pc,d0.w),d0
		eor.b   d2,d0
		rts
 
; -------------------------------------------------------------------------
 
CalcAngle_YZero:
		cmpi.b  #4,d0                           ; Was the X value negated?
		beq.s   CalcAngle_YZeroXNeg             ; If so, branch
		moveq   #0,d0                           ; 0 degrees
		rts
 
CalcAngle_YZeroXNeg:
		moveq   #$FFFFFF80,d0                   ; 180 degrees
		rts
 
CalcAngle_XZero:
		tst.w   d2                              ; Is the Y value negative?
		bmi.s   CalcAngle_XZeroYNeg             ; If so, branch
		moveq   #$40,d0                         ; 90 degrees
		rts
 
CalcAngle_XZeroYNeg:
		moveq   #$FFFFFFC0,d0                   ; 270 degrees
		rts
 
; -------------------------------------------------------------------------
 
OctantAdjust:
		dc.b    %00000000                       ; +X, +Y, |X|>|Y|
		dc.b    %00111111                       ; +X, +Y, |X|<|Y|
		dc.b    %11111111                       ; +X, -Y, |X|>|Y|
		dc.b    %11000000                       ; +X, -Y, |X|<|Y|
		dc.b    %01111111                       ; -X, +Y, |X|>|Y|
		dc.b    %01000000                       ; -X, +Y, |X|<|Y|
		dc.b    %10000000                       ; -X, -Y, |X|>|Y|
		dc.b    %10111111                       ; -X, -Y, |X|<|Y|
 
WordShiftTable:
		dc.b    $00, $01, $02, $02, $03, $03, $03, $03
		dc.b    $04, $04, $04, $04, $04, $04, $04, $04
		dc.b    $05, $05, $05, $05, $05, $05, $05, $05
		dc.b    $05, $05, $05, $05, $05, $05, $05, $05
		dc.b    $06, $06, $06, $06, $06, $06, $06, $06
		dc.b    $06, $06, $06, $06, $06, $06, $06, $06
		dc.b    $06, $06, $06, $06, $06, $06, $06, $06
		dc.b    $06, $06, $06, $06, $06, $06, $06, $06
		dc.b    $07, $07, $07, $07, $07, $07, $07, $07
		dc.b    $07, $07, $07, $07, $07, $07, $07, $07
		dc.b    $07, $07, $07, $07, $07, $07, $07, $07
		dc.b    $07, $07, $07, $07, $07, $07, $07, $07
		dc.b    $07, $07, $07, $07, $07, $07, $07, $07
		dc.b    $07, $07, $07, $07, $07, $07, $07, $07
		dc.b    $07, $07, $07, $07, $07, $07, $07, $07
		dc.b    $07, $07, $07, $07, $07, $07, $07, $07
 
Log2Table:
		dc.b    $00, $00, $1F, $32, $3F, $49, $52, $59
		dc.b    $5F, $64, $69, $6E, $72, $75, $79, $7C
		dc.b    $7F, $82, $84, $87, $89, $8C, $8E, $90
		dc.b    $92, $94, $95, $97, $99, $9A, $9C, $9E
		dc.b    $9F, $A0, $A2, $A3, $A4, $A6, $A7, $A8
		dc.b    $A9, $AA, $AC, $AD, $AE, $AF, $B0, $B1
		dc.b    $B2, $B3, $B4, $B5, $B5, $B6, $B7, $B8
		dc.b    $B9, $BA, $BA, $BB, $BC, $BD, $BE, $BE
		dc.b    $BF, $C0, $C0, $C1, $C2, $C2, $C3, $C4
		dc.b    $C4, $C5, $C6, $C6, $C7, $C8, $C8, $C9
		dc.b    $C9, $CA, $CA, $CB, $CC, $CC, $CD, $CD
		dc.b    $CE, $CE, $CF, $CF, $D0, $D0, $D1, $D1
		dc.b    $D2, $D2, $D3, $D3, $D4, $D4, $D5, $D5
		dc.b    $D5, $D6, $D6, $D7, $D7, $D8, $D8, $D8
		dc.b    $D9, $D9, $DA, $DA, $DA, $DB, $DB, $DC
		dc.b    $DC, $DC, $DD, $DD, $DE, $DE, $DE, $DF
		dc.b    $DF, $DF, $E0, $E0, $E0, $E1, $E1, $E1
		dc.b    $E2, $E2, $E2, $E3, $E3, $E3, $E4, $E4
		dc.b    $E4, $E5, $E5, $E5, $E6, $E6, $E6, $E7
		dc.b    $E7, $E7, $E8, $E8, $E8, $E8, $E9, $E9
		dc.b    $E9, $EA, $EA, $EA, $EA, $EB, $EB, $EB
		dc.b    $EC, $EC, $EC, $EC, $ED, $ED, $ED, $ED
		dc.b    $EE, $EE, $EE, $EE, $EF, $EF, $EF, $F0
		dc.b    $F0, $F0, $F0, $F1, $F1, $F1, $F1, $F1
		dc.b    $F2, $F2, $F2, $F2, $F3, $F3, $F3, $F3
		dc.b    $F4, $F4, $F4, $F4, $F5, $F5, $F5, $F5
		dc.b    $F5, $F6, $F6, $F6, $F6, $F7, $F7, $F7
		dc.b    $F7, $F7, $F8, $F8, $F8, $F8, $F8, $F9
		dc.b    $F9, $F9, $F9, $F9, $FA, $FA, $FA, $FA
		dc.b    $FA, $FB, $FB, $FB, $FB, $FB, $FC, $FC
		dc.b    $FC, $FC, $FC, $FD, $FD, $FD, $FD, $FD
		dc.b    $FE, $FE, $FE, $FE, $FE, $FE, $FF, $FF
 
Atan2Table:
		dc.b    $00, $00, $00, $00, $00, $00, $00, $00
		dc.b    $00, $00, $00, $00, $00, $00, $00, $00
		dc.b    $00, $00, $00, $00, $00, $00, $00, $00
		dc.b    $00, $00, $00, $00, $00, $00, $00, $00
		dc.b    $00, $00, $00, $00, $00, $00, $00, $00
		dc.b    $00, $00, $00, $00, $00, $00, $00, $00
		dc.b    $00, $00, $00, $00, $00, $00, $01, $01
		dc.b    $01, $01, $01, $01, $01, $01, $01, $01
		dc.b    $01, $01, $01, $01, $01, $01, $01, $01
		dc.b    $01, $01, $01, $01, $01, $01, $01, $01
		dc.b    $01, $01, $01, $01, $01, $01, $01, $01
		dc.b    $01, $01, $01, $01, $01, $01, $01, $01
		dc.b    $01, $01, $01, $01, $01, $01, $01, $01
		dc.b    $01, $02, $02, $02, $02, $02, $02, $02
		dc.b    $02, $02, $02, $02, $02, $02, $02, $02
		dc.b    $02, $02, $02, $02, $02, $02, $02, $02
		dc.b    $03, $03, $03, $03, $03, $03, $03, $03
		dc.b    $03, $03, $03, $03, $03, $03, $03, $03
		dc.b    $04, $04, $04, $04, $04, $04, $04, $04
		dc.b    $04, $04, $04, $05, $05, $05, $05, $05
		dc.b    $05, $05, $05, $05, $05, $06, $06, $06
		dc.b    $06, $06, $06, $06, $06, $07, $07, $07
		dc.b    $07, $07, $07, $08, $08, $08, $08, $08
		dc.b    $08, $09, $09, $09, $09, $09, $09, $0A
		dc.b    $0A, $0A, $0A, $0B, $0B, $0B, $0B, $0B
		dc.b    $0C, $0C, $0C, $0C, $0D, $0D, $0D, $0D
		dc.b    $0E, $0E, $0E, $0F, $0F, $0F, $0F, $10
		dc.b    $10, $10, $11, $11, $11, $12, $12, $12
		dc.b    $13, $13, $13, $14, $14, $14, $15, $15
		dc.b    $16, $16, $16, $17, $17, $17, $18, $18
		dc.b    $19, $19, $1A, $1A, $1A, $1B, $1B, $1C
		dc.b    $1C, $1C, $1D, $1D, $1E, $1E, $1F, $1F
