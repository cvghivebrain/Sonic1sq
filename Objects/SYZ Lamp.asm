; ---------------------------------------------------------------------------
; Object 12 - lamp (SYZ)

; spawned by:
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3
; ---------------------------------------------------------------------------

SpinningLight:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Light_Index(pc,d0.w),d1
		jmp	Light_Index(pc,d1.w)
; ===========================================================================
Light_Index:	index *,,2
		ptr Light_Main
		ptr Light_Animate
; ===========================================================================

Light_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Light_Animate next
		move.l	#Map_Light,ost_mappings(a0)
		move.w	#0,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#6,ost_priority(a0)

Light_Animate:	; Routine 2
		shortcut
		subq.b	#1,ost_anim_time(a0)			; decrement animation timer
		bpl.w	DespawnQuick				; branch if time remains
		move.b	#7,ost_anim_time(a0)			; reset timer
		moveq	#0,d0
		move.b	ost_frame(a0),d0
		move.b	Light_Next(pc,d0.w),ost_frame(a0)
		bra.w	DespawnQuick
		
Light_Next:	dc.b 1, 2, 3, 4, 5, 0
		even
