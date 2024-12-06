; ---------------------------------------------------------------------------
; Subroutine to make an object solid, top only

; output:
;	d1.l = collision type (0 = none; 1 = top)
;	a1 = address of OST of Sonic

;	uses d0.l, d2.w

; usage (if object only moves vertically or not at all):
;		bsr.w	SolidObjectTop

; usage (if object moves horizontally):
;		move.w	ost_x_pos(a0),ost_x_prev(a0)		; save x pos before moving
;		bsr.w	.moveobject				; move object
;		bsr.w	SolidObjectTop
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
		
		range_y_quick					; d2 = y dist (-ve if Sonic is above)
		bpl.s	Top_None				; branch if Sonic is below
		addq.w	#1,d2
		add.w	ost_height_hi(a0),d2
		add.w	ost_height_hi(a1),d2			; d2 = y dist with heights
		bmi.s	Top_None				; branch if outside y range
		
		move.w	ost_x_pos(a1),d0
		sbabs.w	ost_x_pos(a0),d0			; d0 = x dist (abs)
		sub.w	ost_width_hi(a0),d0
		sub.w	(v_player1_width).w,d0			; d0 = x dist with widths
		bpl.s	Top_None				; branch if outside x range
		
Top_Collide:
		bsr.w	GetPosOnObject				; d1 = x pos of Sonic on object
		move.w	d1,ost_solid_x_pos(a0)			; save x pos of Sonic on object
		sub.w	d2,ost_y_pos(a1)			; snap to hitbox
		
Top_Collide_SkipPos:
		move.w	ost_y_vel(a1),ost_sonic_impact(a1)	; copy Sonic's y speed
		move.b	#2,ost_mode(a0)				; set flag - Sonic is on the object
		cmpi.b	#id_Roll,ost_anim(a1)
		bne.s	.not_rolling				; branch if Sonic wasn't rolling/jumping
		addq.b	#2,ost_mode(a0)				; set flag - Sonic hit the object rolling/jumping
		
	.not_rolling:
		moveq	#0,d1
		move.w	d1,ost_y_vel(a1)			; stop Sonic falling
		move.w	d1,ost_angle(a1)			; clear Sonic's angle
		move.w	ost_x_vel(a1),ost_inertia(a1)
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
		
		move.w	ost_x_pos(a1),d0
		sbabs.w	ost_x_pos(a0),d0			; d0 = x dist (abs)
		sub.w	ost_width_hi(a0),d0
		sub.w	(v_player1_width).w,d0			; d0 = x dist with widths
		bpl.w	Top_Leave				; branch if outside x range
		
		bsr.w	GetPosOnObject				; d1 = x pos of Sonic on object
		move.w	d1,ost_solid_x_pos(a0)			; save x pos of Sonic on object
		
	.not_moving:
		move.w	ost_y_pos(a0),d2
		subq.w	#1,d2
		sub.w	ost_height_hi(a0),d2
		sub.w	ost_height_hi(a1),d2
		move.w	d2,ost_y_pos(a1)			; snap to hitbox
		
Top_Stand_ChkX:
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
		moveq	#solid_none,d1
		move.b	d1,ost_mode(a0)
		move.w	d1,ost_solid_x_pos(a0)
		move.b	d1,ost_solid_y_pos(a0)
		rts

; ---------------------------------------------------------------------------
; Subroutine to get Sonic's x position on an object

; input:
;	a1 = address of OST of Sonic

; output:
;	d1.w = x position, starting at 0 on left edge
;	d3.w = total width of object

;	uses d1.l
; ---------------------------------------------------------------------------

GetPosOnObject:
		move.w	ost_x_pos(a1),d1
		sub.w	ost_x_pos(a0),d1			; d1 = x dist (-ve if Sonic is to the left)
		move.w	ost_width_hi(a0),d3
		add.w	d3,d1					; d1 = x pos on object
		bpl.s	.no_left_overhang			; branch if not overhanging left side
		moveq	#0,d1					; set to 0 if overhanging
		rts
		
	.no_left_overhang:
		add.w	d3,d3					; d3 = total width of object
		cmp.w	d3,d1
		bcs.s	.exit					; branch if x pos is within object's width
		move.w	d3,d1
		subq.w	#1,d1					; set to width-1 if overhanging
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to get the height of an object below Sonic

; input:
;	d1.w = x position, starting at 0 on left edge
;	d6.l = resolution of heightmap (0 = 1px per byte; 1 = 2px; 2 = 4px; 3 = 8px)
;	a2 = address of heightmap

; output:
;	d1.w = height of object below Sonic
; ---------------------------------------------------------------------------

GetHeightOnObject:
		lsr.w	d6,d1					; reduce precision of x pos
		move.b	(a2,d1.w),d1				; get height byte from heightmap
		andi.w	#$FF,d1					; clear high byte
		rts

; ---------------------------------------------------------------------------
; Subroutine to make an object solid, top only with heightmap

; input:
;	d6.l = resolution of heightmap (0 = 1px per byte; 1 = 2px; 2 = 4px; 3 = 8px)
;	a2 = address of heightmap

; output:
;	d1.l = collision type (0 = none; 1 = top)
;	a1 = address of OST of Sonic

;	uses d0.w, d2.w, d3.w
; ---------------------------------------------------------------------------

SolidObjectTopHeightmap:
		tst.b	ost_render(a0)
		bpl.w	Top_None				; branch if object isn't on screen
		tst.w	(v_debug_active_hi).w
		bne.w	Top_None				; branch if debug mode is in use
		
SolidObjectTopHeightmap_SkipChk:
		tst.b	ost_mode(a0)
		bne.w	TopH_Stand				; branch if Sonic is already standing on object
		
		getsonic					; a1 = OST of Sonic
		tst.w	ost_y_vel(a1)
		bmi.w	Top_None				; branch if Sonic is moving up
		
		range_y_quick					; d2 = y dist (-ve if Sonic is above)
		bpl.w	Top_None				; branch if Sonic is below
		
		move.w	ost_x_pos(a1),d0
		sbabs.w	ost_x_pos(a0),d0			; d0 = x dist (abs)
		sub.w	ost_width_hi(a0),d0
		sub.w	(v_player1_width).w,d0			; d0 = x dist with widths
		bpl.w	Top_None				; branch if outside x range
		
		bsr.w	GetPosOnObject				; d1 = x pos of Sonic on object
		move.w	d1,ost_solid_x_pos(a0)			; save x pos
		bsr.s	GetHeightOnObject			; d1 = object height below Sonic
		move.b	d1,ost_solid_y_pos(a0)			; save height
		add.w	d1,d2
		add.w	ost_height_hi(a1),d2			; d2 = y dist with heights
		bmi.w	Top_None				; branch if outside y range
		sub.w	d2,ost_y_pos(a1)			; snap to hitbox
		bra.w	Top_Collide_SkipPos
		
TopH_Stand:
		getsonic					; a1 = OST of Sonic
		btst	#status_air_bit,ost_status(a1)
		bne.w	Top_Leave				; branch if Sonic jumps
		tst.w	ost_x_vel(a1)
		beq.s	.not_moving				; branch if Sonic isn't moving
		
		move.w	ost_x_pos(a1),d0
		sbabs.w	ost_x_pos(a0),d0			; d0 = x dist (abs)
		sub.w	ost_width_hi(a0),d0
		sub.w	(v_player1_width).w,d0			; d0 = x dist with widths
		bpl.w	Top_Leave				; branch if Sonic walks off platform
		
		bsr.w	GetPosOnObject				; d1 = x pos of Sonic on object
		move.w	d1,ost_solid_x_pos(a0)			; save x pos of Sonic on object
		bsr.w	GetHeightOnObject			; d1 = object height below Sonic
		move.b	d1,ost_solid_y_pos(a0)			; save height
		move.w	ost_y_pos(a0),d2
		sub.w	d1,d2
		sub.w	ost_height_hi(a1),d2
		move.w	d2,ost_y_pos(a1)			; snap to hitbox
		bra.w	Top_Stand_ChkX
		
	.not_moving:
		move.w	ost_y_pos(a0),d2
		moveq	#0,d1
		move.b	ost_solid_y_pos(a0),d1
		sub.w	d1,d2
		sub.w	ost_height_hi(a1),d2
		move.w	d2,ost_y_pos(a1)			; snap to hitbox
		bra.w	Top_Stand_ChkX
		