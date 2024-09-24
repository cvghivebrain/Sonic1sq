; ---------------------------------------------------------------------------
; Object 1C - scenery (GHZ bridge stump, SLZ lava thrower)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3 - subtype 1
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SLZ3 - subtype 0

type_scen_cannon:	equ (Scen_Values_0-Scen_Values)/sizeof_Scen_Values ; SLZ cannon
type_scen_stump:	equ (Scen_Values_1-Scen_Values)/sizeof_Scen_Values ; GHZ bridge stump
; ---------------------------------------------------------------------------

Scenery:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Scen_Index(pc,d0.w),d1
		jmp	Scen_Index(pc,d1.w)
; ===========================================================================
Scen_Index:	index *
		ptr Scen_Main
		ptr Scen_ChkDel
; ===========================================================================

Scen_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Scen_ChkDel next
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; copy object subtype to d0
		mulu.w	#sizeof_Scen_Values,d0			; multiply by $A
		lea	Scen_Values(pc,d0.w),a1
		move.l	(a1)+,ost_mappings(a0)
		move.w	(a1)+,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.w	(a1)+,ost_frame_hi(a0)
		move.w	(a1)+,ost_displaywidth_hi(a0)
		move.w	(a1)+,ost_priority(a0)
		move.b	#StrId_Scenery,ost_name(a0)

Scen_ChkDel:	; Routine 2
		shortcut	DespawnQuick
		bra.w	DespawnQuick
; ===========================================================================
		
Scen_Values:
Scen_Values_0:	dc.l Map_Scen					; mappings address
		dc.w tile_Kos_SlzCannon+tile_pal3		; VRAM setting
		dc.w id_frame_scen_cannon			; frame
		dc.w 8, priority_2				; width, priority
		even
		
Scen_Values_1:	dc.l Map_Bri
		dc.w tile_Kos_Bridge+tile_pal3
		dc.w id_frame_bridge_stump
		dc.w $10, priority_1
		even
		
sizeof_Scen_Values:	equ Scen_Values_1-Scen_Values
