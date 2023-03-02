; ---------------------------------------------------------------------------
; Object 53 - collapsing floors	(MZ, SLZ, SBZ)

; spawned by:
;	ObjPos_MZ3 - subtype 1
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SLZ3 - subtypes 1/$81
;	ObjPos_SBZ1, ObjPos_SBZ2 - subtype 1
; ---------------------------------------------------------------------------

CollapseFloor:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	CFlo_Index(pc,d0.w),d1
		jmp	CFlo_Index(pc,d1.w)
; ===========================================================================
CFlo_Index:	index *,,2
		ptr CFlo_Main
		ptr CFlo_Solid
		ptr CFlo_Wait
		ptr CFlo_Collapse

		rsobj CollapseFloor
ost_cfloor_wait_time:	rs.b 1					; time delay for collapsing floor
		rsobjend
; ===========================================================================

CFlo_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto CFlo_Solid next
		move.l	#Map_CFlo,ost_mappings(a0)
		move.w	(v_tile_floor).w,ost_tile(a0)
		addi.w	#tile_pal3,ost_tile(a0)
		move.b	ost_subtype(a0),d0
		andi.b	#%01110000,d0				; read bits 4-6 of subtype
		lsr.b	#3,d0
		move.b	d0,ost_frame(a0)			; set as frame
		ori.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#7,ost_cfloor_wait_time(a0)
		move.b	#$44,ost_displaywidth(a0)
		move.b	#32,ost_width(a0)
		move.b	#8,ost_height(a0)

CFlo_Solid:	; Routine 2
		bsr.w	SolidObject_TopOnly
		tst.b	d1
		beq.w	DespawnObject				; branch if no collision
		addq.b	#2,ost_routine(a0)			; goto CFlo_Wait next
		bra.w	DespawnObject
; ===========================================================================

CFlo_Wait:	; Routine 4
		subq.b	#1,ost_cfloor_wait_time(a0)		; decrement timer
		bpl.s	.wait					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto CFlo_Collapse next
		
	.wait:
		bsr.w	SolidObject_TopOnly
		bra.w	DespawnObject
; ===========================================================================

CFlo_Collapse:	; Routine 6
		bsr.w	UnSolid_TopOnly
		addq.b	#1,ost_frame(a0)			; use frame consisting of smaller pieces
		tst.b	ost_subtype(a0)
		bpl.s	.no_sidedness				; branch if high bit of subtype is 0
		bclr	#render_xflip_bit,ost_render(a0)
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0
		bcc.s	.no_sidedness				; branch if Sonic is left of the platform
		bset	#render_xflip_bit,ost_render(a0)
		
	.no_sidedness:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		andi.b	#$F,d0					; read low nybble of subtype
		lsl.b	#3,d0					; multiply by 8
		lea	CFlo_FragTiming_0(pc,d0.w),a4
		bra.w	Crumble					; spawn fragments and delete original

CFlo_FragTiming_0:
		dc.b $1E, $16, $E, 6, $1A, $12,	$A, 2		; unused
CFlo_FragTiming_1:
		dc.b $16, $1E, $1A, $12, 6, $E,	$A, 2
		even
