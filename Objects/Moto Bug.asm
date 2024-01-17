; ---------------------------------------------------------------------------
; Object 40 - Moto Bug enemy (GHZ)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3
; ---------------------------------------------------------------------------

MotoBug:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Moto_Index(pc,d0.w),d1
		jmp	Moto_Index(pc,d1.w)
; ===========================================================================
Moto_Index:	index *,,2
		ptr Moto_Main
		ptr Moto_Walk
		ptr Moto_Wait

		rsobj MotoBug
ost_moto_wait_time:	rs.w 1					; time delay before changing direction (2 bytes)
ost_moto_smoke_time:	rs.b 1					; time delay between smoke puffs
		rsobjend
; ===========================================================================

Moto_Main:	; Routine 0
		move.l	#Map_Moto,ost_mappings(a0)
		move.w	(v_tile_motobug).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_4,ost_priority(a0)
		move.b	#$14,ost_displaywidth(a0)
		move.b	#$E,ost_height(a0)
		move.b	#8,ost_width(a0)
		move.b	#id_React_Enemy,ost_col_type(a0)
		move.b	#20,ost_col_width(a0)
		move.b	#16,ost_col_height(a0)
		addq.b	#2,ost_routine(a0)			; goto Moto_Walk next
		move.w	#-$100,ost_x_vel(a0)			; moves to the left
		btst	#status_xflip_bit,ost_status(a0)
		beq.w	SnapFloor				; branch if facing left
		neg.w	ost_x_vel(a0)				; moves right
		bra.w	SnapFloor
; ===========================================================================

Moto_Walk:	; Routine 2
		lea	Ani_Moto(pc),a1
		bsr.w	AnimateSprite
		update_x_pos					; move left/right
		
		jsr	FindFloorObj				; find floor at current position
		cmpi.w	#-8,d1
		blt.s	.stop_here
		cmpi.w	#$C,d1
		bge.s	.stop_here				; branch if more than 11px above or 8px below floor
		add.w	d1,ost_y_pos(a0)			; snap to floor
		
		subq.b	#1,ost_moto_smoke_time(a0)		; decrement time between smoke puffs
		bpl.w	DespawnObject				; branch if time remains
		move.b	#$F,ost_moto_smoke_time(a0)		; reset timer
		bsr.w	FindFreeObj				; find free OST slot
		bne.w	DespawnObject				; branch if not found
		move.l	#MotoSmoke,ost_id(a1)			; load exhaust smoke object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	ost_status(a0),ost_status(a1)
		move.b	#id_ani_moto_smoke,ost_anim(a1)
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	#priority_4,ost_priority(a1)
		move.b	#4,ost_displaywidth(a1)
		bra.w	DespawnObject
		
	.stop_here:
		addq.b	#2,ost_routine(a0)			; goto Moto_Wait next
		move.w	#59,ost_moto_wait_time(a0)		; set pause time to 1 second
		move.b	#id_frame_moto_2,ost_frame(a0)
		bra.w	DespawnObject
; ===========================================================================

Moto_Wait:	; Routine 4
		subq.w	#1,ost_moto_wait_time(a0)		; decrement wait timer
		bpl.w	DespawnObject				; branch if time remains
		subq.b	#2,ost_routine(a0)			; goto Moto_Walk next
		bchg	#status_xflip_bit,ost_status(a0)
		neg.w	ost_x_vel(a0)				; change direction
		bra.w	DespawnObject
		
; ---------------------------------------------------------------------------
; Moto Bug smoke (GHZ)

; spawned by:
;	MotoBug
; ---------------------------------------------------------------------------

MotoSmoke:
		lea	Ani_Moto(pc),a1
		bsr.w	AnimateSprite
		tst.b	ost_routine(a0)
		beq.w	DisplaySprite				; branch if animation isn't complete
		bra.w	DeleteObject				; delete when complete

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Moto:	index *
		ptr ani_moto_walk
		ptr ani_moto_smoke

ani_moto_walk:	dc.w 7
		dc.w id_frame_moto_0
		dc.w id_frame_moto_1
		dc.w id_frame_moto_0
		dc.w id_frame_moto_2
		dc.w id_Anim_Flag_Restart

ani_moto_smoke:	dc.w 1
		dc.w id_frame_moto_smoke1
		dc.w id_frame_moto_blank
		dc.w id_frame_moto_smoke1
		dc.w id_frame_moto_blank
		dc.w id_frame_moto_smoke2
		dc.w id_frame_moto_blank
		dc.w id_frame_moto_smoke2
		dc.w id_frame_moto_blank
		dc.w id_frame_moto_smoke2
		dc.w id_frame_moto_blank
		dc.w id_frame_moto_smoke3
		dc.w id_Anim_Flag_Routine
