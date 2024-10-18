; ---------------------------------------------------------------------------
; Spring Yard Zone boss spike

; spawned by:
;	Boss
; ---------------------------------------------------------------------------

Stabber:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Stab_Index(pc,d0.w),d1
		jmp	Stab_Index(pc,d1.w)
; ===========================================================================
Stab_Index:	index *,,2
		ptr Stab_Main
		ptr Stab_Wait
		ptr Stab_Drop
		ptr Stab_DropNow
		ptr Stab_Stop

		rsobj Stab
ost_stab_y_start:	rs.w 1					; original y position
ost_stab_y_stop:	rs.w 1					; y position to stop when picking up a block
ost_stab_x_grid:	rs.w 1					; x position (div 32) when boss moved over Sonic
		rsobjend
; ===========================================================================

Stab_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Stab_Wait next
		move.b	#16,ost_width(a0)
		move.b	#$1D,ost_height(a0)
		move.b	#StrId_Boss,ost_name(a0)

Stab_Wait:	; Routine 2
		getparent					; a1 = OST of boss
		move.w	ost_x_pos(a1),d0
		move.w	d0,ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)		; match position to boss
		lsr.w	#5,d0					; divide x pos by 32
		getsonic a2					; a2 = OST of Sonic
		move.w	ost_x_pos(a2),d1
		lsr.w	#5,d1
		cmp.w	d0,d1
		bne.s	.exit					; branch if not in same 32px vertical strip as Sonic
		addq.b	#2,ost_routine(a0)			; goto Stab_Drop next
		move.w	d0,ost_stab_x_grid(a0)
		
	.exit:
		rts
; ===========================================================================

Stab_Drop:	; Routine 4
		getparent					; a1 = OST of boss
		move.w	ost_x_pos(a1),d0
		move.w	d0,ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)		; match position to boss
		move.w	d0,d1
		lsr.w	#5,d0					; divide x pos by 32
		cmp.w	ost_stab_x_grid(a0),d0
		bne.s	.cancel					; branch if boss leaves 32px vertical strip
		move.w	d1,d2
		addi.w	#$10,d1
		andi.w	#$1F,d1
		cmpi.w	#1,d1
		bhi.s	.exit					; branch if not in middle of 32px vertical strip
		addq.b	#2,ost_routine(a0)			; goto Stab_DropNow next
		andi.w	#$FFE0,d2
		addi.w	#$10,d2
		move.w	d2,ost_x_pos(a0)			; align to middle of 32px strip
		move.w	ost_y_pos(a1),ost_stab_y_start(a0)	; save boss y pos (including wobble)
		move.b	#1,ost_mode(a1)				; stop boss moving by itself
		move.w	#$180,ost_y_vel(a0)
		move.l	#CheeseBlock,d0
		jsr	FindNearestObj				; find nearest cheese block
		beq.s	Stab_DropNow				; branch if none found
		move.w	d1,ost_linked(a0)			; save OST of cheese block
		getlinked					; a1 = OST of cheese block
		move.w	ost_y_pos(a1),d0
		moveq	#0,d1
		move.b	ost_height(a1),d1
		add.b	ost_height(a0),d1
		sub.w	d1,d0
		move.w	d0,ost_stab_y_stop(a0)
		bra.s	Stab_DropNow
		
	.cancel:
		subq.b	#2,ost_routine(a0)			; goto Stab_Wait next
		
	.exit:
		rts
; ===========================================================================

Stab_DropNow:	; Routine 6
		update_y_pos					; move down
		getparent					; a1 = OST of boss
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)		; move boss as well
		move.w	ost_stab_y_stop(a0),d0
		cmp.w	ost_y_pos(a0),d0
		bhi.s	.exit					; branch if boss hasn't reached block
		addq.b	#2,ost_routine(a0)			; goto Stab_Stop next
		
	.exit:
		rts
; ===========================================================================

Stab_Stop:	; Routine 8
		rts
		
; ---------------------------------------------------------------------------
; Spring Yard Zone cheese blocks

; spawned by:
;	ObjPos_SYZ3

; subtypes:
;	%0000NNNN
;	NNNN - number of additional blocks to right of this one
; ---------------------------------------------------------------------------

CheeseBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Cheese_Index(pc,d0.w),d1
		jmp	Cheese_Index(pc,d1.w)
; ===========================================================================
Cheese_Index:	index *,,2
		ptr Cheese_Main
		ptr Cheese_Solid
; ===========================================================================
		
Cheese_Main:	; Routine 0
		moveq	#0,d1
		move.b	ost_subtype(a0),d1			; get number of extra blocks
		andi.b	#$F,d1
		move.w	ost_x_pos(a0),d2			; starting x pos
		movea.w	a0,a1
		bra.s	.skip_find
		
	.loop:
		jsr	FindFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		
	.skip_find:
		move.l	#CheeseBlock,ost_id(a1)
		move.b	#id_Cheese_Solid,ost_routine(a1)	; goto Cheese_Solid next
		move.l	#Map_BossBlock,ost_mappings(a1)
		move.w	#0+tile_pal3,ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#$10,ost_displaywidth(a1)
		move.b	#StrId_Block,ost_name(a1)
		move.b	#$10,ost_width(a1)
		move.b	#$10,ost_height(a1)
		move.w	#priority_3,ost_priority(a1)
		move.w	d2,ost_x_pos(a1)			; set x position
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		addi.w	#32,d2					; next block 32px to right
		dbf	d1,.loop				; repeat for all blocks
		
	.fail:
		
Cheese_Solid:	; Routine 2
		jsr	SolidObject
		jmp	DespawnQuick
		