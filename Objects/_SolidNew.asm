; ---------------------------------------------------------------------------
; Subroutine to make an object solid

; output:
;	a1 = address of OST of Sonic
;	uses d0, d1, d2, d3, d4, d5
; ---------------------------------------------------------------------------

SolidNew:
		bsr.w	RangePlus				; get distances between Sonic (a1) and object (a0)
		tst.b	ost_solid(a0)
		bne.w	Sol_Stand				; branch if Sonic is already standing on object
		cmp.w	#0,d1
		bgt.s	.exit					; branch if outside hitbox
		tst.w	d3
		bpl.s	.exit
		move.w	ost_y_pos(a1),d5
		move.w	d4,d2					; d2 = object height
		add.w	ost_y_pos(a0),d4			; d4 = y pos of obj bottom edge
		cmp.w	d4,d5
		bhi.s	Sol_Below				; branch if Sonic is below bottom edge
		sub.w	d2,d4
		sub.w	d2,d4					; d4 = y pos of obj top edge
		cmp.w	d4,d5
		bcs.s	Sol_Above				; branch if Sonic is above top edge
		bra.s	Sol_Side
		
	.exit:
		rts
		
Sol_Below:
		sub.w	d3,ost_y_pos(a1)			; snap to hitbox
		rts
		
Sol_Above:
		tst.w	ost_y_vel(a1)
		bmi.s	.exit					; branch if Sonic is moving up
		add.w	d3,ost_y_pos(a1)			; snap to hitbox
		move.w	#0,ost_y_vel(a1)			; stop Sonic falling
		;move.w	#0,ost_inertia(a1)
		move.b	#0,ost_angle(a1)			; clear Sonic's angle
		move.b	#2,ost_solid(a0)			; set flag that Sonic is standing on the object
		bset	#status_platform_bit,ost_status(a0)	; set object's platform flag
		bset	#status_platform_bit,ost_status(a1)	; set Sonic standing on object flag
		move.w	a0,d5
		subi.w	#v_ost_all&$FFFF,d5
		lsr.w	#6,d5
		andi.w	#$7F,d5					; convert object's OST address to index
		move.b	d5,ost_sonic_on_obj(a1)			; save index of object being stood on
		btst	#status_air_bit,ost_status(a1)
		beq.s	.exit					; branch if Sonic isn't jumping
		exg	a0,a1					; temporarily make Sonic the current object
		jsr	Sonic_ResetOnFloor			; reset Sonic as if on floor
		exg	a0,a1
		
	.exit:
		rts
		
Sol_Side:
		tst.w	d0
		bmi.s	.left					; branch if Sonic is on left side
		
	.right:
		sub.w	d1,ost_x_pos(a1)			; snap to hitbox
		tst.w	ost_x_vel(a1)
		bpl.s	.away					; branch if Sonic is moving away
		bra.s	.push
		
	.left:
		add.w	d1,ost_x_pos(a1)			; snap to hitbox
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
		
		add.w	d3,ost_y_pos(a1)			; align Sonic with top of object
		move.w	ost_x_vel(a0),d0
		asr.w	#8,d0					; get distance in pixels moved
		add.w	d0,ost_x_pos(a1)			; update Sonic's x position
		rts

	.leave:
		bclr	#status_platform_bit,ost_status(a1)	; clear Sonic's standing flag
		bclr	#status_platform_bit,ost_status(a0)	; clear object's standing flag
		clr.b	ost_solid(a0)
		rts
		