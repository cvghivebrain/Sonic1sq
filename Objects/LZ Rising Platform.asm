; ---------------------------------------------------------------------------
; Rising platform (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_SBZ3
; ---------------------------------------------------------------------------

LabyrinthPlatform:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	LPlat_Index(pc,d0.w),d1
		jmp	LPlat_Index(pc,d1.w)
; ===========================================================================
LPlat_Index:	index *,,2
		ptr LPlat_Main
		ptr LPlat_Action
		ptr LPlat_Rise
		ptr LPlat_Stop
		
		rsobj LabyrinthPlatform
ost_lplat_y_pos:	rs.w 1					; y pos without sink
ost_lplat_wait_time:	rs.w 1					; time delay
		rsobjend
; ===========================================================================

LPlat_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Cork_Action next
		move.l	#Map_LPlat,ost_mappings(a0)
		move.w	#tile_Kos_LzPlatform+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		move.b	#32,ost_displaywidth(a0)
		move.b	#32,ost_width(a0)
		move.b	#12,ost_height(a0)
		move.w	ost_y_pos(a0),ost_lplat_y_pos(a0)
		
LPlat_Action:	; Routine 2
		tst.w	ost_lblock_wait_time(a0)
		bne.s	.wait					; branch if time > 0
		btst	#status_platform_bit,ost_status(a0)
		beq.s	LPlat_Update				; branch if Sonic isn't standing on it
		move.w	#30,ost_lblock_wait_time(a0)		; wait for half second
		bra.s	LPlat_Update

	.wait:
		subq.w	#1,ost_lblock_wait_time(a0)		; decrement waiting time
		bne.s	LPlat_Update				; branch if time > 0
		addq.b	#2,ost_routine(a0)			; goto LPlat_Rise next
		
LPlat_Update:
		move.w	ost_lplat_y_pos(a0),d0
		bsr.w	Sink					; platform sinks slightly when stood on, update y pos
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================

LPlat_Rise:	; Routine 4
		move.w	ost_y_vel(a0),d0			; load vertical speed
		ext.l	d0
		asl.l	#8,d0					; multiply speed by $100
		add.l	d0,ost_lplat_y_pos(a0)			; update y position
		
		subq.w	#8,ost_y_vel(a0)			; make block rise
		bsr.w	FindCeilingObj
		tst.w	d1					; has block hit the ceiling?
		bpl.s	LPlat_Update				; if not, branch
		sub.w	d1,ost_lplat_y_pos(a0)			; align to ceiling
		clr.w	ost_y_vel(a0)				; stop when it touches the ceiling
		addq.b	#2,ost_routine(a0)			; goto LPlat_Stop next
		bra.s	LPlat_Update
; ===========================================================================
		
LPlat_Stop:	; Routine 6
		shortcut
		bsr.w	SolidObject
		bra.w	DespawnQuick
