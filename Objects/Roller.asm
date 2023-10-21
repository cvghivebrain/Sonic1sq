; ---------------------------------------------------------------------------
; Object 43 - Roller enemy (SYZ)

; spawned by:
;	ObjPos_SYZ1, ObjPos_SYZ2
; ---------------------------------------------------------------------------

Roller:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Roll_Index(pc,d0.w),d1
		jmp	Roll_Index(pc,d1.w)
; ===========================================================================
Roll_Index:	index *,,2
		ptr Roll_Main
		ptr Roll_Action

		rsobj Roller
ost_roller_open_time:	rs.w 1					; time roller stays open for (2 bytes)
ost_roller_mode:	rs.b 1					; +1 = roller has jumped; +$80 = roller has stopped
		rsobjend
; ===========================================================================

Roll_Main:	; Routine 0
		move.b	#$E,ost_height(a0)
		move.b	#8,ost_width(a0)
		update_y_fall					; apply gravity and update position
		bsr.w	FindFloorObj
		tst.w	d1					; has roller hit the floor?
		bpl.s	.no_floor				; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.w	#0,ost_y_vel(a0)			; stop falling
		addq.b	#2,ost_routine(a0)			; goto Roll_Action next
		move.l	#Map_Roll,ost_mappings(a0)
		move.w	(v_tile_roller).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)

	.no_floor:
		rts	
; ===========================================================================

Roll_Action:	; Routine 2
		getsonic					; a1 = OST of Sonic
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		move.w	Roll_Index2(pc,d0.w),d1
		jsr	Roll_Index2(pc,d1.w)
		lea	(Ani_Roll).l,a1
		bsr.w	AnimateSprite
		bra.w	DespawnObject
; ===========================================================================
Roll_Index2:	index *,,2
		ptr Roll_RollChk
		ptr Roll_Stopped
		ptr Roll_ChkJump
		ptr Roll_JumpLand
; ===========================================================================

Roll_RollChk:
		move.w	ost_x_pos(a1),d0
		subi.w	#$100,d0				; d0 = Sonic's x position minus $100
		bcs.s	.hide					; branch if Sonic is < 256px from left edge of level
		sub.w	ost_x_pos(a0),d0			; is Sonic > 256px left of the roller?
		bcs.s	.hide					; if not, branch
		move.b	#id_Roll_ChkJump,ost_mode(a0)		; goto Roll_ChkJump next
		move.b	#id_ani_roll_roll,d0			; use roller's rolling animation
		set_anim
		move.w	#$700,ost_x_vel(a0)			; move roller to the right
		move.b	#id_col_14x14+id_col_hurt,ost_col_type(a0) ; make roller invincible

	.hide:
		addq.l	#4,sp					; don't animate or display roller
		rts	
; ===========================================================================

Roll_Stopped:
		btst	#1,ost_anim(a0)				; is roller still rolling?
		bne.s	.is_rolling				; if yes, branch
		subq.w	#1,ost_roller_open_time(a0)		; decrement timer
		bpl.s	.wait					; branch if time remains
		move.b	#id_ani_roll_fold,d0			; use curling animation
		set_anim
		move.w	#$700,ost_x_vel(a0)			; move roller right
		move.b	#id_col_14x14+id_col_hurt,ost_col_type(a0) ; make roller invincible

	.wait:
		rts	
; ===========================================================================

.is_rolling:
		move.b	#id_Roll_ChkJump,ost_mode(a0)		; goto Roll_ChkJump next
		rts	
; ===========================================================================

Roll_ChkJump:
		tst.b	ost_roller_mode(a0)			; has roller already stopped?
		bmi.s	.skip_stop				; if yes, branch
		move.w	ost_x_pos(a1),d0
		subi.w	#$30,d0
		sub.w	ost_x_pos(a0),d0
		bcc.s	.skip_stop				; branch if Sonic is > 48px left of the roller
		move.b	#id_ani_roll_unfold,d0
		set_anim
		move.b	#id_col_14x14,ost_col_type(a0)
		clr.w	ost_x_vel(a0)				; stop roller moving
		move.w	#120,ost_roller_open_time(a0)		; set waiting time to 2 seconds
		move.b	#id_Roll_Stopped,ost_mode(a0)		; goto Roll_Stopped next
		bset	#7,ost_roller_mode(a0)			; set flag for roller stopped

	.skip_stop:
		update_x_pos					; update position
		bsr.w	FindFloorObj
		cmpi.w	#-8,d1
		blt.s	Roll_Jump				; branch if more than 8px below floor
		cmpi.w	#$C,d1
		bge.s	Roll_Jump				; branch if more than 11px above floor (also detects a ledge)
		add.w	d1,ost_y_pos(a0)			; align to floor
		rts	
; ===========================================================================

Roll_Jump:
		move.b	#id_Roll_JumpLand,ost_mode(a0)		; goto Roll_JumpLand next
		bset	#0,ost_roller_mode(a0)			; set jump flag
		beq.s	.dont_jump				; branch if previously 0 (jumps on next frame instead)
		move.w	#-$600,ost_y_vel(a0)			; move roller upwards

	.dont_jump:
		rts	
; ===========================================================================

Roll_JumpLand:
		update_xy_fall					; apply gravity and update position
		bmi.s	.exit					; branch if moving upwards
		bsr.w	FindFloorObj
		tst.w	d1					; has roller hit the floor?
		bpl.s	.exit					; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.b	#id_Roll_ChkJump,ost_mode(a0)		; goto Roll_ChkJump next
		move.w	#0,ost_y_vel(a0)			; stop falling

	.exit:
		rts

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Roll:	index *
		ptr ani_roll_unfold
		ptr ani_roll_fold
		ptr ani_roll_roll
		
ani_roll_unfold:
		dc.w $F
		dc.w id_frame_roll_roll1
		dc.w id_frame_roll_fold
		dc.w id_frame_roll_stand
		dc.w id_Anim_Flag_Stop
		
ani_roll_fold:	dc.w $F
		dc.w id_frame_roll_fold
		dc.w id_frame_roll_roll1
		dc.w id_Anim_Flag_Change, id_ani_roll_roll
		
ani_roll_roll:	dc.w 3
		dc.w id_frame_roll_roll2
		dc.w id_frame_roll_roll3
		dc.w id_frame_roll_roll1
		dc.w id_Anim_Flag_Restart
