; ---------------------------------------------------------------------------
; Subroutine to make an object solid, top only

; output:
;	d1.l = collision type (0 = none; 1 = top)
;	a1 = address of OST of Sonic

;	uses d0.l, d2.w
; ---------------------------------------------------------------------------

SolidObjectTop:
		tst.b	ost_render(a0)
		bpl.w	Top_None				; branch if object isn't on screen
		tst.w	(v_debug_active_hi).w
		bne.w	Top_None				; branch if debug mode is in use
		
SolidObjectTop_SkipChk:
		tst.b	ost_mode(a0)
		bne.w	Top_Stand				; branch if Sonic is already standing on object
		
		getsonic					; a1 = OST of Sonic
		tst.w	ost_y_vel(a1)
		bmi.w	Top_None				; branch if Sonic is moving up
		move.w	ost_x_pos(a1),d0
		sbabs.w	ost_x_pos(a0),d0			; d0 = x dist
		moveq	#0,d1
		move.b	ost_width(a0),d1
		cmp.w	d0,d1
		bcs.s	Top_None				; branch if outside x range
		
		range_y_quick					; d2 = y dist (-ve if Sonic is above)
		bpl.s	Top_None				; branch if Sonic is below
		moveq	#0,d0
		move.b	ost_height(a1),d0
		add.w	d0,d2
		move.b	ost_height(a0),d0
		add.w	d0,d2
		bmi.s	Top_None				; branch if outside y range
		
		range_x_quick					; d0 = x dist (-ve if Sonic is to the left)
		add.w	d0,d1
		move.b	d1,ost_solid_x_pos(a0)			; save x pos of Sonic on object
		sub.w	d2,ost_y_pos(a1)			; snap to hitbox
		move.w	ost_y_vel(a1),ost_sonic_impact(a1)	; copy Sonic's y speed
		moveq	#0,d1
		move.w	d1,ost_y_vel(a1)			; stop Sonic falling
		move.w	d1,ost_angle(a1)			; clear Sonic's angle
		move.w	ost_x_vel(a1),ost_inertia(a1)
		move.b	#2,ost_mode(a0)				; set flag - Sonic is on the object
		cmpi.b	#id_Roll,ost_anim(a1)
		bne.s	.not_rolling				; branch if Sonic wasn't rolling/jumping
		addq.b	#2,ost_mode(a0)				; set flag - Sonic hit the object rolling/jumping
		
	.not_rolling:
		bset	#status_platform_bit,ost_status(a0)	; set object's platform flag
		bset	#status_platform_bit,ost_status(a1)	; set Sonic standing on object flag
		move.w	a0,ost_sonic_on_obj(a1)			; save OST of object being stood on
		btst	#status_air_bit,ost_status(a1)
		beq.s	.exit					; branch if Sonic isn't jumping
		exg	a0,a1					; temporarily make Sonic the current object
		jsr	Sonic_ResetOnFloor			; reset Sonic as if on floor
		exg	a0,a1

	.exit:
		moveq	#solid_top,d1				; set collision flag to top
		rts
		
Top_None:
		moveq	#solid_none,d1				; set collision flag to none
		rts
		
Top_Stand:
		getsonic					; a1 = OST of Sonic
		btst	#status_air_bit,ost_status(a1)
		bne.s	Top_Leave				; branch if Sonic jumps
		tst.w	ost_x_vel(a1)
		beq.s	.not_moving				; branch if Sonic isn't moving
		
		range_x_quick					; d0 = x dist (-ve if Sonic is to the left)
		moveq	#0,d1
		move.b	ost_width(a0),d1
		add.w	d1,d0					; get Sonic's x pos on platform
		bmi.s	Top_Leave				; branch if beyond left edge
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.s	Top_Leave				; branch if beyond right edge
		move.b	d0,ost_solid_x_pos(a0)			; save x pos of Sonic on object
		
	.not_moving:
		move.w	ost_y_pos(a0),d2
		moveq	#0,d1
		move.b	ost_height(a0),d1
		sub.w	d1,d2
		move.b	ost_height(a1),d1
		sub.w	d1,d2
		move.w	d2,ost_y_pos(a1)			; snap to hitbox
		
		move.w	ost_x_prev(a0),d2
		beq.s	.skip_x_prev				; branch if previous x pos is unused
		sub.w	ost_x_pos(a0),d2			; subtract previous x pos for distance in pixels moved (-ve if moved right)
		clr.w	ost_x_prev(a0)
		sub.w	d2,ost_x_pos(a1)			; update Sonic's x position

	.skip_x_prev:
		moveq	#solid_top,d1				; set collision flag to top
		rts
		
Top_Leave:
		bclr	#status_platform_bit,ost_status(a1)	; clear Sonic's platform flag
		bclr	#status_platform_bit,ost_status(a0)	; clear object's platform flag
		moveq	#0,d0
		move.b	d0,ost_mode(a0)
		move.b	d0,ost_solid_x_pos(a0)
		move.b	d0,ost_solid_y_pos(a0)
		moveq	#solid_none,d1
		rts
		