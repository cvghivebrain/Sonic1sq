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
		movem.l	d3-d4,-(sp)
		moveq	#0,d3
		moveq	#0,d4
		move.w	d1,d3					; d3 = x distance
		move.w	d2,d4					; d4 = y distance
		or.w	d3,d4
		beq.s	CalcAngle_Both0				; branch if both are 0
		move.w	d2,d4
		tst.w	d3
		bpl.w	.x_positive				; branch if x is positive
		neg.w	d3					; force x positive

	.x_positive:
		tst.w	d4
		bpl.w	.y_positive				; branch if y is positive
		neg.w	d4					; force y positive

	.y_positive:
		cmp.w	d3,d4
		bcc.w	.y_larger				; branch if y is larger or same
		lsl.l	#8,d4
		divu.w	d3,d4					; d4 = (y*$100)/x
		moveq	#0,d0
		move.b	Angle_Data(pc,d4.w),d0
		bra.s	CalcAngle_ChkRotation
; ===========================================================================

.y_larger:
		lsl.l	#8,d3
		divu.w	d4,d3					; d3 = (x*$100)/y
		moveq	#$40,d0
		sub.b	Angle_Data(pc,d3.w),d0

CalcAngle_ChkRotation:
		tst.w	d1
		bpl.w	.x_positive				; branch if x is positive
		neg.w	d0
		addi.w	#$80,d0

	.x_positive:
		tst.w	d2
		bpl.w	.y_positive				; branch if y is positive
		neg.w	d0
		addi.w	#$100,d0

	.y_positive:
		movem.l	(sp)+,d3-d4
		rts	
; ===========================================================================

CalcAngle_Both0:
		move.w	#$40,d0
		movem.l	(sp)+,d3-d4
		rts
