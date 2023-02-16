; ---------------------------------------------------------------------------
; Vertical door (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3, ObjPos_SBZ3
; ---------------------------------------------------------------------------

LabyrinthDoorV:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	DoorV_Index(pc,d0.w),d1
		jmp	DoorV_Index(pc,d1.w)
; ===========================================================================
DoorV_Index:	index *,,2
		ptr DoorV_Main
		ptr DoorV_Solid
		ptr DoorV_ChkBtn
		ptr DoorV_Move
		
		rsobj LabyrinthDoorV
ost_doorv_y_start:	rs.w 1					; initial y pos
		rsobjend
; ===========================================================================

DoorV_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto DoorV_Solid next
		move.l	#Map_DoorV,ost_mappings(a0)
		move.w	#tile_Kos_LzDoorV+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#8,ost_width(a0)
		move.b	#32,ost_height(a0)
		bsr.w	GetState
		bne.s	DoorV_Solid				; branch if already opened
		move.w	ost_y_pos(a0),ost_doorv_y_start(a0)	; copy open position
		add.w	#64,ost_y_pos(a0)			; move into closed position
		addq.b	#2,ost_routine(a0)			; goto DoorV_ChkBtn next

DoorV_Solid:	; Routine 2
		bsr.s	DoorV_ChkTunnel
		bsr.w	SolidObject
		move.w	ost_x_pos(a0),d0
		bsr.w	CheckActive
		bne.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

DoorV_ChkBtn:	; Routine 4
		lea	(v_button_state).w,a2
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		andi.b	#$F,d0					; get low nybble of subtype
		tst.b	(a2,d0.w)				; check state of linked button
		beq.s	DoorV_Solid				; branch if button isn't pressed
		bsr.w	SaveState
		bset	#0,(a2)					; remember door state
		addq.b	#2,ost_routine(a0)			; goto DoorV_Move next

DoorV_Move:	; Routine 6
		move.w	ost_y_pos(a0),d0
		cmp.w	ost_doorv_y_start(a0),d0
		ble.s	.fully_open				; branch if door is fully open
		subi.w	#2,d0					; move up 2px
		move.w	d0,ost_y_pos(a0)			; update y pos
		bra.s	DoorV_Solid
		
	.fully_open:
		move.b	#id_DoorV_Solid,ost_routine(a0)		; goto DoorV_Solid next
		bra.s	DoorV_Solid
; ===========================================================================

DoorV_ChkTunnel:
		tst.b	ost_subtype(a0)
		bpl.s	.exit					; branch if high bit of subtype is 0
		clr.b	(f_water_tunnel_disable).w		; enable water tunnels
		move.w	(v_ost_player+ost_x_pos).w,d0
		cmp.w	ost_x_pos(a0),d0
		bcc.s	.exit					; branch if Sonic is right of the door
		move.b	#1,(f_water_tunnel_disable).w		; disable water tunnels if Sonic is to the left
		
	.exit:
		rts
		