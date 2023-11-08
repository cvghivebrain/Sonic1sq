; ---------------------------------------------------------------------------
; Object 1D - switch that activates when Sonic touches it
; (this is not used anywhere in the game)

; subtypes:
;	%0000IIII
;	IIII - button id
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

		rsobj MagicSwitch
ost_switch_y_start:	rs.w 1					; original y-axis position
ost_switch_done:	rs.b 1					; flag set when switch has activated
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
		getsonic					; a1 = OST of Sonic
		range_x
		cmp.w	#16,d1
		bge.w	DespawnQuick
		range_y
		cmp.w	#16,d3
		bge.w	DespawnQuick

		addq.w	#2,ost_y_pos(a0)			; move object down 2px
		tst.b	ost_switch_done(a0)
		bne.w	DespawnQuick				; branch if already touched
		move.b	#1,ost_switch_done(a0)
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0					; get low nybble of subtype
		lea	(v_button_state).w,a3
		lea	(a3,d0.w),a3				; (a3) = button status
		bset	#0,(a3)					; set as pressed
		bra.w	DespawnQuick
