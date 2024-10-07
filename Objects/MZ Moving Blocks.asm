; ---------------------------------------------------------------------------
; Object 52 - moving platform blocks (MZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3

; subtypes:
;	%TTTTMMM
;	TTTT - type (0-2, each with its own width & frame id)
;	MMMM - movement pattern (0-6)

type_mblock_1:		equ 0					; $0x - single block
type_mblock_2:		equ $10					; $1x - double block
type_mblock_3:		equ $20					; $2x - triple block
type_mblock_still:	equ id_MBlock_Still>>1			; $x0 - doesn't move
type_mblock_leftright:	equ id_MBlock_LeftRight>>1		; $x1 - moves side to side
type_mblock_right:	equ id_MBlock_Right>>1			; $x2 - moves right when stood on, stops at wall
type_mblock_rightdrop:	equ id_MBlock_RightDrop>>1		; $x4 - moves right when stood on, stops at wall and drops
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
		dc.b $10, id_frame_mblock_mz1			; $0x - single block
		dc.b $20, id_frame_mblock_mz2			; $1x - double block (unused)
		dc.b $30, id_frame_mblock_mz3			; $2x - triple block

		rsobj MovingBlock
ost_mblock_x_start:	rs.w 1					; original x position
		rsobjend
; ===========================================================================

MBlock_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto MBlock_Solid next
		move.l	#Map_MBlock,ost_mappings(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	ost_subtype(a0),d0			; get subtype
		move.b	d0,d2
		andi.w	#$F0,d0					; read only high nybble
		lsr.w	#3,d0
		lea	MBlock_Var(pc,d0.w),a2			; get variables
		move.b	(a2),ost_displaywidth(a0)
		move.b	(a2)+,ost_width(a0)
		move.b	(a2)+,ost_frame(a0)
		move.w	#tile_Kos_MzBlock+tile_pal3,ost_tile(a0)
		move.b	#8,ost_height(a0)
		move.w	#priority_4,ost_priority(a0)
		move.b	#StrId_Block,ost_name(a0)
		move.w	ost_x_pos(a0),ost_mblock_x_start(a0)
		andi.b	#$F,d2
		add.b	d2,d2
		move.b	d2,ost_subtype(a0)			; clear high nybble of subtype

MBlock_Solid:	; Routine 2
		shortcut
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		bsr.s	MBlock_Move				; move & update position
		bsr.w	SolidObjectTop
		move.w	ost_mblock_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

MBlock_Move:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		move.w	MBlock_TypeIndex(pc,d0.w),d1
		jmp	MBlock_TypeIndex(pc,d1.w)
; ===========================================================================
MBlock_TypeIndex:index *,,2
		ptr MBlock_Still				; 0 - doesn't move
		ptr MBlock_LeftRight				; 1 - moves side to side
		ptr MBlock_Right				; 2 - moves right when stood on, stops at wall
		ptr MBlock_Right_Now				; 3 - moves right immediately, stops at wall
		ptr MBlock_RightDrop				; 4 - moves right when stood on, stops at wall and drops
		ptr MBlock_RightDrop_Now			; 5 - moves right immediately, stops at wall and drops
		ptr MBlock_Drop_Now				; 6 - drops immediately
; ===========================================================================

; Type 0
MBlock_Still:
		rts	
; ===========================================================================

; Type 1
MBlock_LeftRight:
		move.b	(v_oscillating_0_to_60).w,d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d0
		addi.w	#$60,d0

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
		addq.b	#2,ost_subtype(a0)			; if yes, increment type

	.wait:
		rts	
; ===========================================================================

; Type 3
MBlock_Right_Now:
		getpos_right					; d0 = x pos of right; d1 = y pos
		moveq	#1,d6
		bsr.w	WallRightDist
		tst.w	d5					; has the platform hit a wall?
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
		getpos_right					; d0 = x pos of right; d1 = y pos
		moveq	#1,d6
		bsr.w	WallRightDist
		tst.w	d5					; has the platform hit a wall?
		bmi.s	.hit_wall				; if yes, branch
		addq.w	#1,ost_x_pos(a0)			; move platform to the right
		move.w	ost_x_pos(a0),ost_mblock_x_start(a0)
		rts	

.hit_wall:
		addq.b	#2,ost_subtype(a0)			; goto MBlock_Drop_Now next
		rts	
; ===========================================================================

; Type 6
MBlock_Drop_Now:
		update_y_fall	$18				; make the platform fall
		getpos_bottom					; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		bsr.w	FloorDist
		tst.w	d5					; has platform hit the floor?
		bpl.s	.keep_falling				; if not, branch
		add.w	d5,ost_y_pos(a0)			; align to floor
		clr.w	ost_y_vel(a0)				; stop platform	falling
		clr.b	ost_subtype(a0)				; change to type 00 (non-moving)

	.keep_falling:
		rts
