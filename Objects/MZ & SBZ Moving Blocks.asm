; ---------------------------------------------------------------------------
; Object 52 - moving platform blocks (MZ, SBZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 1/2/$41
;	ObjPos_SBZ1, ObjPos_SBZ2 - subtypes $28/$39
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
MBlock_Var_2:	dc.b $20, id_frame_mblock_sbz			; $2x - SBZ black & yellow platform
		dc.w tile_Kos_Stomper+tile_pal2
MBlock_Var_3:	dc.b $3F, id_frame_mblock_sbzwide		; $3x - SBZ red horizontal door
		dc.w tile_Kos_SlideFloor+tile_pal3
MBlock_Var_4:	dc.b $30, id_frame_mblock_mz3			; $4x - triple block
		dc.w tile_Kos_MzBlock+tile_pal3

sizeof_MBlock_Var:	equ MBlock_Var_1-MBlock_Var

		rsobj MovingBlock
ost_mblock_x_start:	rs.w 1					; original x position (2 bytes)
ost_mblock_y_start:	rs.w 1					; original y position (2 bytes)
ost_mblock_wait_time:	rs.w 1					; time delay before moving platform back - subtype x9/xA only (2 bytes)
ost_mblock_move_flag:	rs.b 1					; 1 = move platform back to its original position - subtype x9/xA only
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
		move.w	ost_y_pos(a0),ost_mblock_y_start(a0)
		andi.b	#$F,ost_subtype(a0)			; clear high nybble of subtype

MBlock_Solid:	; Routine 2
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		bsr.s	MBlock_Move				; move & update position
		bsr.w	SolidObject_TopOnly
		move.w	ost_mblock_x_start(a0),d0
		bsr.w	DespawnQuick_AltX
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
		ptr MBlock_UpDown				; 8 - moves up and down
		ptr MBlock_Slide				; 9 - quickly slides right when stood on
		ptr MBlock_Slide_Now				; $A - slides right immediately
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
; Type 9
MBlock_Right:
MBlock_RightDrop:
MBlock_Slide:
		tst.b	ost_solid(a0)				; is Sonic standing on the platform?
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
		bsr.w	SpeedToPos
		addi.w	#$18,ost_y_vel(a0)			; make the platform fall
		bsr.w	FindFloorObj
		tst.w	d1					; has platform hit the floor?
		bpl.w	.keep_falling				; if not, branch
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
; ===========================================================================

; Type 8
MBlock_UpDown:
		move.b	(v_oscillating_0_to_80).w,d0
		move.w	#$80,d1
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d0					; reverse vertical direction if xflip bit is set
		add.w	d1,d0

	.no_xflip:
		move.w	ost_mblock_y_start(a0),d1
		sub.w	d0,d1
		move.w	d1,ost_y_pos(a0)
		rts	
; ===========================================================================

; Type $A
MBlock_Slide_Now:
		move.w	#$80,d3
		moveq	#8,d1
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d1
		neg.w	d3

	.no_xflip:
		tst.b	ost_mblock_move_flag(a0)		; is platform set to move back?
		bne.s	MBlock_0A_Back				; if yes, branch
		move.w	ost_x_pos(a0),d0
		sub.w	ost_mblock_x_start(a0),d0
		cmp.w	d3,d0
		beq.s	MBlock_0A_Wait
		add.w	d1,ost_x_pos(a0)			; move platform
		move.w	#300,ost_mblock_wait_time(a0)		; set time delay to 5 seconds
		rts	
; ===========================================================================

MBlock_0A_Wait:
		subq.w	#1,ost_mblock_wait_time(a0)		; subtract 1 from time delay
		bne.s	.wait					; if time remains, branch
		move.b	#1,ost_mblock_move_flag(a0)		; set platform to move back to its original position

	.wait:
		rts	
; ===========================================================================

MBlock_0A_Back:
		move.w	ost_x_pos(a0),d0
		sub.w	ost_mblock_x_start(a0),d0
		beq.s	MBlock_0A_Reset
		sub.w	d1,ost_x_pos(a0)			; return platform to its original position
		rts	
; ===========================================================================

MBlock_0A_Reset:
		clr.b	ost_mblock_move_flag(a0)
		subq.b	#1,ost_subtype(a0)			; restore subtype to 9
		rts	
