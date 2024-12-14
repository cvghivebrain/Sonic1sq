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
		sub.w	ost_height_hi(a0),d2
		sub.w	ost_height_hi(a1),d2			; d2 = y dist with heights
		bpl.w	Sides_None				; branch if outside y range
		
		range_x_quick					; d0 = x dist (-ve if Sonic is to the left)
		bpl.s	Sides_Right				; branch if Sonic is to the right
		
Sides_Left:
		add.w	ost_width_hi(a0),d0
		add.w	(v_player1_width).w,d0			; d0 = x dist with widths (-ve)
		addq.w	#2,d0					; 2px correction left side
		bmi.s	Sides_None				; branch if outside x range
		
Sides_Left_SkipChk:
		tst.w	ost_x_vel(a1)
		bmi.s	Sides_Cancel				; branch if Sonic is moving away
		moveq	#solid_left,d1				; set collision flag to left
		bra.s	Sides_Collide
		
Sides_Right:
		sub.w	ost_width_hi(a0),d0
		sub.w	(v_player1_width).w,d0			; d0 = x dist with widths
		subq.w	#1,d0					; 1px correction right side
		cmpi.w	#0,d0
		bgt.s	Sides_None				; branch if outside x range
		
Sides_Right_SkipChk:
		cmpi.w	#0,ost_x_vel(a1)
		bgt.s	Sides_Cancel				; branch if Sonic is moving away
		moveq	#solid_right,d1				; set collision flag to right
		
Sides_Collide:
		btst	#status_breakable_bit,ost_status(a0)
		bne.s	.breakable				; branch if object is breakable
		
	.solid:
		sub.w	d0,ost_x_pos(a1)			; snap to hitbox
		clr.w	ost_inertia(a1)
		clr.w	ost_x_vel(a1)				; stop Sonic moving
		btst	#status_air_bit,ost_status(a1)
		bne.s	.exit					; branch if Sonic is in the air
		bset	#status_pushing_bit,ost_status(a1)	; make Sonic push object
		bset	#status_pushing_bit,ost_status(a0)	; make object be pushed
		
	.exit:
		rts
		
	.breakable:
		cmpi.b	#id_Roll,ost_anim(a1)
		bne.s	.solid					; branch if Sonic isn't rolling
		mvabs.w	ost_x_vel(a1),d2			; get Sonic's speed (abs)
		cmpi.w	#solid_break_x_vel,d2
		bcs.s	.solid					; branch if speed is too low
		ori.b	#solid_broken,d1			; set flag for object broken
		rts
		
Sides_Cancel:
		bclr	#status_pushing_bit,ost_status(a1)
		bclr	#status_pushing_bit,ost_status(a0)	; cancel pushing
		
Sides_None:
		moveq	#solid_none,d1				; set collision flag to none
		rts
