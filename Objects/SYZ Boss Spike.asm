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

		rsobj Stab
ost_stab_y_start:	rs.w 1					; original y position
ost_stab_x_grid:	rs.w 1					; x position (div 32) when boss moved over Sonic
		rsobjend
; ===========================================================================

Stab_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Stab_Wait next
		move.b	#16,ost_width(a0)
		move.b	#16,ost_height(a0)
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
		addi.w	#$10,d1
		andi.w	#$1F,d1
		bne.s	.exit					; branch if not in middle of 32px vertical strip
		addq.b	#2,ost_routine(a0)			; goto Stab_DropNow next
		move.w	ost_y_pos(a1),ost_stab_y_start(a0)	; save boss y pos (including wobble)
		move.b	#1,ost_mode(a1)				; stop boss moving by itself
		move.w	#$180,ost_y_vel(a0)
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
		move.w	ost_y_pos(a0),ost_y_pos(a1)		; move boss with this object
		rts
		