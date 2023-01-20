; ---------------------------------------------------------------------------
; Subroutine to make an object solid

; output:
;	d0.w = x position of Sonic on object, starting at 0 on left edge
;	d1.l = collision type (0 = none; 1 = top; 2 = bottom; 4 = left; 8 = right)
;	a1 = address of OST of Sonic

;	uses d2.w, d3.w, d4.l
; ---------------------------------------------------------------------------

SolidNew:
		bsr.w	RangePlus				; get distances between Sonic (a1) and object (a0)
		tst.b	ost_solid(a0)
		bne.w	Sol_Stand				; branch if Sonic is already standing on object
		cmp.w	#0,d1
		bgt.s	Sol_None				; branch if outside x hitbox
		tst.w	d3
		bpl.s	Sol_None				; branch if outside y hitbox
		
		cmp.w	d1,d3
		blt.s	Sol_Side				; branch if Sonic is to the side
		
		tst.w	d2
		bmi.s	Sol_Above				; branch if Sonic is above
		
Sol_Below:
		sub.w	d3,ost_y_pos(a1)			; snap to hitbox
		move.w	#0,ost_y_vel(a1)			; stop Sonic moving up
		moveq	#2,d1					; set collision flag to bottom
		btst	#status_air_bit,ost_status(a1)
		beq.w	Sol_Kill				; branch if Sonic is on the ground
		rts
		
Sol_None:
		moveq	#0,d1					; set collision flag to none
		rts
		
Sol_Above:
		tst.w	ost_y_vel(a1)
		bmi.s	.exit					; branch if Sonic is moving up
		add.w	d3,ost_y_pos(a1)			; snap to hitbox
		subq.w	#1,ost_y_pos(a1)			; move Sonic up 1px
		move.w	#0,ost_y_vel(a1)			; stop Sonic falling
		move.w	ost_x_vel(a1),ost_inertia(a1)
		move.b	#0,ost_angle(a1)			; clear Sonic's angle
		move.b	#2,ost_solid(a0)			; set flag that Sonic is standing on the object
		bset	#status_platform_bit,ost_status(a0)	; set object's platform flag
		bset	#status_platform_bit,ost_status(a1)	; set Sonic standing on object flag
		move.w	a0,ost_sonic_on_obj(a1)			; save OST of object being stood on
		btst	#status_air_bit,ost_status(a1)
		beq.s	.exit					; branch if Sonic isn't jumping
		exg	a0,a1					; temporarily make Sonic the current object
		jsr	Sonic_ResetOnFloor			; reset Sonic as if on floor
		exg	a0,a1
		moveq	#1,d1					; set collision flag to top
		
	.exit:
		rts
		
Sol_Side:
		tst.w	d0
		bmi.s	.left					; branch if Sonic is on left side
		
	.right:
		sub.w	d1,ost_x_pos(a1)			; snap to hitbox
		moveq	#8,d1					; set collision flag to right
		tst.w	ost_x_vel(a1)
		bpl.s	.away					; branch if Sonic is moving away
		bra.s	.push
		
	.left:
		add.w	d1,ost_x_pos(a1)			; snap to hitbox
		moveq	#4,d1					; set collision flag to left
		tst.w	ost_x_vel(a1)
		bmi.s	.away					; branch if Sonic is moving away
		
	.push:
		bset	#status_pushing_bit,ost_status(a1)	; make Sonic push object
		bset	#status_pushing_bit,ost_status(a0)	; make object be pushed
		move.w	#0,ost_inertia(a1)
		move.w	#0,ost_x_vel(a1)			; stop Sonic moving
		rts
		
	.away:
		bclr	#status_pushing_bit,ost_status(a1)
		bclr	#status_pushing_bit,ost_status(a0)
		rts
		
Sol_Stand:
		btst	#status_air_bit,ost_status(a1)
		bne.s	.leave					; branch if Sonic jumps
		cmp.w	#0,d1
		bgt.s	.leave					; branch if Sonic is outside left/right edges
		
		moveq	#0,d4
		move.b	ost_width(a0),d4
		add.w	d4,d0					; d0 = x pos of Sonic on object, starting at 0 on left edge
		
		add.w	d3,ost_y_pos(a1)			; align Sonic with top of object
		tst.w	ost_x_prev(a0)
		beq.s	.skip_x					; branch if previous x pos is unused
		move.w	ost_x_pos(a0),d2
		sub.w	ost_x_prev(a0),d2			; subtract previous x pos for distance in pixels moved (+ve if moved right)
		add.w	d2,ost_x_pos(a1)			; update Sonic's x position
		
	.skip_x:
		moveq	#1,d1					; set collision flag to top
		rts

	.leave:
		bclr	#status_platform_bit,ost_status(a1)	; clear Sonic's standing flag
		bclr	#status_platform_bit,ost_status(a0)	; clear object's standing flag
		clr.b	ost_solid(a0)
		rts
		
Sol_Kill:
		movea.l	a0,a2					; this object killed Sonic
		exg	a0,a1					; temporarily make Sonic the current object
		jsr	KillSonic				; Sonic dies
		exg	a0,a1					; restore this object as current
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to make an object solid, sides only

; output:
;	d0.w = x position of Sonic on object, starting at 0 on left edge
;	d1.l = collision type (0 = none; 4 = left; 8 = right)
;	a1 = address of OST of Sonic

;	uses d2.w, d3.w, d4.l
; ---------------------------------------------------------------------------

SolidNew_SidesOnly:
		bsr.w	RangePlus				; get distances between Sonic (a1) and object (a0)
		cmp.w	#0,d1
		bgt.s	.exit					; branch if outside x hitbox
		tst.w	d3
		bpl.s	.exit					; branch if outside y hitbox
		
		cmp.w	d1,d3
		blt.w	Sol_Side				; branch if Sonic is to the side
		
	.exit:
		moveq	#0,d1					; set collision flag to none
		rts
