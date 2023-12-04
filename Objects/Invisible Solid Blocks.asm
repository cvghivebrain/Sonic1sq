; ---------------------------------------------------------------------------
; Object 71 - invisible	solid barriers

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 0/$11/$31
;	ObjPos_SYZ2, ObjPos_SYZ3 - subtypes $11/$13/$31
;	ObjPos_LZ1, ObjPos_LZ3 - subtypes $11/$31
;	ObjPos_SBZ1, ObjPos_SBZ2, ObjPos_FZ - subtypes $11/$12/$13/$15/$17/$31/$51/$61/$70/$71/$E1

; subtypes:
;	%WWWWHHHH
;	WWWW - width (+1, *8 for ost_width)
;	HHHH - height (+1, *8 for ost_height)
; ---------------------------------------------------------------------------

Invisibarrier:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Invis_Index(pc,d0.w),d1
		jmp	Invis_Index(pc,d1.w)
; ===========================================================================
Invis_Index:	index *,,2
		ptr Invis_Main
		ptr Invis_Solid
; ===========================================================================

Invis_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Invis_Solid next
		move.l	#Map_Invis,ost_mappings(a0)
		move.w	#tile_Art_Lives+tile_hi,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	ost_subtype(a0),d0			; get object type
		move.b	d0,d1
		andi.w	#$F0,d0					; read only the	high nybble
		addi.w	#$10,d0					; add $10
		lsr.w	#1,d0					; divide by 2
		move.b	d0,ost_displaywidth(a0)			; set object width
		move.b	d0,ost_width(a0)
		andi.w	#$F,d1					; read only the	low nybble
		addq.w	#1,d1					; add 1
		lsl.w	#3,d1					; multiply by 8
		move.b	d1,ost_height(a0)			; set object height

Invis_Solid:	; Routine 2
		shortcut
		tst.w	(v_debug_active).w
		bne.w	DespawnQuick				; branch if debug mode is in use (icons are visible)
		
		bsr.w	SolidObject_SkipRenderDebug
		bra.w	DespawnQuick_NoDisplay
