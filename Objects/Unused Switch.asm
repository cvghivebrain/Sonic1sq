; ---------------------------------------------------------------------------
; Object 1D - switch that activates when Sonic touches it
; (this is not used anywhere in the game)
; ---------------------------------------------------------------------------

MagicSwitch:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Swi_Index(pc,d0.w),d1
		jmp	Swi_Index(pc,d1.w)
; ===========================================================================
Swi_Index:	index *,,2
		ptr Swi_Main
		ptr Swi_Action
		ptr Swi_Delete

		rsobj MagicSwitch
ost_switch_y_start:	rs.w 1 ; $30				; original y-axis position (2 bytes)
		rsobjend
; ===========================================================================

Swi_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)
		move.l	#Map_Switch,ost_mappings(a0)
		move.w	#0+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	ost_y_pos(a0),ost_switch_y_start(a0)	; save position on y-axis
		move.b	#$10,ost_displaywidth(a0)
		move.b	#5,ost_priority(a0)

Swi_Action:	; Routine 2
		move.w	ost_switch_y_start(a0),ost_y_pos(a0)	; restore position on y-axis
		bsr.w	RangePlus
		cmp.w	#16,d1
		bge.s	.display
		cmp.w	#16,d3
		bge.s	.display

		addq.w	#2,ost_y_pos(a0)			; move object down 2px
		moveq	#1,d0
		move.w	d0,(v_button_state).w			; set button 0 as "pressed"

	.display:
		out_of_range.s	Swi_Delete
		bra.w	DisplaySprite
; ===========================================================================

Swi_Delete:	; Routine 4
		bra.w	DeleteObject
