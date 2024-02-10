; ---------------------------------------------------------------------------
; Horizontal door (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3, ObjPos_SBZ3
; ---------------------------------------------------------------------------

LabyrinthDoorH:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	DoorH_Index(pc,d0.w),d1
		jmp	DoorH_Index(pc,d1.w)
; ===========================================================================
DoorH_Index:	index *,,2
		ptr DoorH_Main
		ptr DoorH_Solid
		ptr DoorH_ChkBtn
		ptr DoorH_Move

		rsobj LabyrinthDoorH
ost_doorh_x_start:	rs.w 1					; initial x pos
ost_doorh_x_open:	rs.w 1					; open x pos
		rsobjend
; ===========================================================================

DoorH_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto DoorH_Solid next
		move.l	#Map_DoorH,ost_mappings(a0)
		move.w	#tile_Kos_LzDoorH+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_3,ost_priority(a0)
		move.b	#64,ost_displaywidth(a0)
		move.b	#64,ost_width(a0)
		move.b	#16,ost_height(a0)
		move.w	ost_x_pos(a0),ost_doorh_x_start(a0)
		move.w	#128,d1

		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip				; branch if not xflipped
		addi.w	#128,ost_x_pos(a0)			; move into open position
		move.w	#-128,d1

	.no_xflip:
		bsr.w	GetState
		bne.s	DoorH_Solid				; branch if already opened
		move.w	ost_x_pos(a0),ost_doorh_x_open(a0)	; copy open position
		add.w	d1,ost_x_pos(a0)			; move into closed position
		addq.b	#2,ost_routine(a0)			; goto DoorH_ChkBtn next

DoorH_Solid:	; Routine 2
		bsr.w	SolidObject
		move.w	ost_doorh_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

DoorH_ChkBtn:	; Routine 4
		lea	(v_button_state).w,a2
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		tst.b	(a2,d0.w)				; check state of linked button
		beq.s	DoorH_Solid				; branch if button isn't pressed
		bsr.w	SaveState
		beq.s	.not_found				; branch if not in respawn table
		bset	#0,(a2)					; remember door state

	.not_found:
		addq.b	#2,ost_routine(a0)			; goto DoorH_Move next

DoorH_Move:	; Routine 6
		move.w	ost_x_pos(a0),d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip				; branch if not xflipped
		cmp.w	ost_doorh_x_open(a0),d0
		bge.s	.fully_open				; branch if door is fully open
		addq.w	#2,d0					; move right 2px
		move.w	d0,ost_x_pos(a0)			; update x pos
		bra.s	DoorH_Solid

	.no_xflip:
		cmp.w	ost_doorh_x_open(a0),d0
		ble.s	.fully_open				; branch if door is fully open
		subq.w	#2,d0					; move left 2px
		move.w	d0,ost_x_pos(a0)			; update x pos
		bra.s	DoorH_Solid

	.fully_open:
		move.b	#id_DoorH_Solid,ost_routine(a0)		; goto DoorH_Solid next
		bra.s	DoorH_Solid

