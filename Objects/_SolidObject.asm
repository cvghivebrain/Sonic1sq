; ---------------------------------------------------------------------------
; Subroutine to make an object solid

; output:
;	d1.l = collision type (0 = none; 1 = top; 2 = bottom; 4 = left; 8 = right)
;	d4.w = x position of Sonic on object, starting at 0 on left edge
;	a1 = address of OST of Sonic

;	uses d0.w, d2.w, d3.w, d4.l, d5.l

; usage (if object only moves vertically or not at all):
;		bsr.w	SolidObject

; usage (if object moves horizontally):
;		move.w	ost_x_pos(a0),ost_x_prev(a0)		; save x pos before moving
;		bsr.w	.moveobject				; move object
;		bsr.w	SolidObject
; ---------------------------------------------------------------------------

SolidObject:
		tst.b	ost_render(a0)
		bpl.w	Sol_OffScreen				; branch if object isn't on screen

SolidObject_SkipRender:
		tst.w	(v_debug_active_hi).w
		bne.s	Sol_None				; branch if debug mode is in use

SolidObject_SkipRenderDebug:
		getsonic
		tst.b	ost_mode(a0)
		bne.w	Sol_Stand				; branch if Sonic is already standing on object
		range_x_sonic					; get distances between Sonic (a1) and object (a0)
		cmpi.w	#0,d1
		bgt.s	Sol_None				; branch if outside x hitbox
		range_y_exact
		bpl.s	Sol_None				; branch if outside y hitbox

		cmp.w	d1,d3
		blt.w	Sol_Side				; branch if Sonic is to the side

		tst.w	d2
		bmi.s	Sol_Above				; branch if Sonic is above

		cmpi.w	#-1,d1
		bge.s	Sol_None				; branch if Sonic is below, but within 1px of the sides

Sol_Below:
		sub.w	d3,ost_y_pos(a1)			; snap to hitbox
		move.w	#0,ost_y_vel(a1)			; stop Sonic moving up
		moveq	#solid_bottom,d1			; set collision flag to bottom
		btst	#status_air_bit,ost_status(a1)
		beq.w	Sol_Kill				; branch if Sonic is on the ground
		rts

Sol_None:
		btst	#status_pushing_bit,ost_status(a0)
		beq.s	Sol_OffScreen				; branch if object isn't being pushed
		bclr	#status_pushing_bit,ost_status(a1)	; stop pushing
		bclr	#status_pushing_bit,ost_status(a0)

Sol_OffScreen:
		moveq	#solid_none,d1				; set collision flag to none
		rts

Sol_Above:
		tst.w	ost_y_vel(a1)
		bmi.s	Sol_None				; branch if Sonic is moving up
		move.b	d4,ost_solid_x_pos(a0)			; save x pos of Sonic on object
		add.w	d3,ost_y_pos(a1)			; snap to hitbox
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

Sol_Side:
		tst.w	d0
		bmi.s	.left					; branch if Sonic is on left side

	.right:
		sub.w	d1,ost_x_pos(a1)			; snap to hitbox
		moveq	#solid_right,d1				; set collision flag to right
		cmpi.w	#0,ost_x_vel(a1)
		bgt.s	.away					; branch if Sonic is moving away
		bra.s	.push

	.left:
		add.w	d1,ost_x_pos(a1)			; snap to hitbox
		moveq	#solid_left,d1				; set collision flag to left
		tst.w	ost_x_vel(a1)
		bmi.s	.away					; branch if Sonic is moving away

	.push:
		btst	#status_air_bit,ost_status(a1)
		bne.s	.in_air					; branch if Sonic is in the air
		bset	#status_pushing_bit,ost_status(a1)	; make Sonic push object
		bne.s	.stop_moving				; branch if Sonic has already started pushing
		bset	#status_pushing_bit,ost_status(a0)	; make object be pushed
		rts

	.away:
		bclr	#status_pushing_bit,ost_status(a1)
		bclr	#status_pushing_bit,ost_status(a0)
		rts

	.in_air:
		bclr	#status_pushing_bit,ost_status(a1)
		bclr	#status_pushing_bit,ost_status(a0)

	.stop_moving:
		move.w	#0,ost_inertia(a1)
		move.w	#0,ost_x_vel(a1)			; stop Sonic moving
		rts

Sol_Stand:
		btst	#status_air_bit,ost_status(a1)
		bne.s	Sol_Stand_Leave				; branch if Sonic jumps
		range_x_sonic
		
		move.b	d4,ost_solid_x_pos(a0)			; save x pos of Sonic on object
		tst	d1
		bpl.s	Sol_Stand_Leave				; branch if Sonic is outside left/right edges

		moveq	#0,d5
		move.b	ost_height(a0),d5
		
Sol_Stand_Moving:
		move.w	ost_y_pos(a0),d3
		add.b	ost_height(a1),d5
		sub.w	d5,d3
		move.w	d3,ost_y_pos(a1)			; align Sonic with top of object
		
		move.w	ost_x_prev(a0),d2
		beq.s	.skip_x_prev				; branch if previous x pos is unused
		sub.w	ost_x_pos(a0),d2			; subtract previous x pos for distance in pixels moved (-ve if moved right)
		clr.w	ost_x_prev(a0)
		sub.w	d2,ost_x_pos(a1)			; update Sonic's x position

	.skip_x_prev:
		moveq	#solid_top,d1				; set collision flag to top
		rts

Sol_Stand_Leave:
		bclr	#status_platform_bit,ost_status(a1)	; clear Sonic's standing flag
		bclr	#status_platform_bit,ost_status(a0)	; clear object's standing flag
		moveq	#0,d0
		move.b	d0,ost_mode(a0)
		move.b	d0,ost_solid_x_pos(a0)
		move.b	d0,ost_solid_y_pos(a0)
		moveq	#solid_none,d1
		rts

Sol_Kill:
		jmp	ObjectKillSonic				; Sonic dies

; ---------------------------------------------------------------------------
; Subroutine to make an object solid using a heightmap

; input:
;	d6.l = resolution of heightmap (0 = 1px per byte; 1 = 2px; 2 = 4px; 3 = 8px)
;	a2 = address of heightmap

; output:
;	d1.l = collision type (0 = none; 1 = top; 2 = bottom; 4 = left; 8 = right)
;	d4.w = x position of Sonic on object, starting at 0 on left edge
;	a1 = address of OST of Sonic

;	uses d0.w, d2.w, d3.w, d4.l, d5.l

; usage (if object only moves vertically or not at all):
;		moveq	#1,d6					; 1 byte in heightmap = 2px
;		lea	HeightmapData(pc),a2
;		bsr.w	SolidObject_Heightmap

; usage (if object moves horizontally):
;		move.w	ost_x_pos(a0),ost_x_prev(a0)		; save x pos before moving
;		bsr.w	.moveobject				; move object
;		moveq	#1,d6					; 1 byte in heightmap = 2px
;		lea	HeightmapData(pc),a2
;		bsr.w	SolidObject_Heightmap
; ---------------------------------------------------------------------------

SolidObject_Heightmap:
		tst.b	ost_render(a0)
		bpl.w	Sol_OffScreen				; branch if object isn't on screen
		tst.w	(v_debug_active_hi).w
		bne.w	Sol_None				; branch if debug mode is in use

		getsonic
		tst.b	ost_mode(a0)
		bne.s	Sol_Stand_Heightmap			; branch if Sonic is already standing on object
		range_x_sonic					; get distances between Sonic (a1) and object (a0)
		tst.w	d1
		bgt.w	Sol_None				; branch if outside x hitbox

		moveq	#0,d5
		move.w	ost_y_pos(a1),d2
		sub.w	ost_y_pos(a0),d2			; d2 = y dist (-ve if Sonic is above)
		move.w	d2,d3
		bmi.s	.use_heightmap				; branch if Sonic is above object
		move.b	ost_height(a0),d5			; use regular height if below
		bra.s	.skip_heightmap

	.use_heightmap:
		neg.w	d3					; make d3 +ve
		move.w	d4,d5					; d5 = x pos on object
		lsr.w	d6,d5					; reduce precision
		move.b	(a2,d5.w),d5				; get height byte from heightmap
		andi.w	#$FF,d5
		move.b	d5,ost_solid_y_pos(a0)			; save height

	.skip_heightmap:
		sub.w	d5,d3
		move.b	ost_height(a1),d5
		sub.w	d5,d3					; d3 = y dist between hitbox edges (-ve if overlapping)
		
		tst.w	d3
		bpl.w	Sol_None				; branch if outside y hitbox
		
		cmp.w	d1,d3
		blt.w	Sol_Side				; branch if Sonic is to the side
		tst.w	d2
		bmi.w	Sol_Above				; branch if Sonic is above
		cmpi.w	#-1,d1
		bge.w	Sol_None				; branch if Sonic is below, but within 1px of the sides
		bra.w	Sol_Below
		
Sol_Stand_Heightmap:
		btst	#status_air_bit,ost_status(a1)
		bne.w	Sol_Stand_Leave				; branch if Sonic jumps
		tst.w	ost_x_vel(a1)
		bne.s	.moving					; branch if Sonic is moving
		moveq	#0,d4
		move.b	ost_solid_x_pos(a0),d4
		moveq	#0,d5
		move.b	ost_solid_y_pos(a0),d5
		bra.w	Sol_Stand_Moving
		
	.moving:
		range_x_sonic
		move.b	d4,ost_solid_x_pos(a0)			; save x pos of Sonic on object
		tst	d1
		bpl.w	Sol_Stand_Leave				; branch if Sonic is outside left/right edges
		move.w	d4,d5					; d5 = x pos on object
		lsr.w	d6,d5					; reduce precision
		move.b	(a2,d5.w),d5				; get height byte from heightmap
		andi.w	#$FF,d5
		move.b	d5,ost_solid_y_pos(a0)			; save height
		bra.w	Sol_Stand_Moving

; ---------------------------------------------------------------------------
; Subroutine to cancel a solid object

; output:
;	d1.l = 0
;	a1 = address of OST of Sonic
; ---------------------------------------------------------------------------

UnSolid:
		getsonic
		btst	#status_platform_bit,ost_status(a0)
		beq.w	Sol_None				; branch if Sonic isn't standing on the object
		bclr	#status_platform_bit,ost_status(a1)	; remove platform effect
		bclr	#status_platform_bit,ost_status(a0)
		clr.b	ost_mode(a0)
		bra.w	Sol_None				; stop pushing

UnSolid_TopOnly:
		getsonic
		btst	#status_platform_bit,ost_status(a0)
		beq.s	.exit					; branch if Sonic isn't standing on the object
		bset	#status_air_bit,ost_status(a1)
		bclr	#status_platform_bit,ost_status(a1)	; remove platform effect
		bclr	#status_platform_bit,ost_status(a0)
		move.b	#id_Sonic_Control,ost_routine(a1)
		clr.b	ost_mode(a0)
		moveq	#solid_none,d1

	.exit:
		rts
