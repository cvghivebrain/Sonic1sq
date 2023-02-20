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
		ptr Splats_Action
		ptr Splats_ChkFloor
		ptr Splats_Delete
; ---------------------------------------------------------------------------

Splats_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Splats_Action next
		move.l	#Map_Splats,ost_mappings(a0)
		move.w	(v_tile_splats).w,ost_tile(a0)
		add.w	#tile_pal2,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#$C,ost_displaywidth(a0)
		move.b	#$C,ost_width(a0)
		move.b	#$14,ost_height(a0)
		move.b	#id_col_12x20,ost_col_type(a0)
		tst.b	ost_subtype(a0)
		beq.s	Splats_Action				; branch if subtype is 0
		move.w	#768,d2
		bra.s	Splats_Action2
; ---------------------------------------------------------------------------

Splats_Action:	; Routine 2
		move.w	#224,d2

Splats_Action2:
		move.w	#$100,d1				; x vel of Splats when he moves
		bset	#render_xflip_bit,ost_render(a0)
		move.w	(v_ost_player+ost_x_pos).w,d0
		sub.w	ost_x_pos(a0),d0			; d0 = x dist between Sonic and Splats
		bcc.s	.sonic_is_right				; branch if Sonic is to the right
		neg.w	d0					; make d0 +ve
		neg.w	d1
		bclr	#render_xflip_bit,ost_render(a0)

	.sonic_is_right:
		cmp.w	d2,d0
		bcc.s	Splats_ChkFloor				; branch if Sonic is > 224px away
		move.w	d1,ost_x_vel(a0)			; start Splats moving toward Sonic
		addq.b	#2,ost_routine(a0)			; goto Splats_ChkFloor next

Splats_ChkFloor:	; Routine 4
		jsr	ObjectFall				; apply gravity & update position
		move.b	#id_frame_splats_jump,ost_frame(a0)
		tst.w	ost_y_vel(a0)
		bmi.s	.chk_walls				; branch if Splats is moving up
		move.b	#id_frame_splats_fall,ost_frame(a0)
		bsr.w	FindFloorObj
		tst.w	d1
		bpl.s	.chk_walls				; branch if Splats is above the floor
		move.w	(a1),d0					; get 16x16 tile id that Splats is touching
		andi.w	#$3FF,d0				; id only
		cmpi.w	#$2D2,d0
		bcs.s	.hit_floor				; branch if tile is 0-$2D2
		addq.b	#2,ost_routine(a0)			; goto Splats_Delete next
		bra.s	.chk_walls
; ---------------------------------------------------------------------------

.hit_floor:
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.w	#-$400,ost_y_vel(a0)			; bounce

.chk_walls:
		bsr.w	Splats_ChkWalls
		beq.s	.no_walls				; branch if no wall found
		neg.w	ost_x_vel(a0)				; reverse direction
		bchg	#render_xflip_bit,ost_render(a0)	; xflip Splats
		bchg	#status_xflip_bit,ost_status(a0)

	.no_walls:
		bra.w	DespawnObject				; display or despawn
; ---------------------------------------------------------------------------

Splats_Delete:	; Routine 6 (unused)
		jsr	ObjectFall				; apply gravity & update position
		jsr	DisplaySprite
		tst.b	ost_render(a0)
		bmi.s	.exit					; branch if Splats is on screen
		jmp	DeleteObject				; delete if not
		
	.exit:
		rts
		
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
		bsr.w	FindWallRightObj
		tst.w	d1
		bpl.s	.no_wall				; branch if Splat hasn't hit wall

.found_wall:
		moveq	#1,d0
		rts
; ---------------------------------------------------------------------------

.moving_left:
		bsr.w	FindWallLeftObj
		tst.w	d1
		bmi.s	.found_wall

.no_wall:
		moveq	#0,d0
		rts
		