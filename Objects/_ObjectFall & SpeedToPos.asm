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

;	uses d0.l, d2.l
; ---------------------------------------------------------------------------

SpeedToPos:
		move.l	ost_x_pos(a0),d2
		move.w	ost_x_vel(a0),d0			; load horizontal speed
		ext.l	d0
		asl.l	#8,d0					; multiply speed by $100
		add.l	d0,d2					; add to x position
		move.l	d2,ost_x_pos(a0)			; update x position
		
		move.l	ost_y_pos(a0),d2
		move.w	ost_y_vel(a0),d0			; load vertical speed
		ext.l	d0
		asl.l	#8,d0					; multiply by $100
		add.l	d0,d2					; add to y position
		move.l	d2,ost_y_pos(a0)			; update y position
		rts
