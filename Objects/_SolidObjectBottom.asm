; ---------------------------------------------------------------------------
; Subroutine to make an object solid, bottom only

; output:
;	d1.l = collision type (0 = none; 2 = bottom)
;	a1 = address of OST of Sonic

;	uses d0.w, d2.w, a2
; ---------------------------------------------------------------------------

SolidObjectBottom:
		tst.b	ost_render(a0)
		bpl.s	Bottom_None				; branch if object isn't on screen
		tst.w	(v_debug_active_hi).w
		bne.s	Bottom_None				; branch if debug mode is in use
		
SolidObjectBottom_SkipChk:
		getsonic					; a1 = OST of Sonic
		move.w	ost_x_pos(a1),d0
		sbabs.w	ost_x_pos(a0),d0			; d0 = x dist (abs)
		sub.w	ost_width_hi(a0),d0
		sub.w	(v_player1_width).w,d0			; d0 = x dist with widths
		bpl.s	Bottom_None				; branch if outside x range
		
		range_y_quick					; d2 = y dist (-ve if Sonic is above)
		bmi.s	Bottom_None				; branch if Sonic is above
		sub.w	ost_height_hi(a0),d2
		sub.w	ost_height_hi(a1),d2			; d2 = y dist with heights
		bpl.s	Bottom_None				; branch if outside y range
		
Bottom_Collide:
		sub.w	d2,ost_y_pos(a1)			; snap to hitbox
		move.w	ost_y_vel(a1),d1
		bpl.s	.keep_speed				; branch if Sonic is moving down
		move.w	d1,ost_sonic_impact(a1)			; copy Sonic's y speed
		clr.w	ost_y_vel(a1)				; stop Sonic moving up
		
	.keep_speed:
		moveq	#solid_bottom,d1			; set collision flag to bottom
		btst	#status_air_bit,ost_status(a1)
		beq.s	Bottom_Kill				; branch if Sonic is on the ground
		rts
		
Bottom_None:
		moveq	#solid_none,d1				; set collision flag to none
		rts

Bottom_Kill:
		jmp	ObjectKillSonic				; Sonic dies
		