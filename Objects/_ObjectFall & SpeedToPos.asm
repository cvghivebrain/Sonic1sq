; ---------------------------------------------------------------------------
; Subroutine to	make an	object fall downwards, increasingly fast
; (Also updates its position)

;	uses d0.l, d2.l
; ---------------------------------------------------------------------------

ObjectFall:
		bsr.s	SpeedToPos
		addi.w	#$38,ost_y_vel(a0)			; increase falling speed
		rts

; ---------------------------------------------------------------------------
; Subroutine translating object	speed to update	object position
; (speed of $100 will move an object 1px per frame)

;	uses d0.l, d2.l
; ---------------------------------------------------------------------------

SpeedToPos:
		move.w	ost_x_vel(a0),d0			; load horizontal speed
		beq.s	.skip_x					; branch if 0
		move.l	ost_x_pos(a0),d2
		ext.l	d0
		asl.l	#8,d0					; multiply speed by $100
		add.l	d0,d2					; add to x position
		move.l	d2,ost_x_pos(a0)			; update x position
		
	.skip_x:
		move.w	ost_y_vel(a0),d0			; load vertical speed
		beq.s	.skip_y					; branch if 0
		move.l	ost_y_pos(a0),d2
		ext.l	d0
		asl.l	#8,d0					; multiply by $100
		add.l	d0,d2					; add to y position
		move.l	d2,ost_y_pos(a0)			; update y position
		
	.skip_y:
		rts
