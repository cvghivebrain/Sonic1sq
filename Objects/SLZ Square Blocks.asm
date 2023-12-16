; ---------------------------------------------------------------------------
; Square floating blocks (SLZ)

; spawned by:
;	ObjPos_SLZ2, ObjPos_SLZ3 - subtype 4
; ---------------------------------------------------------------------------

SquareBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	SBlock_Index(pc,d0.w),d1
		jmp	SBlock_Index(pc,d1.w)
; ===========================================================================
SBlock_Index:	index *
		ptr SBlock_Main
		ptr SBlock_Action

		rsobj SquareBlock
ost_sblock_radius:	rs.w 1					; distance of block from centre
ost_sblock_x_start:	rs.w 1					; original x position
ost_sblock_y_start:	rs.w 1					; original y position
ost_sblock_value_ptr:	rs.l 1					; RAM address of moving value
		rsobjend
		
SBlock_Settings:
		dc.w $10, v_oscillating_0_to_40_alt		; radius, RAM address of moving value
		dc.b 0, 1					; orientation, lsr value
		dc.w $10, v_oscillating_0_to_40_alt
		dc.b status_yflip, 1
		dc.w $30, v_oscillating_0_to_60_alt
		dc.b 0, 0
		dc.w $30, v_oscillating_0_to_60_alt
		dc.b status_yflip, 0
		dc.w $50, v_oscillating_0_to_A0_fast
		dc.b 0, 0
		dc.w $50, v_oscillating_0_to_A0_fast
		dc.b status_yflip, 0
		dc.w $70, v_oscillating_0_to_E0
		dc.b 0, 0
		dc.w $70, v_oscillating_0_to_E0
		dc.b status_yflip, 0
		even
; ===========================================================================

SBlock_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto SBlock_Action next
		move.l	#Map_SBlock,ost_mappings(a0)
		move.w	#0+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype (1-4)
		move.b	d0,d1
		lsl.w	#5,d0					; multiply by 32
		move.b	d0,ost_displaywidth(a0)
		
		add.w	d1,d1
		subq.b	#1,d1					; subtract 1 for loops
		lea	SBlock_Settings(pc),a2
		
	.loop:
		bsr.w	FindNextFreeObj
		bne.s	SBlock_Action
		move.l	#SquareBlockSingle,ost_id(a1)
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	ost_priority(a0),ost_priority(a1)
		move.w	ost_x_pos(a0),ost_sblock_x_start(a1)
		move.w	ost_y_pos(a0),ost_sblock_y_start(a1)
		move.b	#16,ost_displaywidth(a1)
		move.b	#16,ost_width(a1)
		move.b	#16,ost_height(a1)
		move.w	(a2)+,ost_sblock_radius(a1)
		moveq	#-1,d2
		move.w	(a2)+,d2				; d2 = RAM address of moving value
		move.l	d2,ost_sblock_value_ptr(a1)
		move.b	(a2)+,ost_status(a1)			; set orientation
		move.b	(a2)+,ost_subtype(a1)			; set lsr value
		saveparent
		dbf	d1,.loop

SBlock_Action:	; Routine 2
		shortcut	DespawnFamily_NoDisplay
		bra.w	DespawnFamily_NoDisplay

; ---------------------------------------------------------------------------
; Actual square floating blocks (SLZ)

; spawned by:
;	SquareBlock
; ---------------------------------------------------------------------------

SquareBlockSingle:
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		
		move.w	ost_sblock_radius(a0),d1
		move.l	ost_sblock_value_ptr(a0),a2
		move.b	ost_status(a0),d2
		move.b	ost_subtype(a0),d3			; lsr value is 0 or 1
		moveq	#0,d0
		move.b	(a2),d0					; get oscillating value
		lsr.b	d3,d0					; do nothing or divide by 2
		tst.w	2(a2)					; is oscillating value rate currently 0? (i.e. at peak or nadir of oscillation)
		bne.s	.keep_going				; if not, branch
		addq.b	#1,d2					; change direction
		andi.b	#status_xflip+status_yflip,d2		; prevent bit overflow
		move.b	d2,ost_status(a0)

	.keep_going:
		andi.b	#status_xflip+status_yflip,d2		; read xflip and yflip bits
		bne.s	.xflip					; branch if either are set
		sub.w	d1,d0
		add.w	ost_sblock_x_start(a0),d0
		move.w	d0,ost_x_pos(a0)			; update position
		neg.w	d1
		add.w	ost_sblock_y_start(a0),d1
		move.w	d1,ost_y_pos(a0)
		bsr.w	SolidObject
		bra.w	DisplaySprite
; ===========================================================================

.xflip:
		subq.b	#1,d2
		bne.s	.yflip					; branch if yflip bit is set
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	ost_sblock_y_start(a0),d0
		move.w	d0,ost_y_pos(a0)			; update position
		addq.w	#1,d1
		add.w	ost_sblock_x_start(a0),d1
		move.w	d1,ost_x_pos(a0)
		bsr.w	SolidObject
		bra.w	DisplaySprite
; ===========================================================================

.yflip:
		subq.b	#1,d2
		bne.s	.xflip_and_yflip			; branch if xflip and yflip bits are set
		subq.w	#1,d1
		sub.w	d1,d0
		neg.w	d0
		add.w	ost_sblock_x_start(a0),d0
		move.w	d0,ost_x_pos(a0)			; update position
		addq.w	#1,d1
		add.w	ost_sblock_y_start(a0),d1
		move.w	d1,ost_y_pos(a0)
		bsr.w	SolidObject
		bra.w	DisplaySprite
; ===========================================================================

.xflip_and_yflip:
		sub.w	d1,d0
		add.w	ost_sblock_y_start(a0),d0
		move.w	d0,ost_y_pos(a0)			; update position
		neg.w	d1
		add.w	ost_sblock_x_start(a0),d1
		move.w	d1,ost_x_pos(a0)
		bsr.w	SolidObject
		bra.w	DisplaySprite