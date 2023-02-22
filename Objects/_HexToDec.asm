; ---------------------------------------------------------------------------
; Subroutine to convert hex byte into decimal (up to 99)

; input:
;	d0.w = hex byte

; output:
;	(a1) = decimal tens digit
;	1(a1) = decimal low digit

;	uses d0.w
; ---------------------------------------------------------------------------

HexToDec:
		add.b	d0,d0
		lea	HUD_TimeList(pc,d0.w),a1
		rts

		decnum: = 0
HUD_TimeList:	rept 10
		rept 10
		dc.w decnum
		decnum: = decnum+1
		endr
		decnum: = decnum+$100-10
		endr

HexToDec2:
		add.b	d0,d0
		lea	HUD_TimeList2(pc,d0.w),a1
		rts

		decnum: = 0
HUD_TimeList2:	rept 10
		rept 10
		dc.w decnum
		decnum: = decnum+2
		endr
		decnum: = decnum+$200-20
		endr
		
; ---------------------------------------------------------------------------
; Subroutine to count the number of (decimal) digits in a longword

; input:
;	d0.l = longword

; output:
;	d3.l = number of digits (1-6, or 0 if d0 is 0)
; ---------------------------------------------------------------------------

CountDigits:
		tst.l	d0
		bne.s	.more_than_0
		moveq	#0,d3
		rts
	
	.more_than_0:
		cmpi.l	#9,d0
		bhi.s	.more_than_1
		moveq	#1,d3
		rts
	
	.more_than_1:
		cmpi.l	#99,d0
		bhi.s	.more_than_2
		moveq	#2,d3
		rts
	
	.more_than_2:
		cmpi.l	#999,d0
		bhi.s	.more_than_3
		moveq	#3,d3
		rts
	
	.more_than_3:
		cmpi.l	#9999,d0
		bhi.s	.more_than_4
		moveq	#4,d3
		rts
	
	.more_than_4:
		cmpi.l	#99999,d0
		bhi.s	.more_than_5
		moveq	#5,d3
		rts
	
	.more_than_5:
		moveq	#6,d3
		rts
		