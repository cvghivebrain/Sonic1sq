; ---------------------------------------------------------------------------
; Object 2D - Burrobot enemy (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3, ObjPos_SBZ3
; ---------------------------------------------------------------------------

Burrobot:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Burro_Index(pc,d0.w),d1
		jmp	Burro_Index(pc,d1.w)
; ===========================================================================
Burro_Index:	index *,,2
		ptr Burro_Main
		ptr Burro_Action

		rsobj Burrobot
ost_burro_turn_time:		rs.w 1				; time between direction changes (2 bytes)
ost_burro_findfloor_flag:	rs.b 1				; flag set every other frame to detect edge of floor
		rsobjend
; ===========================================================================

Burro_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)
		move.b	#$13,ost_height(a0)
		move.b	#8,ost_width(a0)
		move.l	#Map_Burro,ost_mappings(a0)
		move.w	(v_tile_burrobot).w,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#id_col_12x18,ost_col_type(a0)
		move.b	#$C,ost_displaywidth(a0)
		move.b	#id_Burro_ChkSonic,ost_mode(a0)		; goto Burro_ChkSonic after Burro_Action
		move.b	#id_ani_burro_digging,ost_anim(a0)

Burro_Action:	; Routine 2
		shortcut
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		move.w	Burro_Action_Index(pc,d0.w),d1
		jsr	Burro_Action_Index(pc,d1.w)
		lea	(Ani_Burro).l,a1
		bsr.w	AnimateSprite
		bra.w	DespawnObject
; ===========================================================================
Burro_Action_Index:
		index *,,2
		ptr Burro_ChangeDir
		ptr Burro_Move
		ptr Burro_Jump
		ptr Burro_ChkSonic
; ===========================================================================

Burro_ChangeDir:
		subq.w	#1,ost_burro_turn_time(a0)		; decrement timer
		bpl.s	.nochg					; branch if time remains
		addq.b	#2,ost_mode(a0)				; goto Burro_Move next
		move.w	#255,ost_burro_turn_time(a0)		; time until turn (4.2ish seconds)
		move.w	#$80,ost_x_vel(a0)
		move.b	#id_ani_burro_walk2,ost_anim(a0)
		bchg	#status_xflip_bit,ost_status(a0)	; change xflip flag
		beq.s	.nochg					; branch if xflip was 0
		neg.w	ost_x_vel(a0)				; change direction

	.nochg:
		rts	
; ===========================================================================

Burro_Move:
		subq.w	#1,ost_burro_turn_time(a0)		; decrement turning timer
		bmi.s	Burro_Move_Turn				; branch if time runs out

		update_x_pos					; update position
		bchg	#0,ost_burro_findfloor_flag(a0)		; change floor flag
		bne.s	.find_floor				; branch if it was 1
		move.w	ost_x_pos(a0),d3
		addi.w	#12,d3					; find floor to the right
		btst	#status_xflip_bit,ost_status(a0)	; is burrobot xflipped?
		bne.s	.is_flipped				; if yes, branch
		subi.w	#24,d3					; find floor to the left

	.is_flipped:
		jsr	(FindFloorObj2).l			; find floor to left or right
		cmpi.w	#12,d1					; is floor 12 or more px away?
		bge.s	Burro_Move_Turn				; if yes, branch
		rts	
; ===========================================================================

.find_floor:
		jsr	(FindFloorObj).l
		add.w	d1,ost_y_pos(a0)			; align to floor
		rts	
; ===========================================================================

Burro_Move_Turn:
		btst	#2,(v_vblank_counter_byte).w		; test bit that changes every 4 frames
		beq.s	.jump_instead				; branch if 0
		subq.b	#2,ost_mode(a0)				; goto Burro_ChangeDir next
		move.w	#59,ost_burro_turn_time(a0)		; set timer to 1 second
		move.w	#0,ost_x_vel(a0)			; stop moving
		move.b	#id_ani_burro_walk1,ost_anim(a0)
		rts	
; ===========================================================================

.jump_instead:
		addq.b	#2,ost_mode(a0)				; goto Burro_Jump next
		move.w	#-$400,ost_y_vel(a0)			; jump upwards
		move.b	#id_ani_burro_digging,ost_anim(a0)
		rts	
; ===========================================================================

Burro_Jump:
		update_xy_fall	$18				; update position & apply gravity
		bmi.s	.exit					; branch if burrobot is moving upwards

		move.b	#id_ani_burro_fall,ost_anim(a0)
		jsr	(FindFloorObj).l
		tst.w	d1					; has burrobot hit the floor?
		bpl.s	.exit					; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.w	#0,ost_y_vel(a0)			; stop falling
		move.b	#id_ani_burro_walk2,ost_anim(a0)
		move.w	#255,ost_burro_turn_time(a0)		; time until turn (4.2ish seconds)
		subq.b	#2,ost_mode(a0)				; goto Burro_Move next
		bset	#status_xflip_bit,ost_status(a0)
		getsonic
		range_x
		tst.w	d0
		bpl.s	.exit					; branch if Sonic is to the right
		bclr	#status_xflip_bit,ost_status(a0)

	.exit:
		rts	
; ===========================================================================

Burro_ChkSonic:
		getsonic
		range_x
		cmp.w	#$60,d1
		bcc.s	.exit					; branch if Sonic is > $60px away
		range_y
		tst.w	d2
		bpl.s	.exit					; branch if Sonic is below
		cmp.w	#$80,d3
		bcc.s	.exit					; branch if Sonic is > $80px above
		tst.w	(v_debug_active).w
		bne.s	.exit					; branch if debug mode is on
		
		subq.b	#2,ost_mode(a0)				; goto Burro_Jump next
		move.w	#-$400,ost_y_vel(a0)			; burrobot jumps
		bset	#status_xflip_bit,ost_status(a0)
		move.w	#$80,ost_x_vel(a0)
		tst.w	d0
		bpl.s	.exit					; branch if Sonic is to the right
		bclr	#status_xflip_bit,ost_status(a0)
		move.w	#-$80,ost_x_vel(a0)

	.exit:
		rts	

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Burro:	index *
		ptr ani_burro_walk1
		ptr ani_burro_walk2
		ptr ani_burro_digging
		ptr ani_burro_fall
		
ani_burro_walk1:
		dc.w 3
		dc.w id_frame_burro_walk1
		dc.w id_frame_burro_walk3
		dc.w id_Anim_Flag_Restart

ani_burro_walk2:
		dc.w 3
		dc.w id_frame_burro_walk1
		dc.w id_frame_burro_walk2
		dc.w id_Anim_Flag_Restart

ani_burro_digging:
		dc.w 3
		dc.w id_frame_burro_dig1
		dc.w id_frame_burro_dig2
		dc.w id_Anim_Flag_Restart

ani_burro_fall:
		dc.w 3
		dc.w id_frame_burro_fall
		dc.w id_Anim_Flag_Restart
		even
