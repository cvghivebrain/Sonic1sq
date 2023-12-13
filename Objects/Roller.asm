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
		ptr Roll_Hide
		ptr Roll_Roll
		ptr Roll_Jump
		ptr Roll_Stop
		ptr Roll_Wait
		ptr Roll_Resume

		rsobj Roller
ost_roller_open_time:	rs.w 1					; time roller stays open for
ost_roller_stopped:	rs.b 1					; flag set when roller has stopped in front of Sonic
		rsobjend
; ===========================================================================

Roll_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Roll_Hide next
		move.l	#Map_Roll,ost_mappings(a0)
		move.w	(v_tile_roller).w,ost_tile(a0)
		move.b	#render_rel+render_onscreen,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#$E,ost_height(a0)
		move.b	#8,ost_width(a0)
		bra.w	SnapFloor
; ===========================================================================

Roll_Hide:	; Routine 2
		getsonic					; a1 = OST of Sonic
		btst	#status_xflip_bit,ost_status(a0)
		bne.s	.left					; branch if roller is facing left
		range_x_quick
		bmi.w	DespawnObject_NoDisplay			; branch if Sonic is to the left
		cmpi.w	#256,d0
		bcs.w	DespawnObject_NoDisplay			; branch if Sonic is within 256px
		addq.b	#2,ost_routine(a0)			; goto Roll_Roll next
		move.b	#id_ani_roll_roll,ost_anim(a0)
		move.w	#$700,ost_x_vel(a0)			; move roller right
		move.b	#id_col_14x14+id_col_hurt,ost_col_type(a0) ; make roller invincible
		bra.s	Roll_Roll
		
	.left:
		range_x_quick
		bpl.w	DespawnObject_NoDisplay			; branch if Sonic is to the right
		cmpi.w	#-256,d0
		bgt.w	DespawnObject_NoDisplay			; branch if Sonic is within 256px
		addq.b	#2,ost_routine(a0)			; goto Roll_Roll next
		move.b	#id_ani_roll_roll,ost_anim(a0)
		move.w	#-$700,ost_x_vel(a0)			; move roller left
		move.b	#id_col_14x14+id_col_hurt,ost_col_type(a0) ; make roller invincible

Roll_Roll:	; Routine 4
		lea	Ani_Roll(pc),a1
		bsr.w	AnimateSprite
		update_x_pos					; move left/right
		
		tst.b	ost_roller_stopped(a0)
		bne.s	.skip_stop				; branch if roller previously stopped
		getsonic					; a1 = OST of Sonic
		range_x
		cmpi.w	#48,d1
		bhi.s	.skip_stop				; branch if Sonic is > 48px away
		move.b	#id_ani_roll_unfold,ost_anim(a0)
		move.b	#id_col_14x14,ost_col_type(a0)		; make roller killable
		move.w	#120,ost_roller_open_time(a0)		; set waiting time to 2 seconds
		move.b	#id_Roll_Stop,ost_routine(a0)		; goto Roll_Stop next
		move.b	#1,ost_roller_stopped(a0)		; set flag for roller stopped
		bra.w	DespawnObject

	.skip_stop:
		bsr.w	FindFloorObj
		cmpi.w	#-8,d1
		blt.s	.jump					; branch if more than 8px below floor
		cmpi.w	#$C,d1
		bge.s	.jump					; branch if more than 11px above floor (also detects a ledge)
		add.w	d1,ost_y_pos(a0)			; align to floor
		bra.w	DespawnObject
		
	.jump:
		move.w	#-$600,ost_y_vel(a0)
		addq.b	#2,ost_routine(a0)			; goto Roll_Jump next
		bra.w	DespawnObject
; ===========================================================================

Roll_Jump:	; Routine 6
		lea	Ani_Roll(pc),a1
		bsr.w	AnimateSprite
		update_xy_fall					; apply gravity & update position
		bmi.w	DespawnObject				; branch if moving upwards
		bsr.w	FindFloorObj
		tst.w	d1					; has roller hit the floor?
		bpl.w	DespawnObject				; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		move.b	#id_Roll_Roll,ost_routine(a0)		; goto Roll_Roll next
		move.w	#0,ost_y_vel(a0)			; stop falling
		bra.w	DespawnObject
; ===========================================================================

Roll_Stop:	; Routine 8
		lea	Ani_Roll(pc),a1				; animate & goto Roll_Wait next
		bsr.w	AnimateSprite
		bra.w	DespawnObject
; ===========================================================================

Roll_Wait:	; Routine $A
		subq.w	#1,ost_roller_open_time(a0)		; decrement timer
		bpl.w	DespawnObject				; branch if time remains
		move.b	#id_ani_roll_fold,ost_anim(a0)
		addq.b	#2,ost_routine(a0)			; goto Roll_Resume next

Roll_Resume:	; Routine $C
		lea	Ani_Roll(pc),a1
		bsr.w	AnimateSprite
		cmpi.b	#id_ani_roll_roll,ost_anim(a0)
		bne.w	DespawnObject				; branch if still folding
		move.b	#id_Roll_Roll,ost_routine(a0)		; goto Roll_Roll next
		move.b	#id_col_14x14+id_col_hurt,ost_col_type(a0) ; make roller invincible
		bra.w	DespawnObject

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
		dc.w id_Anim_Flag_Routine
		
ani_roll_fold:	dc.w $F
		dc.w id_frame_roll_fold
		dc.w id_frame_roll_roll1
		dc.w id_Anim_Flag_Change, id_ani_roll_roll
		
ani_roll_roll:	dc.w 3
		dc.w id_frame_roll_roll2
		dc.w id_frame_roll_roll3
		dc.w id_frame_roll_roll1
		dc.w id_Anim_Flag_Restart
