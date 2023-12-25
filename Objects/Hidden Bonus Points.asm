; ---------------------------------------------------------------------------
; Object 7D - hidden points at the end of a level

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_MZ1, ObjPos_MZ2 - subtypes 1/2/3
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_LZ1, ObjPos_LZ2 - subtypes 1/2/3
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SBZ1 - subtypes 1/2/3
; ---------------------------------------------------------------------------

HiddenBonus:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Bonus_Index(pc,d0.w),d1
		jmp	Bonus_Index(pc,d1.w)
; ===========================================================================
Bonus_Index:	index *,,2
		ptr Bonus_Main
		ptr Bonus_Display

		rsobj HiddenBonus
ost_bonus_wait_time:	rs.w 1					; length of time to display bonus sprites (2 bytes)
		rsobjend
; ===========================================================================

Bonus_Main:	; Routine 0
		getsonic
		range_x
		cmp.w	#16,d1
		bcc.w	DespawnQuick_NoDisplay			; branch if Sonic is > 16px away
		range_y
		cmp.w	#16,d3
		bcc.w	DespawnQuick_NoDisplay

		tst.w	(v_debug_active).w
		bne.w	DespawnQuick_NoDisplay			; branch if using debug mode
		tst.b	(f_giantring_collected).w
		bne.s	Bonus_Delete				; branch if giant ring has been collected

		addq.b	#2,ost_routine(a0)			; goto Bonus_Display next
		move.l	#Map_Bonus,ost_mappings(a0)
		move.w	#(vram_bonus/sizeof_cell)+tile_hi,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#priority_0,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		move.b	ost_subtype(a0),ost_frame(a0)
		add.w	d0,d0
		move.w	Bonus_Points(pc,d0.w),d0		; load bonus points from array
		jsr	(AddPoints).l				; add points and update HUD
		move.w	#119,ost_bonus_wait_time(a0)		; set display time to 2 seconds
		play.w	1, jsr, sfx_Bonus			; play bonus sound
		bra.w	DespawnQuick_NoDisplay

; ===========================================================================
Bonus_Points:	; Bonus	points array
Bonus_Points_0:	dc.w 0						; subtype 0 - 0 points (unused)
Bonus_Points_1:	dc.w 1000					; subtype 1 - 10000 points
Bonus_Points_2:	dc.w 100					; subtype 2 - 1000 points
Bonus_Points_3:	dc.w 10						; subtype 3 - 100 points
; ===========================================================================

Bonus_Display:	; Routine 2
		shortcut
		subq.w	#1,ost_bonus_wait_time(a0)		; decrement display time
		bmi.s	Bonus_Delete				; branch if expired
		bra.w	DespawnQuick

Bonus_Delete:
		jmp	DeleteObject
