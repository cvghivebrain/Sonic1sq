; ---------------------------------------------------------------------------
; Half-height platform blocks (LZ)

; spawned by:
;	ObjPos_LZ1 - subtype 2
;	ObjPos_SBZ3 - subtype $10

; subtypes:
;	%000VBBBB
;	V - 1 if visible from start (buttons have no effect)
;	BBBB - id of linked button
; ---------------------------------------------------------------------------

HalfBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	HBlock_Index(pc,d0.w),d1
		jmp	HBlock_Index(pc,d1.w)
; ===========================================================================
HBlock_Index:	index *,,2
		ptr HBlock_Main
		ptr HBlock_ChkBtn
		ptr HBlock_Solid
		ptr HBlock_Move
		ptr HBlock_Drop
		ptr HBlock_Stop
; ===========================================================================

HBlock_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto HBlock_ChkBtn next
		move.l	#Map_MBlockLZ,ost_mappings(a0)
		move.w	#tile_Kos_LzHalfBlock+tile_pal3,ost_tile(a0)
		move.b	#16,ost_displaywidth(a0)
		move.b	#16,ost_width(a0)
		move.b	#8,ost_height(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_4,ost_priority(a0)
		btst	#4,ost_subtype(a0)
		beq.s	HBlock_ChkBtn				; branch if subtype isn't +$10
		addq.b	#2,ost_routine(a0)			; goto HBlock_Solid next
		rts
; ===========================================================================

HBlock_ChkBtn:	; Routine 2
		lea	(v_button_state).w,a2
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0					; read low nybble of subtype
		tst.b	(a2,d0.w)				; read button status
		beq.w	DespawnQuick_NoDisplay			; branch if button isn't pressed
		addq.b	#2,ost_routine(a0)			; goto HBlock_Solid next
		bra.w	DespawnQuick_NoDisplay
; ===========================================================================

HBlock_Solid:	; Routine 4
		bsr.w	SolidObject_TopOnly
		andi.b	#solid_top,d1
		beq.w	DespawnQuick				; branch if no top collision
		addq.b	#2,ost_routine(a0)			; goto HBlock_Move next
		bra.w	DespawnQuick
; ===========================================================================

HBlock_Move:	; Routine 6
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noxflip				; branch if not xflipped
		subq.w	#1,ost_x_pos(a0)			; move 1px left
		bsr.w	SolidObject_TopOnly
		bsr.w	FindWallLeftObj
		tst.w	d1
		bmi.s	.hit_wall				; branch if block hits wall
		bra.w	DespawnQuick
		
	.noxflip:
		addq.w	#1,ost_x_pos(a0)			; move 1px right
		bsr.w	SolidObject_TopOnly
		bsr.w	FindWallRightObj
		tst.w	d1
		bmi.s	.hit_wall				; branch if block hits wall
		bra.w	DespawnQuick
		
	.hit_wall:
		addq.b	#2,ost_routine(a0)			; goto HBlock_Drop next
		bra.w	DespawnQuick
; ===========================================================================

HBlock_Drop:	; Routine 8
		update_y_fall	$18				; update position & apply gravity
		bsr.w	SolidObject_TopOnly
		getpos_bottom					; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		bsr.w	FloorDist
		tst.w	d5					; has platform hit the floor?
		bpl.w	DespawnQuick				; if not, branch
		add.w	d5,ost_y_pos(a0)			; align to floor
		clr.w	ost_y_vel(a0)				; stop platform	falling
		addq.b	#2,ost_routine(a0)			; goto HBlock_Stop next
		bra.w	DespawnQuick
; ===========================================================================

HBlock_Stop:	; Routine $A
		shortcut
		bsr.w	SolidObject_TopOnly
		bra.w	DespawnQuick
		
