; ---------------------------------------------------------------------------
; Sliding red platform (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2
; ---------------------------------------------------------------------------

SlideBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Slide_Index(pc,d0.w),d1
		jmp	Slide_Index(pc,d1.w)
; ===========================================================================
Slide_Index:	index *,,2
		ptr Slide_Main
		ptr Slide_Solid
		ptr Slide_Move
		ptr Slide_Wait
		ptr Slide_Return

		rsobj SlideBlock
ost_slide_x_start:	rs.w 1					; original x position
ost_slide_dist:		rs.w 1					; distance moved
ost_slide_speed:	rs.w 1					; speed/direction to move
ost_slide_wait_time:	rs.w 1					; time to wait after moving
		rsobjend
; ===========================================================================

Slide_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Slide_Solid next
		move.l	#Map_Slide,ost_mappings(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$40,ost_displaywidth(a0)
		move.b	#$3F,ost_width(a0)
		move.b	#8,ost_height(a0)
		move.w	#tile_Kos_SlideFloor+tile_pal3,ost_tile(a0)
		move.b	#priority_4,ost_priority(a0)
		move.w	ost_x_pos(a0),ost_slide_x_start(a0)
		move.w	#8,ost_slide_speed(a0)
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	Slide_Solid				; branch if not xflipped
		neg.w	ost_slide_speed(a0)

Slide_Solid:	; Routine 2
		bsr.w	SolidObject_TopOnly
		tst.b	d1
		bne.s	.stood_on				; branch if Sonic stands on platform
		bra.w	DespawnQuick
		
	.stood_on:
		addq.b	#2,ost_routine(a0)			; goto Slide_Move next
		bra.w	DespawnQuick
; ===========================================================================

Slide_Move:	; Routine 4
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		move.w	ost_slide_speed(a0),d0
		add.w	d0,ost_x_pos(a0)			; move 8px left/right
		add.w	d0,ost_slide_dist(a0)
		mvabs.w	ost_slide_dist(a0),d0
		cmpi.w	#$80,d0
		bne.s	.keep_moving				; branch if not fully moved
		addq.b	#2,ost_routine(a0)			; goto Slide_Wait next
		move.w	#300,ost_slide_wait_time(a0)		; wait for 5 seconds
		
	.keep_moving:
		bsr.w	SolidObject_TopOnly
		move.w	ost_slide_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

Slide_Wait:	; Routine 6
		subq.w	#1,ost_slide_wait_time(a0)		; decrement timer
		bpl.s	.wait					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Slide_Return next
		
	.wait:
		bsr.w	SolidObject_TopOnly
		move.w	ost_slide_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

Slide_Return:	; Routine 8
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		move.w	ost_slide_speed(a0),d0
		sub.w	d0,ost_x_pos(a0)			; move 8px left/right
		sub.w	d0,ost_slide_dist(a0)
		bne.s	.keep_moving				; branch if not fully returned
		move.b	#id_Slide_Solid,ost_routine(a0)		; goto Slide_Solid next
		
	.keep_moving:
		bsr.w	SolidObject_TopOnly
		move.w	ost_slide_x_start(a0),d0
		bra.w	DespawnQuick_AltX
