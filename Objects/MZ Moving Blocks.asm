; ---------------------------------------------------------------------------
; Object 52 - moving platform blocks (MZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 1/2/$41

; subtypes:
;	%TTTTMMMM
;	TTTT - type (0-2, each with its own width, frame & tile setting)
;	MMMM - movement pattern (0-7)
; ---------------------------------------------------------------------------

MovingBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	MBlock_Index(pc,d0.w),d1
		jmp	MBlock_Index(pc,d1.w)
; ===========================================================================
MBlock_Index:	index *,,2
		ptr MBlock_Main
		ptr MBlock_Solid

MBlock_Var:	; object width,	frame number
MBlock_Var_0:	dc.b $10, id_frame_mblock_mz1			; $0x - single block
		dc.w tile_Kos_MzBlock+tile_pal3
MBlock_Var_1:	dc.b $20, id_frame_mblock_mz2			; $1x - double block (unused)
		dc.w tile_Kos_MzBlock+tile_pal3
MBlock_Var_2:	dc.b $30, id_frame_mblock_mz3			; $3x - triple block
		dc.w tile_Kos_MzBlock+tile_pal3

sizeof_MBlock_Var:	equ MBlock_Var_1-MBlock_Var

		rsobj MovingBlock
ost_mblock_x_start:	rs.w 1					; original x position
		rsobjend
; ===========================================================================

MBlock_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto MBlock_Solid next
		move.l	#Map_MBlock,ost_mappings(a0)
		move.b	#render_rel,ost_render(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype
		andi.w	#$F0,d0					; read only high nybble
		lsr.w	#2,d0
		lea	MBlock_Var(pc,d0.w),a2			; get variables
		move.b	(a2),ost_displaywidth(a0)
		move.b	(a2)+,ost_width(a0)
		move.b	(a2)+,ost_frame(a0)
		move.w	(a2)+,ost_tile(a0)
		move.b	#8,ost_height(a0)
		move.b	#4,ost_priority(a0)
		move.w	ost_x_pos(a0),ost_mblock_x_start(a0)
		andi.b	#$F,ost_subtype(a0)			; clear high nybble of subtype

MBlock_Solid:	; Routine 2
		shortcut
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		bsr.s	MBlock_Move				; move & update position
		bsr.w	SolidObject_TopOnly
		move.w	ost_mblock_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

MBlock_Move:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		add.w	d0,d0
		move.w	MBlock_TypeIndex(pc,d0.w),d1
		jmp	MBlock_TypeIndex(pc,d1.w)
; ===========================================================================
MBlock_TypeIndex:index *
		ptr MBlock_Still				; 0 - doesn't move
		ptr MBlock_LeftRight				; 1 - moves side to side
		ptr MBlock_Right				; 2 - moves right when stood on, stops at wall
		ptr MBlock_Right_Now				; 3 - moves right immediately, stops at wall
		ptr MBlock_RightDrop				; 4 - moves right when stood on, stops at wall and drops
		ptr MBlock_RightDrop_Now			; 5 - moves right immediately, stops at wall and drops
		ptr MBlock_Drop_Now				; 6 - drops immediately
		ptr MBlock_RightDrop_Button			; 7 - appears when button 2 is pressed; moves right when stood on, stops at wall and drops
; ===========================================================================

; Type 0
MBlock_Still:
		rts	
; ===========================================================================

; Type 1
MBlock_LeftRight:
		move.b	(v_oscillating_0_to_60).w,d0
		move.w	#$60,d1
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d0
		add.w	d1,d0

	.no_xflip:
		move.w	ost_mblock_x_start(a0),d1
		sub.w	d0,d1
		move.w	d1,ost_x_pos(a0)
		rts	
; ===========================================================================

; Type 2
; Type 4
MBlock_Right:
MBlock_RightDrop:
		tst.b	ost_mode(a0)				; is Sonic standing on the platform?
		beq.s	.wait
		addq.b	#1,ost_subtype(a0)			; if yes, add 1 to type

	.wait:
		rts	
; ===========================================================================

; Type 3
MBlock_Right_Now:
		bsr.w	FindWallRightObj
		tst.w	d1					; has the platform hit a wall?
		bmi.s	.hit_wall				; if yes, branch
		addq.w	#1,ost_x_pos(a0)			; move platform to the right
		move.w	ost_x_pos(a0),ost_mblock_x_start(a0)
		rts	

.hit_wall:
		clr.b	ost_subtype(a0)				; change to type 00 (non-moving	type)
		rts	
; ===========================================================================

; Type 5
MBlock_RightDrop_Now:
		bsr.w	FindWallRightObj
		tst.w	d1					; has the platform hit a wall?
		bmi.s	.hit_wall				; if yes, branch
		addq.w	#1,ost_x_pos(a0)			; move platform to the right
		move.w	ost_x_pos(a0),ost_mblock_x_start(a0)
		rts	

.hit_wall:
		addq.b	#1,ost_subtype(a0)			; change to type 06 (falling)
		rts	
; ===========================================================================

; Type 6
MBlock_Drop_Now:
		update_y_fall	$18				; make the platform fall
		bsr.w	FindFloorObj
		tst.w	d1					; has platform hit the floor?
		bpl.s	.keep_falling				; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		clr.w	ost_y_vel(a0)				; stop platform	falling
		clr.b	ost_subtype(a0)				; change to type 00 (non-moving)

	.keep_falling:
		rts	
; ===========================================================================

; Type 7
MBlock_RightDrop_Button:
		tst.b	(v_button_state+2).w			; has button number 02 been pressed?
		beq.s	.not_pressed
		move.b	#id_MBlock_RightDrop,ost_subtype(a0)	; if yes, change object type to 04

	.not_pressed:
		addq.l	#4,sp
		move.w	ost_mblock_x_start(a0),d0
		bsr.w	CheckActive
		bne.w	DeleteObject
		rts
