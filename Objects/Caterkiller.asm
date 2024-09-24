; ---------------------------------------------------------------------------
; Object 78 - Caterkiller enemy	(MZ, SBZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3
;	ObjPos_SBZ1, ObjPos_SBZ2
;	Caterkiller - routine 4 (body segments)
; ---------------------------------------------------------------------------

Caterkiller:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Cat_Index(pc,d0.w),d1
		jmp	Cat_Index(pc,d1.w)
; ===========================================================================
Cat_Index:	index *,,2
		ptr Cat_Main
		ptr Cat_Head
		ptr Cat_Segment

		rsobj Caterkiller
ost_cat_y_start:	rs.w 1					; y position of object when aligned to floor
ost_cat_x_edge:		rs.w 1					; x position of ledge/wall recently encountered by head
ost_cat_wait_time:	rs.b 1					; time to wait between actions
ost_cat_counter:	rs.b 1					; frame counter when rising or falling
ost_cat_turned:		equ ost_cat_counter			; flag set when segment has recently changed direction
		rsobjend
		
cat_height:	equ 7
; ===========================================================================

Cat_Deleted:
		rts	
; ===========================================================================

Cat_Main:	; Routine 0
		move.b	#cat_height,ost_height(a0)
		move.b	#8,ost_width(a0)
		bsr.w	SnapFloor				; align to floor
		beq.s	Cat_Deleted				; branch if floor not found
		move.w	ost_y_pos(a0),ost_cat_y_start(a0)
		clr.w	ost_y_vel(a0)
		addq.b	#2,ost_routine(a0)			; goto Cat_Head next
		move.l	#Map_Cat,ost_mappings(a0)
		move.w	(v_tile_caterkiller).w,ost_tile(a0)
		addi.w	#tile_pal2,ost_tile(a0)
		move.b	ost_status(a0),ost_render(a0)
		ori.b	#render_rel,ost_render(a0)
		move.w	#priority_4,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#StrId_Caterkiller,ost_name(a0)
		move.b	#id_React_Caterkiller,ost_col_type(a0)
		move.b	#8,ost_col_width(a0)
		move.b	#8,ost_col_height(a0)
		move.w	#-$C0,ost_x_vel(a0)
		move.b	#id_frame_cat_mouth1,ost_frame(a0)
		
		move.w	ost_x_pos(a0),d2			; head x position
		moveq	#12,d4					; distance between segments (12px)
		btst	#status_xflip_bit,ost_render(a0)
		beq.s	.noflip
		neg.w	d4					; negative if xflipped
		neg.w	ost_x_vel(a0)

	.noflip:
		moveq	#3-1,d1					; 3 body segments
		moveq	#0,d3

	.loop:
		jsr	FindNextFreeObj
		bne.s	Cat_Head
		move.l	#Caterkiller,ost_id(a1)			; load body segment object
		move.b	#id_Cat_Segment,ost_routine(a1)		; goto Cat_Segment next
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.w	#priority_5,ost_priority(a1)
		move.b	#8,ost_displaywidth(a1)
		move.b	#StrId_CaterSegment,ost_name(a1)
		move.b	#cat_height,ost_height(a1)
		move.b	#8,ost_width(a1)
		move.b	#id_React_Hurt,ost_col_type(a1)
		move.b	#8,ost_col_width(a1)
		move.b	#8,ost_col_height(a1)
		add.w	d4,d2
		move.w	d2,ost_x_pos(a1)			; body segment x pos = previous segment x pos +12
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	ost_status(a0),ost_status(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	#id_frame_cat_body1,ost_frame(a1)
		move.b	d3,ost_subtype(a1)
		addq.b	#2,d3
		saveparent
		dbf	d1,.loop				; repeat sequence 2 more times

Cat_Head:	; Routine 2
		shortcut
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		move.w	Cat_Head_Index(pc,d0.w),d1
		jmp	Cat_Head_Index(pc,d1.w)
; ===========================================================================
Cat_Head_Index:	index *,,2
		ptr Cat_Rise
		ptr Cat_Wait
		ptr Cat_Drop
		ptr Cat_Wait2
		ptr Cat_Split
; ===========================================================================

Cat_Rise:
		moveq	#0,d1
		move.b	ost_cat_counter(a0),d0
		move.b	Cat_Rise_Dist(pc,d0.w),d1		; get distance to move up
		move.b	#cat_height,ost_height(a0)
		add.b	d1,ost_height(a0)			; set height to match current state
		neg.w	d1
		add.w	ost_cat_y_start(a0),d1			; subtract from initial y pos
		move.w	d1,ost_y_pos(a0)			; update actual y pos
		addq.b	#1,d0					; increment counter
		cmpi.w	#Cat_Rise_Dist_size-Cat_Rise_Dist,d0
		bne.s	.update_counter				; branch if not at max
		moveq	#0,d0					; reset counter to 0
		addq.b	#2,ost_mode(a0)				; goto Cat_Wait next
		move.b	#7,ost_cat_wait_time(a0)
		
	.update_counter:
		move.b	d0,ost_cat_counter(a0)
		bra.w	DespawnFamily
		
Cat_Rise_Dist:	dc.b 0, 0, 0, 0, 1, 1, 2, 3, 4, 4, 5, 6, 6, 7, 7, 7
	Cat_Rise_Dist_size:
		even
; ===========================================================================

Cat_Wait:
		subq.b	#1,ost_cat_wait_time(a0)		; decrement timer
		bpl.w	DespawnFamily				; branch if time remains
		addq.b	#2,ost_mode(a0)				; goto Cat_Drop next
		move.b	#id_frame_cat_head1,ost_frame(a0)
		bra.w	DespawnFamily
; ===========================================================================

Cat_Drop:
		move.b	ost_cat_counter(a0),d0
		move.b	Cat_Heights(pc,d0.w),ost_height(a0)	; get height
		addq.b	#1,d0					; increment counter
		cmpi.w	#Cat_Heights_size-Cat_Heights,d0
		bne.s	.update_counter				; branch if not at max
		moveq	#0,d0					; reset counter to 0
		addq.b	#2,ost_mode(a0)				; goto Cat_Wait2 next
		move.b	#7,ost_cat_wait_time(a0)
		
	.update_counter:
		move.b	d0,ost_cat_counter(a0)
		update_x_pos
		getpos_bottom					; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		bsr.w	FloorDist
		cmpi.w	#-8,d5
		blt.s	.turn_around				; branch if > 8px below floor
		cmpi.w	#$C,d5
		bge.s	.turn_around				; branch if > 11px above floor (also detects a ledge)
		add.w	d5,ost_y_pos(a0)			; align to floor
		bra.w	DespawnFamily
		
	.turn_around:
		neg.w	ost_x_vel(a0)				; reverse direction
		neg.w	ost_x_sub(a0)
		bchg	#render_xflip_bit,ost_render(a0)	; xflip sprite
		move.w	ost_x_pos(a0),ost_cat_x_edge(a0)	; save x pos of ledge/wall
		bra.w	DespawnFamily
		
Cat_Heights:	dc.b cat_height+7, cat_height+7, cat_height+7, cat_height+6, cat_height+6, cat_height+5, cat_height+4, cat_height+4
		dc.b cat_height+3, cat_height+2, cat_height+1, cat_height+1, cat_height+0, cat_height+0, cat_height+0, cat_height+0
	Cat_Heights_size:
		even
; ===========================================================================

Cat_Wait2:
		subq.b	#1,ost_cat_wait_time(a0)		; decrement timer
		bpl.w	DespawnFamily				; branch if time remains
		move.b	#0,ost_mode(a0)				; goto Cat_Rise next
		move.b	#id_frame_cat_mouth1,ost_frame(a0)
		move.w	ost_y_pos(a0),ost_cat_y_start(a0)
		bra.w	DespawnFamily
; ===========================================================================

Cat_Split:
		move.l	#Cat_Fragment,ost_id(a0)		; change object to bouncing fragment
		move.b	#cat_height,ost_height(a0)
		move.w	#-$200,d0
		btst	#status_xflip_bit,ost_render(a0)
		beq.s	.no_xflip
		neg.w	d0					; reverse if xflipped

	.no_xflip:
		move.w	d0,ost_x_vel(a0)			; set x speed
		move.w	#-$400,ost_y_vel(a0)
		move.b	#id_React_Hurt,ost_col_type(a0)
		jmp	DisplaySprite
; ===========================================================================

Cat_Segment:	; Routine 4
		shortcut
		getparent					; a1 = OST of parent caterkiller
		moveq	#0,d0
		move.b	ost_mode(a1),d0
		move.w	Cat_Seg_Index(pc,d0.w),d1
		jmp	Cat_Seg_Index(pc,d1.w)
; ===========================================================================
Cat_Seg_Index:	index *,,2
		ptr Cat_Seg_Move
		ptr Cat_Seg_Wait
		ptr Cat_Seg_Move
		ptr Cat_Seg_Wait2
		ptr Cat_Seg_Split
; ===========================================================================

Cat_Seg_Move:
		add.b	d0,d0					; d0 = 0 or 8
		add.b	ost_subtype(a0),d0
		move.w	Cat_Speeds(pc,d0.w),d0			; get x speed for current segment
		btst	#render_xflip_bit,ost_render(a0)
		beq.s	.moving_left				; branch if segment is moving left
		neg.w	d0					; reverse direction
		
	.moving_left:
		move.w	d0,ost_x_vel(a0)			; update x speed
		update_x_pos
		tst.b	ost_cat_turned(a0)
		bne.s	.skip_edge_chk				; branch if segment has already turned
		move.w	ost_x_pos(a0),d0
		cmp.w	ost_cat_x_edge(a1),d0
		beq.s	.turn_around				; branch if segment is at ledge/wall
		
	.skip_edge_chk:
		cmpi.b	#2,ost_subtype(a0)
		bne.s	.not_middle_seg				; branch if not the middle segment
		move.b	ost_height(a1),ost_height(a0)		; copy height from head
		
	.not_middle_seg:
		getpos_bottom					; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		bsr.w	FloorDist
		cmpi.w	#-8,d5
		blt.s	.skip_floor				; branch if > 8px below floor
		cmpi.w	#$C,d5
		bge.s	.skip_floor				; branch if > 11px above floor (also detects a ledge)
		add.w	d5,ost_y_pos(a0)			; align to floor
		
	.skip_floor:
		jmp	DisplaySprite
		
	.turn_around:
		bchg	#render_xflip_bit,ost_render(a0)	; xflip sprite
		neg.w	ost_x_sub(a0)
		move.b	#1,ost_cat_turned(a0)			; don't turn again
		jmp	DisplaySprite
		
Cat_Speeds:	dc.w -$40, -$80, -$C0, 0
		dc.w -$80, -$40, 0
; ===========================================================================
		
Cat_Seg_Wait2:
		cmpi.b	#6,ost_cat_wait_time(a1)
		bne.s	Cat_Seg_Wait				; branch if not on a particular frame
		move.b	ost_render(a1),d0
		andi.b	#render_xflip,d0
		move.b	ost_render(a0),d1
		andi.b	#render_xflip,d1
		eor.b	d0,d1
		bne.s	Cat_Seg_Wait				; branch if head & segment are facing different directions
		moveq	#0,d1
		move.b	ost_subtype(a0),d1
		add.w	d1,d1
		move.w	d1,d2
		add.w	d1,d1
		add.w	d2,d1					; d1 = subtype * 6
		addi.w	#12,d1					; fixed x dist between segments
		tst.b	d0
		beq.s	.noflip					; branch if not facing left
		neg.w	d1
		
	.noflip:
		add.w	ost_x_pos(a1),d1
		move.w	d1,ost_x_pos(a0)			; reset x pos to match head (prevents desync)
		
Cat_Seg_Wait:
		clr.b	ost_cat_turned(a0)
		jmp	DisplaySprite
; ===========================================================================

Cat_Seg_Split:
		move.l	#Cat_Fragment,ost_id(a0)		; change object to bouncing fragment
		move.b	#cat_height,ost_height(a0)
		move.b	ost_subtype(a0),d0
		move.w	Cat_FragSpeed(pc,d0.w),d0		; get x speed from list
		btst	#status_xflip_bit,ost_render(a1)
		beq.s	.no_xflip
		neg.w	d0					; reverse if xflipped

	.no_xflip:
		move.w	d0,ost_x_vel(a0)			; set x speed
		move.w	#-$400,ost_y_vel(a0)
		jmp	DisplaySprite

Cat_FragSpeed:	dc.w -$180, $180, $200				; segment x speed

; ---------------------------------------------------------------------------
; Bouncing Caterkiller fragment

; spawned by:
;	Caterkiller
; ---------------------------------------------------------------------------

Cat_Fragment:
		update_xy_fall					; apply gravity & update position
		bmi.s	.nocollide				; branch if moving upwards
		getpos_bottom cat_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		bsr.w	FloorDist
		tst.w	d5					; has object hit floor?
		bpl.s	.nocollide				; if not, branch
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.w	#-$400,ost_y_vel(a0)			; bounce

	.nocollide:
		tst.b	ost_render(a0)				; is object on-screen?
		jpl	DeleteObject				; if not, branch
		jmp	(DisplaySprite).l
