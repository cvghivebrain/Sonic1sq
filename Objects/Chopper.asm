; ---------------------------------------------------------------------------
; Object 2B - Chopper enemy (GHZ)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2

; subtypes:
;	%0000TTTT
;	TTTT - type (see Chop_Types)
; ---------------------------------------------------------------------------

Chopper:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Chop_Index(pc,d0.w),d1
		jmp	Chop_Index(pc,d1.w)
; ===========================================================================
Chop_Index:	index *,,2
		ptr Chop_Main
		ptr Chop_Jump
		ptr Chop_Fall
		ptr Chop_Fall2

		rsobj Chopper
ost_chopper_y_start:	rs.w 1					; original y position
ost_chopper_y_vel:	rs.w 1					; jump speed
		rsobjend
		
Chop_Types:	dc.w $700					; jump speed
; ===========================================================================

Chop_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Chop_Jump next
		move.l	#Map_Chop,ost_mappings(a0)
		move.w	(v_tile_chopper).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#id_React_Enemy,ost_col_type(a0)
		move.b	#12,ost_col_width(a0)
		move.b	#16,ost_col_height(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0					; read low nybble of subtype
		add.w	d0,d0
		move.w	Chop_Types(pc,d0.w),d0			; get jump speed from list
		neg.w	d0
		move.w	d0,ost_chopper_y_vel(a0)
		move.w	d0,ost_y_vel(a0)			; set vertical speed
		move.w	ost_y_pos(a0),ost_chopper_y_start(a0)	; save original position

Chop_Jump:	; Routine 2
		update_y_fall	$18				; update position & apply gravity
		tst.w	ost_y_vel(a0)
		bpl.s	.fall					; branch if falling
		moveq	#3,d1					; use fast animation
		move.w	ost_chopper_y_start(a0),d0
		sub.w	ost_y_pos(a0),d0			; d0 = distance from start
		subi.w	#192,d0
		bcc.s	.above_192				; branch if > 192px above start
		moveq	#7,d1					; use slow animation
		
	.above_192:
		toggleframe	d1				; animate
		bra.w	DespawnObject

	.fall:
		addq.b	#2,ost_routine(a0)			; goto Chop_Fall next
		bra.w	DespawnObject
; ===========================================================================

Chop_Fall:	; Routine 4
		toggleframe	3				; animate
		update_y_fall	$18				; update position & apply gravity
		move.w	ost_chopper_y_start(a0),d0
		sub.w	ost_y_pos(a0),d0
		subi.w	#192,d0
		bcc.w	DespawnObject				; branch if > 192px above start
		
		move.b	#id_frame_chopper_shut,ost_frame(a0)
		addq.b	#2,ost_routine(a0)			; goto Chop_Fall2 next
		bra.w	DespawnObject
; ===========================================================================

Chop_Fall2:	; Routine 6
		update_y_fall	$18				; update position & apply gravity
		move.w	ost_chopper_y_start(a0),d0
		sub.w	ost_y_pos(a0),d0
		bcc.w	DespawnObject				; branch if chopper hasn't hit start position
		move.w	ost_chopper_y_start(a0),ost_y_pos(a0)	; snap to start position
		move.w	ost_chopper_y_vel(a0),ost_y_vel(a0)	; reset vertical speed
		subq.b	#4,ost_routine(a0)			; goto Chop_Jump next
		bra.w	DespawnObject
