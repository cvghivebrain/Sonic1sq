; ---------------------------------------------------------------------------
; Striped yellow platform (SBZ)

; spawned by:
;	ObjPos_SBZ2
; ---------------------------------------------------------------------------

YellowPlatform:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	YPlat_Index(pc,d0.w),d1
		jmp	YPlat_Index(pc,d1.w)
; ===========================================================================
YPlat_Index:	index *,,2
		ptr YPlat_Main
		ptr YPlat_Move
		ptr YPlat_Still

		rsobj YellowPlatform
ost_yplat_y_start:	rs.w 1					; original y position
		rsobjend
		
YPlat_Settings:	dc.b 32, 8, id_frame_yplat_thin, id_YPlat_Move	; width, height, frame, routine
		dc.b 32, 16, id_frame_yplat_fat, id_YPlat_Still
		even
; ===========================================================================

YPlat_Main:	; Routine 0
		move.l	#Map_YPlat,ost_mappings(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0					; get low nybble of subtype
		add.w	d0,d0
		add.w	d0,d0					; multiply by 4
		lea	YPlat_Settings(pc,d0.w),a2
		move.b	(a2),ost_displaywidth(a0)
		move.b	(a2)+,ost_width(a0)
		move.b	(a2)+,ost_height(a0)
		move.b	(a2)+,ost_frame(a0)
		move.b	(a2)+,ost_routine(a0)
		move.w	#tile_Kos_Stomper+tile_pal2,ost_tile(a0)
		move.w	#priority_4,ost_priority(a0)
		move.w	ost_y_pos(a0),ost_yplat_y_start(a0)
		bra.w	DespawnQuick
; ===========================================================================

YPlat_Move:	; Routine 2
		shortcut
		moveq	#0,d0
		move.b	(v_oscillating_0_to_80).w,d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d0					; reverse vertical direction if xflip bit is set
		addi.w	#$80,d0

	.no_xflip:
		move.w	ost_yplat_y_start(a0),d1
		sub.w	d0,d1
		move.w	d1,ost_y_pos(a0)
		bsr.w	SolidObject_TopOnly
		bra.w	DespawnQuick
; ===========================================================================

YPlat_Still:	; Routine 4
		shortcut
		bsr.w	SolidObject_TopOnly
		bra.w	DespawnQuick
		
