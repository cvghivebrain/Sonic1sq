; ---------------------------------------------------------------------------
; Object 17 - helix of spikes on a pole	(GHZ)

; spawned by:
;	ObjPos_GHZ3 - subtype 1

; subtypes:
;	%R000SSSN
;	R - 1 if helix rotates backwards
;	SSS - start position
;	N - number of spikes (0 = 8; 1 = 16)
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
		move.w	#tile_Kos_SpikePole+tile_pal3,ost_tile(a0)
		move.b	#status_pointy,ost_status(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_3,ost_priority(a0)
		move.b	#StrId_Helix,ost_name(a0)
		move.b	ost_subtype(a0),d1
		move.b	d1,d4
		andi.w	#1,d1					; read low bit
		addq.b	#1,d1
		lsl.b	#3,d1					; d1 = 8 or 16
		bsr.w	FindFreeSub				; a1 = subsprite table
		bne.w	DeleteObject				; delete if not available
		
		move.w	d1,(a1)+				; write subsprite count
		move.w	d1,d2
		lsl.w	#3,d2
		move.w	d2,d3
		addq.w	#8,d2
		move.w	d2,ost_displaywidth_hi(a0)
		neg.w	d3					; d3 = x pos of first spike
		subq.b	#1,d1					; -1 for loops
		
		lsr.b	#1,d4					; read bits 1-3 of subtype
		add.b	(v_syncani_0_frame).w,d4		; add synchronised animation
		andi.w	#7,d4					; max 8 frames
		lsl.w	#3,d4					; multiply by 8
		lea	Hel_Sprites(pc,d4.w),a2			; jump to relevant sprite data
		
	.loop:
		move.w	(a2)+,d0
		cmpi.w	#$1234,d0
		bne.s	.not_at_end				; branch if not at end of sprite list
		lea	Hel_Sprites(pc),a2			; back to start of list
		bra.s	.loop
		
	.not_at_end:
		move.w	d0,(a1)+				; write y pos
		move.w	(a2)+,(a1)+				; write sprite size
		move.w	ost_tile(a0),d0
		add.w	(a2)+,d0
		move.w	d0,(a1)+				; write tile
		move.w	d3,d0
		add.w	(a2)+,d0
		move.w	d0,(a1)+				; write x pos
		addi.w	#16,d3					; next spike is 16px apart
		dbf	d1,.loop				; repeat for all spikes
		bra.s	Hel_Action
		
Hel_Sprites:	dc.w -$10, sprite1x2, 0, -4			; up
		dc.w -$B, sprite2x2, 2, -8			; up 45 deg
		dc.w -8, sprite2x2, 6, -8			; 90 deg
		dc.w -5, sprite2x2, $A, -8			; down 45 deg
		dc.w 0, sprite1x2, $E, -4			; down
		dc.w 4, sprite1x1, $10, -3			; down 45 deg
		dc.w $1000, sprite1x1, 0, -1			; hidden
		dc.w -$C, sprite1x1, $11, -3			; up 45 deg
		dc.w $1234

Hel_Action:	; Routine 2
		shortcut
		tst.b	(v_syncani_0_time).w
		bne.w	DespawnFamily				; branch if frame timer isn't 0
		move.w	ost_subsprite(a0),d0
		beq.w	DespawnFamily				; branch if subsprites aren't present
		movea.w	d0,a2					; a2 = subsprite table
		move.w	(a2),d0					; get subsprite count (8 or 16)
		move.w	d0,d1
		lsl.w	#3,d1
		move.w	d1,d2					; d2 = 64 or 128
		add.w	d1,d1					; d1 = 128 or 256
		subq.b	#1,d0					; -1 for loops
		addq.w	#subspr0+piece_x_pos,a2			; jump to x pos
		moveq	#16,d3
		sub.w	d3,d2
		subi.w	#32,d2
		sub.w	d3,d1
		
	.loop:
		cmp.w	(a2),d2
		blt.s	.wrap					; branch if subsprite is at rightmost end
		add.w	d3,(a2)					; move 16px to the right
		
	.next:
		addq.w	#sizeof_piece,a2			; next subsprite
		dbf	d0,.loop				; repeat for all
		bra.w	DespawnFamily
		
	.wrap:
		sub.w	d1,(a2)					; wrap to left side
		bra.s	.next

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
