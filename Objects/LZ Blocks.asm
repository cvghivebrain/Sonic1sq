; ---------------------------------------------------------------------------
; Object 61 - blocks (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3, ObjPos_SBZ3 - subtypes 1/$13/$27/$30
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

LBlk_Var:	; width, height, tile setting
		dc.b $10, $10
		dc.w tile_Kos_LzDoorH+tile_pal3			; $0x
		dc.b $20, $C
		dc.w tile_Kos_LzPlatform+tile_pal3		; $1x
		dc.b $10, $10
		dc.w tile_Kos_LzBlock+tile_pal3			; $3x

		rsobj LabyrinthBlock
ost_lblock_y_start:	rs.w 1 ; $30				; original y-axis position (2 bytes)
ost_lblock_x_start:	rs.w 1 ; $34				; original x-axis position (2 bytes)
ost_lblock_wait_time:	rs.w 1 ; $36				; time delay for block movement (2 bytes)
ost_lblock_flag:	rs.b 1 ; $38				; 1 = untouched; 0 = touched
ost_lblock_sink:	rs.b 1 ; $3E				; amount the block sinks after Sonic stands on it
ost_lblock_coll_flag:	rs.b 1 ; $3F				; 0 = none; 1 = side collision; -1 = top/bottom collision
		rsobjend
; ===========================================================================

LBlk_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto LBlk_Action next
		move.l	#Map_LBlock,ost_mappings(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get block type
		andi.w	#$F0,d0					; read only the high nybble
		lsr.w	#2,d0
		lea	LBlk_Var(pc,d0.w),a2
		move.b	(a2)+,ost_displaywidth(a0)		; set width
		move.b	(a2)+,ost_height(a0)			; set height
		move.w	(a2),ost_tile(a0)			; set tile setting
		lsr.w	#2,d0
		move.b	d0,ost_frame(a0)
		move.w	ost_x_pos(a0),ost_lblock_x_start(a0)
		move.w	ost_y_pos(a0),ost_lblock_y_start(a0)
		move.b	ost_subtype(a0),d0			; get block type
		andi.b	#$F,d0					; read only the low nybble
		beq.s	LBlk_Action				; branch if 0
		move.b	#1,ost_lblock_flag(a0)			; for types 1/3, set "untouched" flag

LBlk_Action:	; Routine 2
		move.w	ost_x_pos(a0),-(sp)			; save recent x pos to stack
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get block type
		andi.w	#$F,d0					; read only the low nybble
		add.w	d0,d0
		move.w	LBlk_Type_Index(pc,d0.w),d1
		jsr	LBlk_Type_Index(pc,d1.w)		; update position/speed based on type
		move.w	(sp)+,d4				; retrieve x pos from stack
		tst.b	ost_render(a0)				; is block on-screen?
		bpl.s	.chkdel					; if not, branch
		moveq	#0,d1
		move.b	ost_displaywidth(a0),d1
		addi.w	#$B,d1
		moveq	#0,d2
		move.b	ost_height(a0),d2
		move.w	d2,d3
		addq.w	#1,d3
		bsr.w	SolidObject
		move.b	d4,ost_lblock_coll_flag(a0)		; copy collision type (output from SolidObject)
		bsr.w	LBlk_Sink

	.chkdel:
		move.w	ost_lblock_x_start(a0),d0
		bsr.w	OffScreen
		bne.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================
LBlk_Type_Index:
		index *
		ptr LBlk_Type_Solid				; 0
		ptr LBlk_Type_Sinks				; 1
		ptr LBlk_Type_Sinks_Now				; 2
		ptr LBlk_Type_Rises				; 3
		ptr LBlk_Type_Rises_Now				; 4
		ptr LBlk_Type_Sinks_Side			; 5 (unused)
		ptr LBlk_Type_Sinks_Now				; 6
; ===========================================================================

; Type 0 - doesn't move
LBlk_Type_Solid:
		rts
; ===========================================================================

; Type 1/3 - sinks or rises when stood on
LBlk_Type_Sinks:
LBlk_Type_Rises:
		tst.w	ost_lblock_wait_time(a0)		; does time remain?
		bne.s	.wait01					; if yes, branch
		btst	#status_platform_bit,ost_status(a0)	; is Sonic standing on the object?
		beq.s	.donothing01				; if not, branch
		move.w	#30,ost_lblock_wait_time(a0)		; wait for half second

	.donothing01:
		rts	
; ===========================================================================

	.wait01:
		subq.w	#1,ost_lblock_wait_time(a0)		; decrement waiting time
		bne.s	.donothing01				; if time remains, branch
		addq.b	#1,ost_subtype(a0)			; goto LBlk_Type_Sinks_Now or LBlk_Type_Rises_Now
		clr.b	ost_lblock_flag(a0)			; flag block as touched
		rts	
; ===========================================================================

; Type 2/6 - sinks until it hits the floor
LBlk_Type_Sinks_Now:
		bsr.w	SpeedToPos				; update position
		addq.w	#8,ost_y_vel(a0)			; make block fall
		bsr.w	FindFloorObj
		tst.w	d1					; has block hit the floor?
		bpl.w	.nofloor02				; if not, branch
		addq.w	#1,d1
		add.w	d1,ost_y_pos(a0)			; align to floor
		clr.w	ost_y_vel(a0)				; stop when it touches the floor
		clr.b	ost_subtype(a0)				; set type to 00 (non-moving type)

	.nofloor02:
		rts	
; ===========================================================================

; Type 4 - rises until it hits the ceiling
LBlk_Type_Rises_Now:
		bsr.w	SpeedToPos				; update position
		subq.w	#8,ost_y_vel(a0)			; make block rise
		bsr.w	FindCeilingObj
		tst.w	d1					; has block hit the ceiling?
		bpl.w	.noceiling04				; if not, branch
		sub.w	d1,ost_y_pos(a0)			; align to ceiling
		clr.w	ost_y_vel(a0)				; stop when it touches the ceiling
		clr.b	ost_subtype(a0)				; set type to 0 (non-moving type)

	.noceiling04:
		rts	
; ===========================================================================

; Type 5 - sinks when touched from the side (unused)
LBlk_Type_Sinks_Side:
		cmpi.b	#1,ost_lblock_coll_flag(a0)		; has Sonic touched the side of the block?
		bne.s	.notouch05				; if not, branch
		addq.b	#1,ost_subtype(a0)			; set type to 6 (LBlk_Type_Sinks_Now)
		clr.b	ost_lblock_flag(a0)			; flag block as touched

	.notouch05:
		rts

; ---------------------------------------------------------------------------
; Subroutine to sink block slightly when stood on
; ---------------------------------------------------------------------------

LBlk_Sink:
		tst.b	ost_lblock_flag(a0)			; has block been stood on or touched?
		beq.s	.exit					; if yes, branch
		btst	#status_platform_bit,ost_status(a0)	; is Sonic standing on it now?
		bne.s	.standing_on				; if yes, branch
		tst.b	ost_lblock_sink(a0)			; is block in default position?
		beq.s	.exit					; if yes, branch
		subq.b	#4,ost_lblock_sink(a0)			; incrementally return block to default
		bra.s	.update_y
; ===========================================================================

.standing_on:
		cmpi.b	#$40,ost_lblock_sink(a0)		; is block at maximum sink?
		beq.s	.exit					; if yes, branch
		addq.b	#4,ost_lblock_sink(a0)			; keep sinking

.update_y:
		move.b	ost_lblock_sink(a0),d0
		jsr	(CalcSine).l				; convert sink value to sine
		move.w	#$400,d1
		muls.w	d1,d0
		swap	d0
		add.w	ost_lblock_y_start(a0),d0
		move.w	d0,ost_y_pos(a0)			; update position

.exit:
		rts	
