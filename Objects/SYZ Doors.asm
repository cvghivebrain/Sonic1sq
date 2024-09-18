; ---------------------------------------------------------------------------
; Doors/blocks that move when a button is pressed (SYZ)

; spawned by:
;	ObjPos_SYZ1, ObjPos_SYZ3

; subtypes:
;	%FTTTBBBB
;	F - 1 for far-right moving block in its final position
;	TTT - type (0-7; see YDoor_Types)
;	BBBB - button id
; ---------------------------------------------------------------------------

YardDoor:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	YDoor_Index(pc,d0.w),d1
		jmp	YDoor_Index(pc,d1.w)
; ===========================================================================
YDoor_Index:	index *,,2
		ptr YDoor_Main
		ptr YDoor_WaitBtn
		ptr YDoor_Up
		ptr YDoor_Down
		ptr YDoor_Left
		ptr YDoor_Right
		ptr YDoor_FarRight
		ptr YDoor_Stop

		rsobj YardDoor
ost_ydoor_distance:	rs.w 1					; distance moved
ost_ydoor_x_start:	rs.w 1					; original x position
ost_ydoor_btn_num:	rs.b 1					; which button the block is linked to
ost_ydoor_routine:	rs.b 1					; routine to run after button is pressed
		rsobjend

YDoor_Types:	dc.b  $10, $10, id_frame_fblock_syz1x1, id_YDoor_Up ; height, width, frame, routine
		dc.b  $20, $20, id_frame_fblock_syz2x2, id_YDoor_Up
		dc.b  $10, $20, id_frame_fblock_syz1x2, id_YDoor_Up
		dc.b  $20, $1A, id_frame_fblock_syzrect2x2, id_YDoor_FarRight
		dc.b  $10, $27, id_frame_fblock_syzrect1x3, id_YDoor_Up
		even
; ===========================================================================

YDoor_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto YDoor_WaitBtn next
		move.l	#Map_FBlock,ost_mappings(a0)
		move.w	#0+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_3,ost_priority(a0)
		move.w	ost_x_pos(a0),ost_ydoor_x_start(a0)
		move.b	ost_subtype(a0),d0			; get subtype
		move.b	d0,d2
		lsr.w	#4,d0
		andi.w	#7,d0					; read only bits 4-6 of subtype
		add.w	d0,d0
		add.w	d0,d0					; multiply by 4
		lea	YDoor_Types(pc,d0.w),a2			; get size data
		move.b	(a2),ost_width(a0)
		move.b	(a2)+,ost_displaywidth(a0)
		move.b	(a2)+,ost_height(a0)
		move.b	(a2)+,ost_frame(a0)
		move.b	(a2)+,ost_ydoor_routine(a0)
		andi.b	#$F,d2					; read only low nybble of subtype
		move.b	d2,ost_ydoor_btn_num(a0)

YDoor_WaitBtn:	; Routine 2
		tst.b	ost_subtype(a0)
		bmi.s	.chk_stopped				; branch if bit 7 of subtype is set
		cmpi.b	#id_YDoor_FarRight,ost_ydoor_routine(a0)
		bne.s	.allow_respawn				; branch if not the block that moves far right
		tst.b	(v_syzdoor_status).w
		bne.w	DeleteObject				; branch if block is already moving/has moved
		
	.allow_respawn:
		lea	(v_button_state).w,a2
		moveq	#0,d0
		move.b	ost_ydoor_btn_num(a0),d0
		btst	#0,(a2,d0.w)				; check status of linked button
		beq.s	.not_pressed				; branch if not pressed
		move.b	ost_ydoor_routine(a0),ost_routine(a0)	; goto specified routine next
		
	.not_pressed:
		bsr.w	SolidObject
		bra.w	DespawnQuick
		
	.chk_stopped:
		cmpi.b	#2,(v_syzdoor_status).w
		beq.w	YDoor_StopNow				; branch if block is in final position
		bra.w	DeleteObject
; ===========================================================================

YDoor_Up:	; Routine 4
		subq.w	#2,ost_y_pos(a0)			; move up 2px
		addq.b	#1,ost_ydoor_distance(a0)
		move.b	ost_height(a0),d0
		cmp.b	ost_ydoor_distance(a0),d0
		beq.w	YDoor_StopNow				; branch if fully moved
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================

YDoor_Down:	; Routine 6
		addq.w	#2,ost_y_pos(a0)			; move down 2px
		addq.b	#1,ost_ydoor_distance(a0)
		move.b	ost_height(a0),d0
		cmp.b	ost_ydoor_distance(a0),d0
		beq.w	YDoor_StopNow				; branch if fully moved
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================

YDoor_Left:	; Routine 8
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		subq.w	#2,ost_x_pos(a0)			; move left 2px
		addq.b	#1,ost_ydoor_distance(a0)
		move.b	ost_width(a0),d0
		cmp.b	ost_ydoor_distance(a0),d0
		beq.s	YDoor_StopNow				; branch if fully moved
		bsr.w	SolidObject
		move.w	ost_ydoor_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

YDoor_Right:	; Routine $A
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		addq.w	#2,ost_x_pos(a0)			; move right 2px
		addq.b	#1,ost_ydoor_distance(a0)
		move.b	ost_width(a0),d0
		cmp.b	ost_ydoor_distance(a0),d0
		beq.s	YDoor_StopNow				; branch if fully moved
		bsr.w	SolidObject
		move.w	ost_ydoor_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

YDoor_FarRight:	; Routine $C
		move.b	#1,(v_syzdoor_status).w
		shortcut
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		addq.w	#1,ost_x_pos(a0)			; move right 1px
		addq.w	#1,ost_ydoor_distance(a0)
		cmpi.w	#$380,ost_ydoor_distance(a0)
		beq.s	.stop_now				; branch if fully moved
		bsr.w	SolidObject
		bra.w	DisplaySprite				; don't despawn until it stops
		
	.stop_now:
		move.b	#2,(v_syzdoor_status).w
		shortcut					; always return to this location
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================

YDoor_StopNow:
		move.b	#id_YDoor_Stop,ost_routine(a0)		; goto YDoor_Stop next

YDoor_Stop:	; Routine $E
		shortcut
		bsr.w	SolidObject
		move.w	ost_ydoor_x_start(a0),d0
		bra.w	DespawnQuick_AltX
