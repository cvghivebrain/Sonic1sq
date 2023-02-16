; ---------------------------------------------------------------------------
; Cork block (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ3
; ---------------------------------------------------------------------------

Cork:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Cork_Index(pc,d0.w),d1
		jmp	Cork_Index(pc,d1.w)
; ===========================================================================
Cork_Index:	index *,,2
		ptr Cork_Main
		ptr Cork_Action
; ===========================================================================

Cork_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Cork_Action next
		move.l	#Map_Cork,ost_mappings(a0)
		move.w	#tile_Kos_Cork+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		move.b	#16,ost_displaywidth(a0)
		move.b	#16,ost_width(a0)
		move.b	#16,ost_height(a0)
		
Cork_Action:	; Routine 2
		bsr.s	Cork_Float
		bsr.w	SolidObject
		move.w	ost_x_pos(a0),d0
		bsr.w	CheckActive
		bne.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

Cork_Float:
		move.w	(v_water_height_actual).w,d0
		tst.b	ost_solid(a0)
		beq.s	.not_stood_on				; branch if block isn't being stood on
		addq.w	#4,d0					; pretend water surface is 4px lower
		
	.not_stood_on:
		sub.w	ost_y_pos(a0),d0			; is block level with water?
		beq.s	.exit					; if yes, branch
		bcc.s	.fall					; branch if block is above water
		cmpi.w	#-2,d0					; is block within 2px of water surface?
		bge.s	.near_surface				; if yes, branch
		moveq	#-2,d0					; set maximum rate for block rising

	.near_surface:
		add.w	d0,ost_y_pos(a0)			; make the block rise
		bsr.w	FindCeilingObj
		tst.w	d1					; has block hit the ceiling?
		bpl.s	.exit					; if not, branch
		sub.w	d1,ost_y_pos(a0)			; stop block
		rts

.fall:
		cmpi.w	#2,d0					; is block within 2px of water surface?
		ble.s	.near_surface2				; if yes, branch
		moveq	#2,d0					; set maximum rate for block sinking

	.near_surface2:
		add.w	d0,ost_y_pos(a0)			; make the block sink
		bsr.w	FindFloorObj
		tst.w	d1					; has block hit the floor?
		bpl.s	.exit					; if not, branch
		add.w	d1,ost_y_pos(a0)			; stop block

	.exit:
		rts
		