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
		ptr Moto_Action

		rsobj MotoBug
ost_moto_wait_time:	rs.w 1						; time delay before changing direction (2 bytes)
ost_moto_smoke_time:	rs.b 1						; time delay between smoke puffs
		rsobjend
; ===========================================================================

Moto_Main:	; Routine 0
		move.l	#Map_Moto,ost_mappings(a0)
		move.w	(v_tile_motobug).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#$14,ost_displaywidth(a0)
		move.b	#$E,ost_height(a0)
		move.b	#8,ost_width(a0)
		move.b	#id_col_20x16,ost_col_type(a0)
		update_y_fall					; apply gravity and update position
		jsr	(FindFloorObj).l
		tst.w	d1					; has motobug hit the floor?
		bpl.s	.notonfloor				; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.w	#0,ost_y_vel(a0)			; stop falling
		addq.b	#2,ost_routine(a0)			; goto Moto_Action next
		bchg	#status_xflip_bit,ost_status(a0)

	.notonfloor:
		rts
; ===========================================================================

Moto_Action:	; Routine 2
		shortcut
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		move.w	Moto_ActIndex(pc,d0.w),d1
		jsr	Moto_ActIndex(pc,d1.w)
		lea	Ani_Moto(pc),a1
		bsr.w	AnimateSprite
		bra.w	DespawnObject

; ===========================================================================
Moto_ActIndex:	index *
		ptr Moto_Move
		ptr Moto_FindFloor
; ===========================================================================

Moto_Move:
		subq.w	#1,ost_moto_wait_time(a0)		; decrement wait timer
		bpl.s	.wait					; if time remains, branch
		addq.b	#2,ost_mode(a0)				; goto Moto_FindFloor next
		move.w	#-$100,ost_x_vel(a0)			; move object to the left
		move.b	#id_ani_moto_walk,ost_anim(a0)
		bchg	#status_xflip_bit,ost_status(a0)
		bne.s	.wait
		neg.w	ost_x_vel(a0)				; change direction

	.wait:
		rts	
; ===========================================================================

Moto_FindFloor:
		update_x_pos					; update position
		jsr	(FindFloorObj).l			; d1 = distance to floor
		cmpi.w	#-8,d1
		blt.s	.pause
		cmpi.w	#$C,d1
		bge.s	.pause					; branch if object is more than 11px above or 8px below floor

		add.w	d1,ost_y_pos(a0)			; align to floor
		subq.b	#1,ost_moto_smoke_time(a0)		; decrement time between smoke puffs
		bpl.s	.nosmoke				; branch if time remains
		move.b	#$F,ost_moto_smoke_time(a0)		; reset timer
		bsr.w	FindFreeObj				; find free OST slot
		bne.s	.nosmoke				; branch if not found
		move.l	#MotoSmoke,ost_id(a1)			; load exhaust smoke object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	ost_status(a0),ost_status(a1)
		move.b	#id_ani_moto_smoke,ost_anim(a1)
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	#4,ost_priority(a1)
		move.b	#4,ost_displaywidth(a1)

	.nosmoke:
		rts	

.pause:
		subq.b	#2,ost_mode(a0)				; goto Moto_Move next
		move.w	#59,ost_moto_wait_time(a0)		; set pause time to 1 second
		move.w	#0,ost_x_vel(a0)			; stop the object moving
		move.b	#id_ani_moto_stand,ost_anim(a0)
		rts	
		
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
		ptr ani_moto_stand
		ptr ani_moto_walk
		ptr ani_moto_smoke

ani_moto_stand:	dc.w $F
		dc.w id_frame_moto_2
		dc.w id_Anim_Flag_Restart

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
