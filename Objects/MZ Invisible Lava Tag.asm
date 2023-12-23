; ---------------------------------------------------------------------------
; Object 54 - invisible	lava tag (MZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 0/1/2
; ---------------------------------------------------------------------------

LavaTag:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	LTag_Index(pc,d0.w),d1
		jmp	LTag_Index(pc,d1.w)
; ===========================================================================
LTag_Index:	index *,,2
		ptr LTag_Main
		ptr LTag_ChkDel

LTag_ColTypes:	dc.b 32, 32					; 0
		dc.b 64, 32					; 1
		dc.b 128, 32					; 2
		even
; ===========================================================================

LTag_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto LTag_ChkDel next
		move.b	#id_React_Hurt,ost_col_type(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		lea	LTag_ColTypes(pc,d0.w),a2
		move.b	(a2)+,ost_col_width(a0)			; get collision setting based on subtype
		move.b	(a2)+,ost_col_height(a0)
		move.b	#render_onscreen+render_rel,ost_render(a0)

LTag_ChkDel:	; Routine 2
		shortcut	DespawnQuick_NoDisplay
		bra.w	DespawnQuick_NoDisplay
