; ---------------------------------------------------------------------------
; Object 30 - large green glass blocks (MZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 1/2/4/$14

; subtypes:
;	%BBBBTTTT
;	BBBB - button id (when TTTT is 4)
;	TTTT - block type (0 = still; 1/2 = up/down; 3 = drops on jump; 4 = drops on button)
; ---------------------------------------------------------------------------

GlassBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Glass_Index(pc,d0.w),d1
		jmp	Glass_Index(pc,d1.w)
; ===========================================================================
Glass_Index:	index *,,2
		ptr Glass_Main
		ptr Glass_UpDown
		ptr Glass_UpDownRev
		ptr Glass_JumpDrop
		ptr Glass_BtnDrop
		ptr Glass_Stop

Glass_Type_List:
		; width, height, frame, routine, shine type
		dc.b $20, $38, id_frame_glass_short, id_Glass_Stop, 2
		dc.b $20, $48, id_frame_glass_tall, id_Glass_UpDown, 0
		dc.b $20, $48, id_frame_glass_tall, id_Glass_UpDownRev, 1
		dc.b $20, $38, id_frame_glass_short, id_Glass_JumpDrop, 2
		dc.b $20, $38, id_frame_glass_short, id_Glass_BtnDrop, 2
		even

		rsobj GlassBlock
ost_glass_y_start:	rs.w 1					; original y position (2 bytes)
ost_glass_move_mode:	rs.b 1					; flag set when block is moving
ost_glass_in_floor:	rs.b 1					; flag set when block starts in floor
		rsobjend
; ===========================================================================

Glass_Main:	; Routine 0
		move.l	#Map_Glass,ost_mappings(a0)
		move.w	#tile_Kos_MzGlass+tile_pal3+tile_hi,ost_tile(a0)
		move.b	#render_rel+render_useheight,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.w	ost_y_pos(a0),ost_glass_y_start(a0)
		move.b	ost_subtype(a0),d0
		move.b	d0,d1
		andi.b	#$F,d0					; low nybble of subtype
		mulu.w	#5,d0
		lsr.b	#4,d1
		move.b	d1,ost_subtype(a0)			; move subtype high nybble to low
		lea	Glass_Type_List(pc,d0.w),a2
		move.b	(a2),ost_displaywidth(a0)
		move.b	(a2)+,ost_width(a0)
		move.b	(a2)+,ost_height(a0)
		move.b	(a2)+,ost_frame(a0)
		move.b	(a2)+,ost_routine(a0)
		bsr.w	FindNextFreeObj
		bne.s	.fail
		move.l	#GlassShine,ost_id(a1)			; load glass shine object
		move.l	#Map_Glass,ost_mappings(a1)
		move.w	#tile_Kos_MzGlass+tile_pal3+tile_hi,ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#$10,ost_displaywidth(a1)
		move.b	#3,ost_priority(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.b	#id_frame_glass_shine,ost_frame(a1)
		move.b	(a2)+,ost_subtype(a1)
		saveparent
		
	.fail:
		jsr	(FindFloorObj).l
		tst.w	d1
		bpl.s	.not_in_floor				; branch if block doesn't start in floor
		move.b	#1,ost_glass_in_floor(a0)		; remember that it did
		
	.not_in_floor:
		rts
; ===========================================================================

Glass_UpDown:	; Routine 2
		moveq	#0,d0
		move.b	(v_oscillating_0_to_40_fast).w,d0
		move.w	ost_glass_y_start(a0),d1		; get initial y position
		sub.w	d0,d1					; apply difference
		move.w	d1,ost_y_pos(a0)			; update y position
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================

Glass_UpDownRev:
		; Routine 4
		moveq	#0,d0
		move.b	(v_oscillating_0_to_40_fast).w,d0
		neg.w	d0
		addi.w	#$40,d0					; invert value
		move.w	ost_glass_y_start(a0),d1		; get initial y position
		sub.w	d0,d1					; apply difference
		move.w	d1,ost_y_pos(a0)			; update y position
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================

Glass_JumpDrop:	; Routine 6
		tst.b	ost_glass_move_mode(a0)
		bne.s	.skip_jump				; branch if block is moving
		cmpi.b	#4,ost_mode(a0)
		bne.s	.solid					; branch if not jumped on
		move.b	#1,ost_glass_move_mode(a0)		; set moving flag
		move.w	#$300,ost_y_vel(a0)			; move downwards
		
	.skip_jump:
		update_y_pos					; update position
		subi.w	#$20,ost_y_vel(a0)			; slow down
		bne.s	.not_stopped				; branch if still moving
		clr.b	ost_glass_move_mode(a0)			; allow block to move again
		move.b	#2,ost_mode(a0)
		
	.not_stopped:
		tst.b	ost_glass_in_floor(a0)
		bne.s	.solid					; branch if block started in floor
		jsr	(FindFloorObj).l
		tst.w	d1					; has block hit the floor?
		bpl.s	.solid					; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.b	#id_Glass_Stop,ost_routine(a0)		; goto Glass_Stop next
		
	.solid:
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================

Glass_BtnDrop:	; Routine 8
		tst.b	ost_glass_move_mode(a0)
		bne.s	.skip_button				; branch if block is moving
		lea	(v_button_state).w,a2
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype (not same as original)
		tst.b	(a2,d0.w)				; has button number d0 been pressed?
		beq.s	.solid					; if not, branch
		move.b	#1,ost_glass_move_mode(a0)		; set moving flag

	.skip_button:
		addq.w	#2,ost_y_pos(a0)			; move down 2px
		tst.b	ost_glass_in_floor(a0)
		bne.s	.solid					; branch if block started in floor
		jsr	(FindFloorObj).l
		tst.w	d1					; has block hit the floor?
		bpl.s	.solid					; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.b	#id_Glass_Stop,ost_routine(a0)		; goto Glass_Stop next
		
	.solid:
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================

Glass_Stop:	; Routine $A
		shortcut
		bsr.w	SolidObject
		bra.w	DespawnQuick
		
; ---------------------------------------------------------------------------
; Reflection on large green glass blocks (MZ)

; spawned by:
;	GlassBlock - subtypes 0/1/2
; ---------------------------------------------------------------------------

GlassShine:
		getparent					; a1 = OST of glass block object
		moveq	#0,d0
		move.b	(v_oscillating_0_to_40_fast).w,d0
		cmpi.b	#2,ost_subtype(a0)
		beq.s	.short_block				; branch if glass block is smaller
		cmpi.b	#1,ost_subtype(a0)
		bne.s	.no_rev					; branch if not reversed
		neg.w	d0
		addi.w	#$40,d0					; reverse d0
		
	.no_rev:
		move.w	d0,d1
		lsr.w	#1,d1
		add.w	d1,d0					; d0 = 0-$60
		move.w	ost_y_pos(a1),d1
		subi.w	#$30,d1
		add.w	d0,d1
		move.w	d1,ost_y_pos(a0)
		bra.w	DespawnQuick
		
	.short_block:
		move.w	ost_y_pos(a1),d1
		subi.w	#$20,d1
		add.w	d0,d1
		move.w	d1,ost_y_pos(a0)
		bra.w	DespawnQuick
