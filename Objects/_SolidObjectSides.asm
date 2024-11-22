; ---------------------------------------------------------------------------
; Subroutine to make an object solid, sides only

; output:
;	d1.l = collision type (0 = none; 4 = left; 8 = right)
;	a1 = address of OST of Sonic

;	uses d0.l, d2.w
; ---------------------------------------------------------------------------

SolidObjectSides:
		tst.b	ost_render(a0)
		bpl.w	Sides_None				; branch if object isn't on screen
		tst.w	(v_debug_active_hi).w
		bne.w	Sides_None				; branch if debug mode is in use
		
SolidObjectSides_SkipChk:
		getsonic					; a1 = OST of Sonic
		move.w	ost_y_pos(a1),d2
		sbabs.w	ost_y_pos(a0),d2			; d2 = y dist (abs)
		moveq	#0,d0
		move.b	ost_height(a0),d0
		sub.w	d0,d2
		move.b	ost_height(a1),d0
		sub.w	d0,d2					; d2 = y dist with heights
		bpl.s	Sides_None				; branch if outside y range
		
		moveq	#1,d1
		add.b	(v_player1_width).w,d1			; use fixed player width value +1
		move.b	ost_width(a0),d0
		add.w	d0,d1					; d1 = combined Sonic/object widths
		range_x_quick					; d0 = x dist (-ve if Sonic is to the left)
		bpl.s	Sides_Right				; branch if Sonic is to the right
		
Sides_Left:
		add.w	d1,d0					; d0 = x dist with widths (-ve)
		addq.w	#1,d0					; 1px correction
		bmi.s	Sides_None				; branch if outside x range
		
Sides_Left_SkipChk:
		tst.w	ost_x_vel(a1)
		bmi.s	Sides_Cancel				; branch if Sonic is moving away
		moveq	#solid_left,d1				; set collision flag to left
		bra.s	Sides_Collide
		
Sides_Right:
		sub.w	d1,d0					; d0 = x dist with widths
		cmpi.w	#0,d0
		bgt.s	Sides_None				; branch if outside x range
		
Sides_Right_SkipChk:
		cmpi.w	#0,ost_x_vel(a1)
		bgt.s	Sides_Cancel				; branch if Sonic is moving away
		moveq	#solid_right,d1				; set collision flag to right
		
Sides_Collide:
		sub.w	d0,ost_x_pos(a1)			; snap to hitbox
		clr.w	ost_inertia(a1)
		clr.w	ost_x_vel(a1)				; stop Sonic moving
		btst	#status_air_bit,ost_status(a1)
		bne.s	.in_air					; branch if Sonic is in the air
		bset	#status_pushing_bit,ost_status(a1)	; make Sonic push object
		bset	#status_pushing_bit,ost_status(a0)	; make object be pushed
		
	.in_air:
		rts
		
Sides_Cancel:
		bclr	#status_pushing_bit,ost_status(a1)
		bclr	#status_pushing_bit,ost_status(a0)	; cancel pushing
		
Sides_None:
		moveq	#solid_none,d1				; set collision flag to none
		rts
