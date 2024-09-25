; ---------------------------------------------------------------------------
; Horizontal sliding door (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2
; ---------------------------------------------------------------------------

ScrapDoorH:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	SDoorH_Index(pc,d0.w),d1
		jsr	SDoorH_Index(pc,d1.w)
		move.w	ost_sdoorh_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================
SDoorH_Index:	index *,,2
		ptr SDoorH_Main
		ptr SDoorH_ChkBtn
		ptr SDoorH_Move
		ptr SDoorH_Wait
		ptr SDoorH_Reset
		
		rsobj ScrapDoorH
ost_sdoorh_x_start:	rs.w 1					; initial x pos
ost_sdoorh_dist:	rs.w 1					; distance moved
ost_sdoorh_time:	rs.w 1					; time until reset position
		rsobjend
; ===========================================================================

SDoorH_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto SDoorH_ChkBtn next
		move.l	#Map_SDoorH,ost_mappings(a0)
		move.w	#tile_Kos_SbzDoorH+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_4,ost_priority(a0)
		move.b	#64,ost_displaywidth(a0)
		move.b	#StrId_Door,ost_name(a0)
		move.b	#64,ost_width(a0)
		move.b	#12,ost_height(a0)
		move.w	ost_x_pos(a0),ost_sdoorh_x_start(a0)
		
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	SDoorH_ChkBtn				; branch if not xflipped
		subi.w	#128,ost_x_pos(a0)			; starts in left position

SDoorH_ChkBtn:	; Routine 2
		lea	(v_button_state).w,a2
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		tst.b	(a2,d0.w)				; check state of linked button
		beq.w	SolidObject				; branch if button isn't pressed
		addq.b	#2,ost_routine(a0)			; goto SDoorH_Move next
		bra.w	SolidObject
; ===========================================================================

SDoorH_Move:	; Routine 4
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		move.b	ost_status(a0),d0
		andi.w	#status_xflip,d0
		add.w	d0,d0
		add.w	d0,d0
		neg.w	d0
		addq.w	#2,d0
		sub.w	d0,ost_x_pos(a0)			; move 2px right/left depending on xflip
		addq.w	#2,ost_sdoorh_dist(a0)
		cmpi.w	#128,ost_sdoorh_dist(a0)
		bne.w	SolidObject				; branch if not fully moved
		addq.b	#2,ost_routine(a0)			; goto SDoorH_Wait next
		move.w	#180,ost_sdoorh_time(a0)		; set timer to 3 seconds
		bra.w	SolidObject
; ===========================================================================

SDoorH_Wait:	; Routine 6
		subq.w	#1,ost_sdoorh_time(a0)
		bne.w	SolidObject				; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto SDoorH_Reset next
		bra.w	SolidObject
; ===========================================================================

SDoorH_Reset:	; Routine 8
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		move.b	ost_status(a0),d0
		andi.w	#status_xflip,d0
		add.w	d0,d0
		add.w	d0,d0
		neg.w	d0
		addq.w	#2,d0
		add.w	d0,ost_x_pos(a0)			; move 2px right/left depending on xflip
		subq.w	#2,ost_sdoorh_dist(a0)
		bne.w	SolidObject				; branch if not fully moved
		move.b	#id_SDoorH_ChkBtn,ost_routine(a0)	; goto SDoorH_ChkBtn next
		bra.w	SolidObject
		
