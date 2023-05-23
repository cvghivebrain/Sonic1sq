; ---------------------------------------------------------------------------
; Spawner for platforms on a conveyor belt (LZ)

; spawned by:
;	ObjPos_LZ1 - subtypes 0/1
;	ObjPos_LZ2 - subtypes 2/3
;	ObjPos_LZ3 - subtypes 4/5
; ---------------------------------------------------------------------------

LabyrinthConvey:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	LCon_Index(pc,d0.w),d1
		jmp	LCon_Index(pc,d1.w)
; ===========================================================================
LCon_Index:	index *,,2
		ptr LCon_Main
		ptr LCon_ChkDist
; ===========================================================================

LCon_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto LCon_ChkDist next
		move.b	ost_subtype(a0),d0
		add.w	d0,d0
		add.w	d0,d0
		lea	(ObjPosLZPlatform_Index).l,a2
		movea.l	(a2,d0.w),a2				; get address of platform position data
		move.w	(a2)+,d1				; get object count

	.loop:
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#LabyrinthConveyPlatform,ost_id(a1)	; load platform object
		move.w	(a2)+,ost_x_pos(a1)
		move.w	(a2)+,ost_y_pos(a1)
		move.w	(a2)+,d0
		move.b	d0,ost_subtype(a1)
		saveparent
		dbf	d1,.loop				; repeat for number of objects

	.fail:
		rts
; ===========================================================================

LCon_ChkDist:	; Routine 2
		shortcut
		getsonic
		range_x
		cmpi.w	#512,d1
		bcs.s	.exit					; branch if Sonic is < 512px away
		moveq	#0,d0
		move.b	ost_respawn(a0),d0			; get respawn id
		beq.w	DeleteFamily				; branch if not set
		lea	(v_respawn_list).w,a2
		bclr	#7,2(a2,d0.w)				; allow object to respawn later
		bra.w	DeleteFamily				; delete the object and all platforms
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Object 63 - platforms on a conveyor belt (LZ)

; spawned by:
;	LabyrinthConvey - subtypes 0-$53
; ---------------------------------------------------------------------------

LabyrinthConveyPlatform:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	LConP_Index(pc,d0.w),d1
		jmp	LConP_Index(pc,d1.w)
; ===========================================================================
LConP_Index:	index *,,2
		ptr LConP_Main
		ptr LConP_Platform

		rsobj LabyrinthConveyPlatform
ost_lcon_corner_ptr:	rs.l 1					; address of corner position data (4 bytes)
ost_lcon_corner_x_pos:	rs.w 1					; x position of next corner (2 bytes)
ost_lcon_corner_y_pos:	rs.w 1					; y position of next corner (2 bytes)
ost_lcon_corner_next:	rs.b 1					; index of next corner
ost_lcon_corner_count:	rs.b 1					; total number of corners *8
		rsobjend
; ===========================================================================

LConP_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto LConP_Platform next
		move.l	#Map_LConv,ost_mappings(a0)
		move.w	#tile_Kos_LzWheel+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#$10,ost_width(a0)
		move.b	#8,ost_height(a0)
		move.b	#4,ost_priority(a0)
		move.b	#id_frame_lcon_platform,ost_frame(a0)	; use platform sprite
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype (not the same as initial subtype)
		move.w	d0,d1
		lsr.w	#3,d0
		andi.w	#$1E,d0					; read high nybble of subtype
		lea	LCon_Corner_Data(pc),a2
		adda.w	(a2,d0.w),a2				; get address of corner data
		move.w	(a2)+,d0
		move.b	d0,ost_lcon_corner_count(a0)		; get corner count
		move.l	a2,ost_lcon_corner_ptr(a0)		; pointer to corner x/y values
		andi.w	#$F,d1					; read low nybble of subtype
		lsl.w	#3,d1					; multiply by 8
		move.b	d1,ost_lcon_corner_next(a0)
		lea	(a2,d1.w),a2
		move.w	(a2)+,ost_lcon_corner_x_pos(a0)		; get corner position data
		move.w	(a2)+,ost_lcon_corner_y_pos(a0)
		move.w	(a2)+,ost_x_vel(a0)			; set initial speed
		move.w	(a2)+,ost_y_vel(a0)
		bra.s	LConP_ChkCorner				; don't start moving until corners are checked

LConP_Platform:	; Routine 2
		shortcut
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		update_xy_pos
		
LConP_ChkCorner:
		move.w	ost_lcon_corner_x_pos(a0),d0
		cmp.w	ost_x_pos(a0),d0
		bne.s	.continue_x				; branch if not at corner on x
		clr.w	ost_x_vel(a0)				; stop moving x
		
	.continue_x:
		move.w	ost_lcon_corner_y_pos(a0),d0
		cmp.w	ost_y_pos(a0),d0
		bne.s	.continue_y				; branch if not at corner on y
		clr.w	ost_y_vel(a0)				; stop moving y
		
	.continue_y:
		tst.l	ost_x_vel(a0)
		beq.s	LConP_NextCorner			; branch if at corner
		bsr.w	SolidObject_TopOnly
		bra.w	DisplaySprite
; ===========================================================================
		
LConP_NextCorner:
		moveq	#0,d0
		move.b	ost_lcon_corner_next(a0),d0
		addq.b	#8,d0
		cmp.b	ost_lcon_corner_count(a0),d0
		bne.s	.corner_valid				; branch if corner exists
		moveq	#0,d0					; reset to 0
		
	.corner_valid:
		move.b	d0,ost_lcon_corner_next(a0)
		movea.l	ost_lcon_corner_ptr(a0),a2		; get pointer to corner data
		lea	(a2,d0.w),a2				; jump to relevant corner
		move.w	(a2)+,ost_lcon_corner_x_pos(a0)		; get corner position data
		move.w	(a2)+,ost_lcon_corner_y_pos(a0)
		move.w	(a2)+,ost_x_vel(a0)			; set speed
		move.w	(a2)+,ost_y_vel(a0)
		bsr.w	SolidObject_TopOnly
		bra.w	DisplaySprite
; ===========================================================================

LCon_Corner_Data:
		index *
		ptr LCon_Corners_0
		ptr LCon_Corners_1
		ptr LCon_Corners_2
		ptr LCon_Corners_3
		ptr LCon_Corners_4
		ptr LCon_Corners_5
LCon_Corners_0:	dc.w .end-(*+2)					; act 1
		; x pos, y pos, x vel, y vel (max $100 to avoid overshoot)
		dc.w $1078, $21A, $100, -$7D
		dc.w $10BE, $260, $100, $100
		dc.w $10BE, $393, 0, $100
		dc.w $108C, $3C5, -$100, $100
		dc.w $1022, $390, -$100, -$80
		dc.w $1022, $244, 0, -$100
	.end:

LCon_Corners_1:	dc.w .end-(*+2)					; act 1
		dc.w $127E, $280, $100, -$100
		dc.w $12CE, $2D0, $100, $100
		dc.w $12CE, $46E, 0, $100
		dc.w $1232, $420, -$100, -$80
		dc.w $1232, $2CC, 0, -$100
	.end:

LCon_Corners_2:	dc.w .end-(*+2)					; act 2
		dc.w $D22, $482, -$100, 0
		dc.w $D22, $5DE, 0, $100
		dc.w $DAE, $5DE, $100, 0
		dc.w $DAE, $482, 0, -$100
	.end:

LCon_Corners_3:	dc.w .end-(*+2)					; act 2
		dc.w $D62, $3A2, 0, -$100
		dc.w $DEE, $3A2, $100, 0
		dc.w $DEE, $4DE, 0, $100
		dc.w $D62, $4DE, -$100, 0
	.end:

LCon_Corners_4:	dc.w .end-(*+2)					; act 3
		dc.w $CAC, $242, $100, -$100
		dc.w $DDE, $242, $100, 0
		dc.w $DDE, $3DE, 0, $100
		dc.w $C52, $3DE, -$100, 0
		dc.w $C52, $29C, 0, -$100
	.end:

LCon_Corners_5:	dc.w .end-(*+2)					; act 3
		dc.w $1252, $20A, 0, -$100
		dc.w $13DE, $20A, $100, 0
		dc.w $13DE, $2BE, 0, $100
		dc.w $1252, $2BE, -$100, 0
	.end:
