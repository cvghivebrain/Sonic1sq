; ---------------------------------------------------------------------------
; Subroutine to make an object solid

; output:
;	d0 = x position of Sonic on object, starting at 0 on left edge
;	d1 = collision type (0 = none; 1 = top; 2 = bottom; 4 = left; 8 = right)
;	a1 = address of OST of Sonic
;	uses d0, d1, d2, d3, d4, d5, d6
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
		moveq	#0,d6
		move.b	ost_height(a1),d6
		sub.w	d6,d5					; d5 = y pos of Sonic's top edge
		move.w	d4,d2					; d2 = object height
		add.w	ost_y_pos(a0),d4			; d4 = y pos of obj bottom edge
		cmp.w	d4,d5
		bhi.s	Sol_Below				; branch if Sonic is below bottom edge
		add.w	d6,d5
		add.w	d6,d5					; d5 = y pos of Sonic's bottom edge
		sub.w	#4,d5					; extra 4px leeway
		sub.w	d2,d4
		sub.w	d2,d4					; d4 = y pos of obj top edge
		cmp.w	d4,d5
		bcs.s	Sol_Above				; branch if Sonic is above top edge
		bra.s	Sol_Side
		
	.exit:
		moveq	#0,d1					; set collision flag to none
		rts
		
Sol_Below:
		sub.w	d3,ost_y_pos(a1)			; snap to hitbox
		moveq	#2,d1					; set collision flag to bottom
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
		
; ---------------------------------------------------------------------------
; Subroutine to make an object solid, sides only

; output:
;	d0 = x position of Sonic on object, starting at 0 on left edge
;	d1 = collision type (0 = none; 4 = left; 8 = right)
;	a1 = address of OST of Sonic
;	uses d0, d1, d2, d3, d4, d5, d6
; ---------------------------------------------------------------------------

SolidNew_SidesOnly:
		bsr.w	RangePlus				; get distances between Sonic (a1) and object (a0)
		cmp.w	#0,d1
		bgt.s	.exit					; branch if outside hitbox
		tst.w	d3
		bpl.s	.exit
		move.w	ost_y_pos(a1),d5
		moveq	#0,d6
		move.b	ost_height(a1),d6
		sub.w	d6,d5					; d5 = y pos of Sonic's top edge
		move.w	d4,d2					; d2 = object height
		add.w	ost_y_pos(a0),d4			; d4 = y pos of obj bottom edge
		cmp.w	d4,d5
		bhi.s	.exit					; branch if Sonic is below bottom edge
		add.w	d6,d5
		add.w	d6,d5					; d5 = y pos of Sonic's bottom edge
		sub.w	d2,d4
		sub.w	d2,d4					; d4 = y pos of obj top edge
		cmp.w	d4,d5
		bcs.s	.exit					; branch if Sonic is above top edge
		bra.w	Sol_Side
		
	.exit:
		moveq	#0,d1					; set collision flag to none
		rts
