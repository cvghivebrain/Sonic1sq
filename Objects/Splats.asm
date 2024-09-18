; ---------------------------------------------------------------------------
; Splats enemy

; spawned by:
;	ObjPos_MZ3
; ---------------------------------------------------------------------------

Splats:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Splats_Index(pc,d0.w),d1
		jmp	Splats_Index(pc,d1.w)
; ---------------------------------------------------------------------------
Splats_Index:	index *,,2
		ptr Splats_Main
		ptr Splats_ChkDist
		ptr Splats_Move
		
splats_width:	equ $C
splats_height:	equ $14
; ---------------------------------------------------------------------------

Splats_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Splats_ChkDist next
		move.l	#Map_Splats,ost_mappings(a0)
		move.w	(v_tile_splats).w,ost_tile(a0)
		addi.w	#tile_pal2,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_4,ost_priority(a0)
		move.b	#$C,ost_displaywidth(a0)
		move.b	#$C,ost_width(a0)
		move.b	#splats_height,ost_height(a0)
		move.b	#id_React_Enemy,ost_col_type(a0)
		move.b	#12,ost_col_width(a0)
		move.b	#20,ost_col_height(a0)

Splats_ChkDist:	; Routine 2
		getsonic					; a1 = OST of Sonic
		range_x_quick
		bmi.s	.sonic_left				; branch if Sonic is to the left
		cmpi.w	#244,d0
		bcc.w	DespawnQuick				; branch if Sonic is > 224px away
		bset	#render_xflip_bit,ost_render(a0)	; face right
		move.w	#$100,ost_x_vel(a0)			; move right
		addq.b	#2,ost_routine(a0)			; goto Splats_Move next
		bra.s	Splats_Move
		
	.sonic_left:
		bclr	#render_xflip_bit,ost_render(a0)	; face left
		move.w	#-$100,ost_x_vel(a0)			; move left
		addq.b	#2,ost_routine(a0)			; goto Splats_Move next

Splats_Move:	; Routine 4
		shortcut
		update_xy_fall					; apply gravity & update position
		move.b	#id_frame_splats_jump,ost_frame(a0)
		tst.w	ost_y_vel(a0)
		bmi.s	.chk_walls				; branch if Splats is moving up
		move.b	#id_frame_splats_fall,ost_frame(a0)
		getpos_bottom splats_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		bsr.w	FloorDist
		tst.w	d5
		bpl.s	.chk_walls				; branch if Splats is above the floor
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.w	#-$400,ost_y_vel(a0)			; bounce

	.chk_walls:
		bsr.s	Splats_ChkWalls
		beq.w	DespawnObject				; branch if no wall found
		neg.w	ost_x_vel(a0)				; reverse direction
		bchg	#render_xflip_bit,ost_render(a0)	; xflip Splats
		bchg	#status_xflip_bit,ost_status(a0)
		bra.w	DespawnObject				; display or despawn
		
; ---------------------------------------------------------------------------
; Subroutine to detect collision with walls

; output:
;	d0.l = 1 when wall is found; 0 otherwise
;	d1.w = distance to wall
; ---------------------------------------------------------------------------

Splats_ChkWalls:
		move.w	(v_frame_counter).w,d0
		add.w	d7,d0
		andi.w	#3,d0					; subroutine only runs every 4th frame (different for each Splats)
		bne.s	.no_wall				; branch if not on specific frame
		tst.w	ost_x_vel(a0)
		bmi.s	.moving_left				; branch if Splats is moving left
		getpos_right splats_width			; d0 = x pos of right; d1 = y pos
		moveq	#1,d6
		bsr.w	WallRightDist
		tst.w	d5
		bpl.s	.no_wall				; branch if Splats hasn't hit wall

.found_wall:
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------

.moving_left:
		getpos_left splats_width			; d0 = x pos of left; d1 = y pos
		moveq	#1,d6
		bsr.w	WallLeftDist
		tst.w	d5
		bmi.s	.found_wall

.no_wall:
		moveq	#0,d0
		rts
		
