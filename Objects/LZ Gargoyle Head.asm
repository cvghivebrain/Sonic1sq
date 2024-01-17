; ---------------------------------------------------------------------------
; Object 62 - gargoyle head (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3, ObjPos_SBZ3 - subtypes 1/2/3/4

; subtypes:
;	%TTTTRRRR
;	TTTT - type of object to spawn (see Gar_Settings; only fireballs are defined)
;	RRRR - fireball rate (+1, *30 for ost_gar_time_master)
; ---------------------------------------------------------------------------

Gargoyle:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Gar_Index(pc,d0.w),d1
		jmp	Gar_Index(pc,d1.w)
; ===========================================================================
Gar_Index:	index *,,2
		ptr Gar_Main
		ptr Gar_MakeFire

		rsobj Gargoyle
ost_gar_time_master:	rs.b 1					; time between fireballs
		rsobjend

Gar_Settings:	dc.l GarFire					; object id
		dc.w $200, 0					; initial x/y vel
; ===========================================================================

Gar_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Gar_MakeFire next
		move.l	#Map_Gar,ost_mappings(a0)
		move.w	#tile_Kos_Gargoyle+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#priority_3,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	ost_subtype(a0),d0			; get object type
		andi.w	#$F,d0					; read only the	low nybble
		addi.b	#1,d0
		mulu.w	#30,d0
		move.b	d0,ost_gar_time_master(a0)		; set fireball spit rate
		move.b	ost_gar_time_master(a0),ost_anim_time(a0)

Gar_MakeFire:	; Routine 2
		shortcut
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bne.w	DespawnQuick				; if time remains, branch

		move.b	ost_gar_time_master(a0),ost_anim_time(a0) ; reset timer
		tst.b	ost_render(a0)
		bpl.w	DespawnQuick				; branch if off screen
		bsr.w	FindFreeObj				; find free OST slot
		bne.w	DespawnQuick				; branch if not found
		move.b	ost_subtype(a0),d0
		andi.w	#$F0,d0					; read high nybble of subtype
		lsr.b	#1,d0
		lea	Gar_Settings(pc,d0.w),a2
		move.l	(a2)+,ost_id(a1)			; load fireball object
		move.w	(a2)+,ost_x_vel(a1)
		move.w	(a2)+,ost_y_vel(a1)
		btst	#status_xflip_bit,ost_status(a0)
		bne.s	.xflipped				; branch if xflipped
		neg.w	ost_x_vel(a1)				; send in opposite direction
		
	.xflipped:
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	ost_status(a0),ost_status(a1)
		bra.w	DespawnQuick
		
; ---------------------------------------------------------------------------
; Fireballs from gargoyle heads (LZ)

; spawned by:
;	Gargoyle
; ---------------------------------------------------------------------------

GarFire:
		move.b	#8,ost_height(a0)
		move.b	#8,ost_width(a0)
		move.l	#Map_Gar,ost_mappings(a0)
		move.w	#tile_Kos_Gargoyle,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#priority_4,ost_priority(a0)
		move.b	#id_React_Hurt,ost_col_type(a0)
		move.b	#4,ost_col_width(a0)
		move.b	#4,ost_col_height(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#id_frame_gargoyle_fireball1,ost_frame(a0)
		addq.w	#8,ost_y_pos(a0)
		play.w	1, jsr, sfx_FireBall			; play fireball sound

		shortcut
		toggleframe	8				; animate
		update_x_pos					; update position
		tst.w	ost_x_vel(a0)
		bpl.s	.isright				; branch if moving right
		bsr.w	FindWallLeftObj
		tst.w	d1
		bmi.w	DeleteObject				; delete if the	fireball hits a	wall to the left
		bra.w	DespawnQuick

	.isright:
		bsr.w	FindWallRightObj
		tst.w	d1
		bmi.w	DeleteObject				; delete if the	fireball hits a	wall to the right
		bra.w	DespawnQuick
