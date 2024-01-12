; ---------------------------------------------------------------------------
; Object 17 - helix of spikes on a pole	(GHZ)

; spawned by:
;	ObjPos_GHZ3 - subtype $10

; subtypes:
;	%R00NNNNN
;	R - 1 if helix rotates backwards
;	NNNNN - number of spikes (max $1F)
; ---------------------------------------------------------------------------

Helix:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Hel_Index(pc,d0.w),d1
		jmp	Hel_Index(pc,d1.w)
; ===========================================================================
Hel_Index:	index *,,2
		ptr Hel_Main
		ptr Hel_Action
; ===========================================================================

Hel_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Hel_Action next
		move.l	#Map_Hel,ost_mappings(a0)
		move.w	#tile_Kos_SpikePole+tile_pal3,ost_tile(a0)
		move.b	#status_pointy,ost_status(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_3,ost_priority(a0)
		move.l	#HelixSpike,d4
		moveq	#0,d1
		move.b	ost_subtype(a0),d1
		bpl.s	.no_rev					; branch if high bit of subtype is clear
		move.l	#HelixSpikeRev,d4			; helix rotates backwards
		
	.no_rev:
		andi.b	#$1F,d1
		move.l	d1,d2
		lsl.w	#3,d1					; multiply by 8
		move.b	d1,ost_displaywidth(a0)
		move.b	d1,ost_width(a0)
		
		sub.w	ost_x_pos(a0),d1
		neg.w	d1					; d1 = x pos of left edge
		subq.b	#1,d2
		moveq	#0,d3

	.loop:
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	Hel_Action				; branch if not found
		move.l	d4,ost_id(a1)				; load spike object
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#priority_3,ost_priority(a1)
		move.w	ost_status(a0),ost_status(a1)
		move.b	#8,ost_displaywidth(a1)
		move.b	#4,ost_col_width(a1)
		move.b	#16,ost_col_height(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	d1,ost_x_pos(a1)
		addi.w	#16,d1					; x position of next spike
		move.b	d3,ost_subtype(a1)			; set initial frame for current spike
		addq.b	#1,d3					; use next frame on next spike
		andi.b	#7,d3					; there are only 8 frames
		saveparent
		dbf	d2,.loop				; repeat d2 times (helix length)

Hel_Action:	; Routine 2
		shortcut	DespawnFamily_NoDisplay
		bra.w	DespawnFamily_NoDisplay

; ---------------------------------------------------------------------------
; Individual spike object

; spawned by:
;	Helix
; ---------------------------------------------------------------------------

HelixSpike:
		tst.b	(v_syncani_0_time).w
		bne.w	DisplaySprite				; branch if frame timer isn't 0
		move.b	(v_syncani_0_frame).w,d0		; get synchronised frame value
		move.b	#0,ost_col_type(a0)			; make object harmless
		add.b	ost_subtype(a0),d0			; add initial frame
		andi.b	#7,d0					; there are 8 frames max
		move.b	d0,ost_frame(a0)			; change current frame
		bne.w	DisplaySprite				; branch if not 0
		move.b	#id_React_Hurt,ost_col_type(a0)		; make object harmful
		bra.w	DisplaySprite

HelixSpikeRev:
		tst.b	(v_syncani_0_time).w
		bne.w	DisplaySprite				; branch if frame timer isn't 0
		move.b	(v_syncani_0_frame).w,d0		; get synchronised frame value
		neg.b	d0
		addq.b	#7,d0					; invert frame
		move.b	#0,ost_col_type(a0)			; make object harmless
		add.b	ost_subtype(a0),d0			; add initial frame
		andi.b	#7,d0					; there are 8 frames max
		move.b	d0,ost_frame(a0)			; change current frame
		bne.w	DisplaySprite				; branch if not 0
		move.b	#id_React_Hurt,ost_col_type(a0)		; make object harmful
		bra.w	DisplaySprite
