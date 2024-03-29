; ---------------------------------------------------------------------------
; Subroutine to generate a pseudo-random number

; output:
;	d0.l = pseudo-random number
;	d1.l = d0 with high/low words swapped
; ---------------------------------------------------------------------------

RandomNumber:
		move.l	(v_random).w,d1
		beq.s	.init					; branch if v_random is 0

	.scramble:
		move.l	d1,d0
		asl.l	#2,d1
		add.l	d0,d1
		asl.l	#3,d1
		add.l	d0,d1
		move.w	d1,d0
		swap	d1
		add.w	d1,d0
		move.w	d0,d1
		swap	d1
		move.l	d1,(v_random).w
		rts
		
	.init:
		move.l	#$2A6D365A,d1				; if d1 is 0, use seed number
		bra.s	.scramble
