; ---------------------------------------------------------------------------
; Subroutine to make an object solid

; output:
;	d1.l = collision type (0 = none; 1 = top; 2 = bottom; 4 = left; 8 = right)
;	a1 = address of OST of Sonic

;	uses d0.w, d2.l, a2

; usage (if object only moves vertically or not at all):
;		bsr.w	SolidObject

; usage (if object moves horizontally):
;		move.w	ost_x_pos(a0),ost_x_prev(a0)		; save x pos before moving
;		bsr.w	.moveobject				; move object
;		bsr.w	SolidObject
; ---------------------------------------------------------------------------

SolidObject:
		tst.b	ost_render(a0)
		bpl.s	Sol_None				; branch if object isn't on screen

SolidObject_SkipRender:
		tst.w	(v_debug_active_hi).w
		bne.s	Sol_None				; branch if debug mode is in use

SolidObject_SkipRenderDebug:
		tst.b	ost_mode(a0)
		bne.w	Top_Stand				; branch if Sonic is already standing on object
		
		getsonic					; a1 = OST of Sonic
		range_y_quick					; d2 = y dist (-ve if Sonic is above)
		bpl.s	Sol_LowerHalf				; branch if Sonic is below
		addq.w	#1,d2					; 1px correction on top side
		neg.w	d2					; d2 = y dist (abs)
		
Sol_LowerHalf:
		sub.w	ost_height_hi(a0),d2
		sub.w	ost_height_hi(a1),d2			; d2 = y dist with heights
		bpl.s	Sol_None				; branch if outside y range
		
		move.w	ost_x_pos(a1),d0
		subq.w	#1,d0					; 1px correction on right side
		sub.w	ost_x_pos(a0),d0			; d0 = x dist (-ve if Sonic is to the left)
		bpl.s	.right					; branch if Sonic is to the right
		addq.w	#3,d0					; 2px correction on left side
		neg.w	d0					; d0 = x dist (abs)
		
	.right:
		sub.w	ost_width_hi(a0),d0
		sub.w	(v_player1_width).w,d0			; d0 = x dist with widths
		bpl.s	Sol_None				; branch if outside x range

		cmp.w	d0,d2
		blt.s	Sol_Side				; branch if Sonic is to the side
		move.w	ost_y_pos(a1),d1
		sub.w	ost_y_pos(a0),d1			; d1 = y dist (-ve if Sonic is above)
		bpl.w	Bottom_Collide				; branch if Sonic is below
		neg.w	d2
		bra.w	Top_Collide
		
Sol_Side:
		move.w	ost_x_pos(a1),d1
		sub.w	ost_x_pos(a0),d1			; d1 = x dist (-ve if Sonic is to the left)
		bpl.w	Sides_Right_SkipChk			; branch if Sonic is to the right
		neg.w	d0
		bra.w	Sides_Left_SkipChk			; branch if Sonic is to the left

Sol_None:
		moveq	#solid_none,d1				; set collision flag to none
		rts

; ---------------------------------------------------------------------------
; Subroutine to make an object solid, with heightmap

; input:
;	d6.l = resolution of heightmap (0 = 1px per byte; 1 = 2px; 2 = 4px; 3 = 8px)
;	a2 = address of heightmap

; output:
;	d1.l = collision type (0 = none; 1 = top; 2 = bottom; 4 = left; 8 = right)
;	a1 = address of OST of Sonic

;	uses d0.w, d2.w, d3.w
; ---------------------------------------------------------------------------

SolidObjectHeightmap:
		tst.b	ost_render(a0)
		bpl.w	Sol_None				; branch if object isn't on screen
		tst.w	(v_debug_active_hi).w
		bne.w	Sol_None				; branch if debug mode is in use

		tst.b	ost_mode(a0)
		bne.w	TopH_Stand				; branch if Sonic is already standing on object
		
		getsonic
		range_y_quick					; d2 = y dist (-ve if Sonic is above)
		bpl.w	Sol_LowerHalf				; branch if Sonic is below (use regular height)
		
		move.w	ost_x_pos(a1),d0
		subq.w	#1,d0					; 1px correction on right side
		sub.w	ost_x_pos(a0),d0			; d0 = x dist (-ve if Sonic is to the left)
		bpl.s	.right					; branch if Sonic is to the right
		addq.w	#3,d0					; 2px correction on left side
		neg.w	d0					; d0 = x dist (abs)
		
	.right:
		sub.w	ost_width_hi(a0),d0
		sub.w	(v_player1_width).w,d0			; d0 = x dist with widths
		bpl.w	Sol_None				; branch if outside x range
		
		bsr.w	GetPosOnObject				; d1 = x pos on object
		move.w	d1,d3
		bsr.w	GetHeightOnObject			; d1 = height of object below Sonic
		add.w	d1,d2
		add.w	ost_height_hi(a1),d2			; d2 = y dist with heights
		bmi.w	Sol_None				; branch if outside y range
		
		neg.w	d2
		cmp.w	d0,d2
		blt.w	Sol_Side				; branch if Sonic is to the side
		move.w	d3,ost_solid_x_pos(a0)			; save x pos
		move.b	d1,ost_solid_y_pos(a0)			; save height
		add.w	d2,ost_y_pos(a1)			; snap to hitbox
		bra.w	Top_Collide_SkipPos

; ---------------------------------------------------------------------------
; Subroutine to cancel a solid object

; output:
;	d1.l = 0
;	a1 = address of OST of Sonic
; ---------------------------------------------------------------------------

UnSolid:
		getsonic
		btst	#status_platform_bit,ost_status(a0)
		beq.s	.exit					; branch if Sonic isn't standing on the object
		bclr	#status_platform_bit,ost_status(a1)	; remove platform effect
		bclr	#status_platform_bit,ost_status(a0)
		clr.b	ost_mode(a0)
		moveq	#solid_none,d1

	.exit:
		rts

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
