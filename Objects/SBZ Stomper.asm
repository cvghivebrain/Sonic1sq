; ---------------------------------------------------------------------------
; Object 6B - stomper (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2 - subtypes 0/1/2
; ---------------------------------------------------------------------------

ScrapStomp:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Sto_Index(pc,d0.w),d1
		jmp	Sto_Index(pc,d1.w)
; ===========================================================================
Sto_Index:	index *,,2
		ptr Sto_Main
		ptr Sto_Wait
		ptr Sto_Drop
		ptr Sto_Wait2
		ptr Sto_Rise

Sto_Settings:	dc.w $38					; distance to move
		dc.w 60						; drop delay (in frames)
		dc.w 60						; rising delay (in frames)
		dc.b 8						; drop speed (distance must be divisible by this)
		dc.b 1						; rising speed (distance must be divisible by this)

		dc.w $40
		dc.w 60
		dc.w 60
		dc.b 8
		dc.b 8
		
		dc.w $60
		dc.w 60
		dc.w 60
		dc.b 8
		dc.b 8

		rsobj ScrapStomp
ost_stomp_moved:	rs.w 1					; distance moved
ost_stomp_distance:	rs.w 1					; distance to move
ost_stomp_wait_time:	rs.w 1					; time until next action
ost_stomp_drop_master:	rs.w 1					; time to wait until drop
ost_stomp_rise_master:	rs.w 1					; time to wait until rising
ost_stomp_drop_speed:	rs.b 1					; px per frame when dropping
ost_stomp_rise_speed:	rs.b 1					; px per frame when rising
		rsobjend
; ===========================================================================

Sto_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Sto_Wait next
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype
		lsl.w	#3,d0
		lea	Sto_Settings(pc,d0.w),a2		; get variables from list
		move.b	#28,ost_displaywidth(a0)
		move.b	#28,ost_width(a0)
		move.b	#32,ost_height(a0)
		move.w	#tile_Kos_Stomper+tile_pal2,ost_tile(a0)
		move.l	#Map_Stomp,ost_mappings(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#priority_4,ost_priority(a0)
		move.w	(a2)+,ost_stomp_distance(a0)
		move.w	(a2)+,ost_stomp_drop_master(a0)
		move.w	(a2)+,ost_stomp_rise_master(a0)
		move.b	(a2)+,ost_stomp_drop_speed(a0)
		move.b	(a2)+,ost_stomp_rise_speed(a0)
		move.w	ost_stomp_drop_master(a0),ost_stomp_wait_time(a0)

Sto_Wait:	; Routine 2
Sto_Wait2:	; Routine 6
		subq.w	#1,ost_stomp_wait_time(a0)		; decrement timer
		bpl.s	.exit					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Sto_Drop/Sto_Rise next
		
	.exit:
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================

Sto_Drop:	; Routine 4
		moveq	#0,d0
		move.b	ost_stomp_drop_speed(a0),d0
		add.w	d0,ost_y_pos(a0)			; update y pos
		add.w	d0,ost_stomp_moved(a0)
		move.w	ost_stomp_moved(a0),d0
		cmp.w	ost_stomp_distance(a0),d0
		blt.s	.exit					; branch if stomper hasn't moved the full distance
		move.w	ost_stomp_rise_master(a0),ost_stomp_wait_time(a0)
		addq.b	#2,ost_routine(a0)			; goto Sto_Wait2 next
		
	.exit:
		bsr.w	SolidObject
		bra.w	DespawnQuick
; ===========================================================================

Sto_Rise:	; Routine 8
		moveq	#0,d0
		move.b	ost_stomp_rise_speed(a0),d0
		sub.w	d0,ost_y_pos(a0)			; update y pos
		sub.w	d0,ost_stomp_moved(a0)
		bne.s	.exit					; branch if stomper hasn't returned to its original position
		move.w	ost_stomp_drop_master(a0),ost_stomp_wait_time(a0)
		move.b	#id_Sto_Wait,ost_routine(a0)		; goto Sto_Wait next
		
	.exit:
		bsr.w	SolidObject
		bra.w	DespawnQuick
		