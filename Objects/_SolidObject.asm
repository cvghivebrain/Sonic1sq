; ---------------------------------------------------------------------------
; Subroutine to make an object solid

; output:
;	d1.l = collision type (0 = none; 1 = top; 2 = bottom; 4 = left; 8 = right)
;	a1 = address of OST of Sonic

;	uses d0.l, d2.l, a2

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
		move.w	ost_y_pos(a1),d2
		sbabs.w	ost_y_pos(a0),d2			; d2 = y dist (abs)
		moveq	#0,d0
		move.b	ost_height(a0),d0
		sub.w	d0,d2
		move.b	ost_height(a1),d0
		sub.w	d0,d2					; d2 = y dist with heights
		bpl.s	Sol_None				; branch if outside y range
		
		moveq	#1,d1
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0
		bpl.s	.right					; branch if Sonic is to the right
		neg.w	d0					; d0 = x dist (abs)
		addq.w	#1,d1					; 1px correction on left side
		
	.right:
		add.b	ost_width(a0),d1
		sub.w	d1,d0
		move.w	(v_player1_width).w,d1
		sub.w	d1,d0					; d0 = x dist with widths
		bpl.s	Sol_None				; branch if outside x range

		cmp.w	d0,d2
		blt.s	Sol_Side				; branch if Sonic is to the side
		move.w	ost_y_pos(a1),d0
		sub.w	ost_y_pos(a0),d0			; d0 = y dist (-ve if Sonic is above)
		bpl.w	Bottom_Collide				; branch if Sonic is below
		bra.w	Top_Collide
		
Sol_Side:
		move.w	ost_x_pos(a1),d1
		sub.w	ost_x_pos(a0),d1			; d1 = x dist (-ve if Sonic is to the left)
		bpl.w	Sides_Right_SkipChk			; branch if Sonic is to the right
		neg.w	d0
		bra.w	Sides_Left_SkipChk			; branch if Sonic is to the left

Sol_Below:

Sol_None:
Sol_OffScreen:
		moveq	#solid_none,d1				; set collision flag to none
		rts

Sol_Above:
Sol_Stand_Moving:
Sol_Stand_Leave:

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
		rts
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
