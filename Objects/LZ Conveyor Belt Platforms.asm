; ---------------------------------------------------------------------------
; Spawner for platforms on a conveyor belt (LZ)

; spawned by:
;	ObjPos_LZ1 - subtypes 0/1
;	ObjPos_LZ2 - subtypes 2/3
;	ObjPos_LZ3 - subtypes 4/$E5

; subtypes:
;	%BBBBCCCC
;	BBBB - button id that reverses the conveyor (0 does nothing)
;	CCCC - corner data id
; ---------------------------------------------------------------------------

LabyrinthConvey:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	LCon_Index(pc,d0.w),d1
		jmp	LCon_Index(pc,d1.w)
; ===========================================================================
LCon_Index:	index *,,2
		ptr LCon_Main
		ptr LCon_Action

		rsobj LabyrinthConvey
ost_lcon_platform_ptr:	rs.l 1					; pointer to platform list data
ost_lcon_visible_left:	equ ost_sink				; visible left limit of camera x pos
ost_lcon_visible_right:	rs.w 1					; visible right limit of camera x pos
ost_lcon_visible_top:	rs.w 1					; visible upper limit of camera y pos
ost_lcon_visible_btm:	rs.w 1					; visible lower limit of camera y pos
ost_lcon_visible_flag:	rs.b 1					; flag set when conveyor is visible
ost_lcon_button:	rs.b 1					; button id that controls reverse direction
		rsobjend
; ===========================================================================

LCon_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto LCon_Action next
		move.b	ost_subtype(a0),d0
		move.b	d0,d1
		andi.b	#$F,d0					; read low nybble of subtype
		lsr.b	#4,d1
		move.b	d1,ost_lcon_button(a0)			; save high nybble as button id
		add.w	d0,d0
		add.w	d0,d0
		lea	(ObjPosLZPlatform_Index).l,a2
		movea.l	(a2,d0.w),a2				; get address of platform position data
		move.l	a2,ost_lcon_platform_ptr(a0)
		add.w	d0,d0
		lea	(LCon_Edge_Data).l,a2			; get edge data
		lea	(a2,d0.w),a2
		move.w	(a2)+,ost_lcon_visible_left(a0)		; set limits of visibility
		move.w	(a2)+,ost_lcon_visible_right(a0)
		move.w	(a2)+,ost_lcon_visible_top(a0)
		move.w	(a2)+,ost_lcon_visible_btm(a0)
		rts
; ===========================================================================

LCon_Action:	; Routine 2
		shortcut
		moveq	#0,d0
		move.b	ost_lcon_button(a0),d0
		beq.s	.no_button				; branch if subtype is 0
		lea	(v_button_state).w,a2
		tst.b	(a2,d0.w)				; check state of linked button
		beq.s	.no_button				; branch if button isn't pressed
		move.b	#1,(f_convey_reverse).w			; set global reverse flag
		move.b	#2,ost_mode(a0)				; set local reverse flag
		
	.no_button:
		move.w	(v_camera_x_pos).w,d0
		cmp.w	ost_lcon_visible_left(a0),d0
		bcs.s	.not_visible				; branch if camera is too far left
		cmp.w	ost_lcon_visible_right(a0),d0
		bhi.s	.not_visible				; branch if camera is too far right
		move.w	(v_camera_y_pos).w,d0
		cmp.w	ost_lcon_visible_top(a0),d0
		bcs.s	.not_visible				; branch if camera is above
		cmp.w	ost_lcon_visible_btm(a0),d0
		bhi.s	.not_visible				; branch if camera is below
		tst.b	ost_lcon_visible_flag(a0)
		bne.s	.exit					; branch if already visible
		
		move.b	#1,ost_lcon_visible_flag(a0)		; set flag
		movea.l	ost_lcon_platform_ptr(a0),a2		; get pointer to platform position data
		move.w	(a2)+,d1				; get object count

	.loop:
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	.exit					; branch if not found
		move.l	#LabyrinthConveyPlatform,ost_id(a1)	; load platform object
		move.w	(a2)+,ost_x_pos(a1)
		move.w	(a2)+,ost_y_pos(a1)
		move.w	(a2)+,d0
		move.b	d0,ost_subtype(a1)
		saveparent
		dbf	d1,.loop				; repeat for number of objects
		
	.exit:
		rts
		
	.not_visible:
		tst.b	ost_lcon_visible_flag(a0)
		beq.s	.exit					; branch if already not visible
		clr.b	ost_lcon_visible_flag(a0)		; clear flag
		bra.w	DeleteChildren				; delete platforms

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
ost_lcon_rev_flag:	rs.b 1					; flag set when platform has reversed
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
		move.b	#priority_4,ost_priority(a0)
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
		getparent
		bra.s	LConP_ChkCorner				; don't start moving until corners are checked

LConP_Platform:	; Routine 2
		shortcut
		getparent					; a1 = OST of parent
		tst.b	ost_lcon_rev_flag(a0)
		bne.s	.skip_reverse				; branch if already reversed
		tst.b	ost_mode(a1)
		beq.s	.skip_reverse				; branch if button hasn't been pressed
		move.b	#1,ost_lcon_rev_flag(a0)		; set reverse "done" flag
		neg.w	ost_x_vel(a0)				; go backwards
		neg.w	ost_y_vel(a0)
		bra.w	LConP_RevCorner
		
	.skip_reverse:
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
		tst.b	ost_mode(a1)
		bne.s	LConP_RevCorner				; branch if reverse flag is set
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

LConP_RevCorner:
		moveq	#0,d0
		move.b	ost_lcon_corner_next(a0),d0
		move.w	d0,d1
		addq.b	#4,d1					; d1 = offset for x/y vel of previous corner
		subq.b	#8,d0
		bpl.s	.corner_valid				; branch if corner exists
		add.b	ost_lcon_corner_count(a0),d0		; reset to final corner
		
	.corner_valid:
		move.b	d0,ost_lcon_corner_next(a0)
		movea.l	ost_lcon_corner_ptr(a0),a2		; get pointer to corner data
		lea	(a2,d0.w),a3				; jump to relevant corner
		move.w	(a3)+,ost_lcon_corner_x_pos(a0)		; get corner position data
		move.w	(a3)+,ost_lcon_corner_y_pos(a0)
		lea	(a2,d1.w),a3				; jump to previous corner
		move.w	(a3)+,ost_x_vel(a0)			; set speed
		move.w	(a3)+,ost_y_vel(a0)
		neg.w	ost_x_vel(a0)				; go backwards
		neg.w	ost_y_vel(a0)
		bsr.w	SolidObject_TopOnly
		bra.w	DisplaySprite
; ===========================================================================

LCon_Edge_Data:	; left, right, top, bottom (includes width/height of screen and platforms)
		dc.w $1022-16-screen_width, $10BE+16, $21A-8-screen_height, $3C5+8
		dc.w $1232-16-screen_width, $12CE+16, $280-8-screen_height, $46E+8
		dc.w $D22-16-screen_width, $DAE+16, $482-8-screen_height, $5DE+8
		dc.w $D62-16-screen_width, $DEE+16, $3A2-8-screen_height, $4DE+8
		dc.w $C52-16-screen_width, $DDE+16, $242-8-screen_height, $3DE+8
		dc.w $1252-16-screen_width, $13DE+16, $20A-8-screen_height, $2BE+8

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
