; ---------------------------------------------------------------------------
; Object 50 - Yadrin enemy (SYZ)

; spawned by:
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3
; ---------------------------------------------------------------------------

Yadrin:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Yad_Index(pc,d0.w),d1
		jmp	Yad_Index(pc,d1.w)
; ===========================================================================
Yad_Index:	index *,,2
		ptr Yad_Main
		ptr Yad_Walk
		ptr Yad_Wait

		rsobj Yadrin
ost_yadrin_wait_time:	rs.w 1					; time to wait before changing direction
		rsobjend
		
yadrin_height:	equ $11
; ===========================================================================

Yad_Main:	; Routine 0
		move.b	#yadrin_height,ost_height(a0)
		move.b	#$14,ost_width(a0)
		move.l	#Map_Yad,ost_mappings(a0)
		move.w	(v_tile_yadrin).w,ost_tile(a0)
		addi.w	#tile_pal2,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_4,ost_priority(a0)
		move.b	#$14,ost_displaywidth(a0)
		move.b	#id_React_Yadrin,ost_col_type(a0)
		move.b	#20,ost_col_width(a0)
		move.b	#16,ost_col_height(a0)
		addq.b	#2,ost_routine(a0)			; goto Yad_Walk next
		move.w	#-$100,ost_x_vel(a0)			; move yadrin left
		btst	#status_xflip_bit,ost_status(a0)
		beq.w	SnapFloor
		neg.w	ost_x_vel(a0)				; move right if xflipped
		bra.w	SnapFloor				; align with floor
; ===========================================================================

Yad_Walk:	; Routine 2
		update_x_pos					; move left or right
		getpos_bottom yadrin_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		bsr.w	FloorDist
		cmpi.w	#-8,d5
		blt.s	.stop_now				; branch if > 8px below floor
		cmpi.w	#$C,d5
		bge.s	.stop_now				; branch if > 11px above floor (also detects a ledge)
		add.w	d5,ost_y_pos(a0)			; align to floor
		
		move.w	(v_frame_counter).w,d0			; get word that increments every frame
		add.w	d7,d0					; add OST id (so that multiple yadrins don't do wall check on the same frame)
		andi.w	#3,d0					; read only bits 0-1
		bne.s	.skip_wall				; branch if either are set
		tst.w	ost_x_vel(a0)				; is yadrin moving to the left?
		bmi.s	.moving_left				; if yes, branch
		bsr.w	FindWallRightObj
		tst.w	d1					; has yadrin hit wall to the right?
		bmi.s	.stop_now				; if yes, branch
		bra.s	.skip_wall
	.moving_left:
		bsr.w	FindWallLeftObj
		tst.w	d1					; has yadrin hit wall to the left?
		bmi.s	.stop_now				; if yes, branch
		
	.skip_wall:
		lea	Ani_Yad(pc),a1
		bsr.w	AnimateSprite
		bra.w	DespawnObject
		
	.stop_now:
		addq.b	#2,ost_routine(a0)			; goto Yad_Wait next
		move.w	#59,ost_yadrin_wait_time(a0)		; set wait time to 1 second
		move.b	#id_frame_yadrin_walk0,ost_frame(a0)
		
Yad_Wait:	; Routine 6
		subq.w	#1,ost_yadrin_wait_time(a0)		; decrement timer
		bpl.w	DespawnObject				; if time remains, branch
		bchg	#status_xflip_bit,ost_status(a0)
		bchg	#render_xflip_bit,ost_render(a0)
		neg.w	ost_x_vel(a0)				; change direction
		subq.b	#2,ost_routine(a0)			; goto Yad_Walk next
		bra.w	DespawnObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Yad:	index *
		ptr ani_yadrin_walk

ani_yadrin_walk:
		dc.w 7
		dc.w id_frame_yadrin_walk0
		dc.w id_frame_yadrin_walk3
		dc.w id_frame_yadrin_walk1
		dc.w id_frame_yadrin_walk4
		dc.w id_frame_yadrin_walk0
		dc.w id_frame_yadrin_walk3
		dc.w id_frame_yadrin_walk2
		dc.w id_frame_yadrin_walk5
		dc.w id_Anim_Flag_Restart
