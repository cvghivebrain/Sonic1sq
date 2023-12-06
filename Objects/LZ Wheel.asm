; ---------------------------------------------------------------------------
; Wheels (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3
; ---------------------------------------------------------------------------

Wheel:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Whee_Index(pc,d0.w),d1
		jmp	Whee_Index(pc,d1.w)
; ===========================================================================
Whee_Index:	index *,,2
		ptr Whee_Main
		ptr Whee_Display
; ===========================================================================

Whee_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Whee_Display next
		move.l	#Map_LConv,ost_mappings(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.w	#tile_Kos_LzWheel,ost_tile(a0)
		move.b	#1,ost_priority(a0)
		
Whee_Display:	; Routine 2
		shortcut
		move.b	(v_frame_counter_low).w,d0		; get synchronised frame counter
		andi.b	#3,d0					; read only bits 0-1 (max. 4 frames)
		bne.w	DespawnQuick				; branch if not 0
		
		tst.b	(f_convey_reverse).w
		bne.s	.reverse				; branch if conveyor is running in reverse
		addq.b	#1,ost_frame(a0)			; increment frame
		andi.b	#3,ost_frame(a0)
		bra.w	DespawnQuick

	.reverse:
		subq.b	#1,ost_frame(a0)			; decrement frame
		andi.b	#3,ost_frame(a0)
		bra.w	DespawnQuick