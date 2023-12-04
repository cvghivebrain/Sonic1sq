; ---------------------------------------------------------------------------
; Object 61 - blocks (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3, ObjPos_SBZ3 - subtypes 0/1
; ---------------------------------------------------------------------------

LabyrinthBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	LBlk_Index(pc,d0.w),d1
		jmp	LBlk_Index(pc,d1.w)
; ===========================================================================
LBlk_Index:	index *,,2
		ptr LBlk_Main
		ptr LBlk_Action
		ptr LBlk_Fall
		ptr LBlk_Stop

		rsobj LabyrinthBlock
ost_lblock_y_pos:	rs.w 1					; y pos without sink
ost_lblock_wait_time:	rs.w 1					; time delay for block movement
		rsobjend
; ===========================================================================

LBlk_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto LBlk_Action next
		move.l	#Map_LBlock,ost_mappings(a0)
		move.w	#tile_Kos_LzDoorH+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		move.b	#16,ost_displaywidth(a0)
		move.b	#16,ost_width(a0)
		move.b	#16,ost_height(a0)
		move.w	ost_y_pos(a0),ost_lblock_y_pos(a0)
		move.b	ost_subtype(a0),ost_frame(a0)
		bne.s	LBlk_Action				; branch if not type 0
		
		move.w	#tile_Kos_LzBlock+tile_pal3,ost_tile(a0)
		move.b	#id_LBlk_Stop,ost_routine(a0)		; goto LBlk_Stop next
		bra.s	LBlk_Solid
; ===========================================================================

LBlk_Action:	; Routine 2
		tst.w	ost_lblock_wait_time(a0)
		bne.s	.wait					; branch if time > 0
		btst	#status_platform_bit,ost_status(a0)
		beq.s	LBlk_Update				; branch if Sonic isn't standing on it
		move.w	#30,ost_lblock_wait_time(a0)		; wait for half second
		bra.s	LBlk_Update

	.wait:
		subq.w	#1,ost_lblock_wait_time(a0)		; decrement waiting time
		bne.s	LBlk_Update				; branch if time > 0
		addq.b	#2,ost_routine(a0)			; goto LBlk_Fall next
		
LBlk_Update:
		move.w	ost_lblock_y_pos(a0),d0
		bsr.w	Sink					; platform sinks slightly when stood on, update y pos
		
LBlk_Solid:	; Routine 6
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================

LBlk_Fall:	; Routine 4
		update_y_fall	8				; update position & apply gravity
		bsr.w	FindFloorObj
		tst.w	d1					; has block hit the floor?
		bpl.s	LBlk_Solid				; if not, branch
		addq.w	#1,d1
		add.w	d1,ost_y_pos(a0)			; align to floor
		clr.w	ost_y_vel(a0)				; stop when it touches the floor
		addq.b	#2,ost_routine(a0)			; goto LBlk_Stop next
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================
		
LBlk_Stop:	; Routine 6
		shortcut
		bsr.w	SolidObject
		bra.w	DespawnQuick
