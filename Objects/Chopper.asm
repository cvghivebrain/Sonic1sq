; ---------------------------------------------------------------------------
; Object 2B - Chopper enemy (GHZ)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2
; ---------------------------------------------------------------------------

Chopper:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Chop_Index(pc,d0.w),d1
		jmp	Chop_Index(pc,d1.w)
; ===========================================================================
Chop_Index:	index *,,2
		ptr Chop_Main
		ptr Chop_ChgSpeed

		rsobj Chopper
ost_chopper_y_start:	rs.w 1					; original y position (2 bytes)
		rsobjend
; ===========================================================================

Chop_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)
		move.l	#Map_Chop,ost_mappings(a0)
		move.w	(v_tile_chopper).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#id_col_12x16,ost_col_type(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.w	#-$700,ost_y_vel(a0)			; set vertical speed
		move.w	ost_y_pos(a0),ost_chopper_y_start(a0)	; save original position

Chop_ChgSpeed:	; Routine 2
		shortcut
		lea	Ani_Chop(pc),a1
		bsr.w	AnimateSprite
		update_y_fall	$18				; update position & apply gravity
		move.w	ost_chopper_y_start(a0),d1
		cmp.w	ost_y_pos(a0),d1			; has Chopper returned to its original position?
		bcc.s	.chganimation				; if not, branch
		move.w	d1,ost_y_pos(a0)
		move.w	#-$700,ost_y_vel(a0)			; set vertical speed

	.chganimation:
		moveq	#id_ani_chopper_fast,d0
		subi.w	#$C0,d1
		cmp.w	ost_y_pos(a0),d1
		bcc.s	.chkanim				; fast animation when chopper is above 192px of y start
		
		moveq	#id_ani_chopper_slow,d0
		tst.w	ost_y_vel(a0)
		bmi.s	.chkanim				; slow animation when below 192px and moving up
		
		moveq	#id_ani_chopper_still,d0		; stop animation when below 192px and moving down

	.chkanim:
		set_anim					; set new animation if different
		bra.w	DespawnObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Chop:	index *
		ptr ani_chopper_slow
		ptr ani_chopper_fast
		ptr ani_chopper_still
		
ani_chopper_slow:
		dc.w 7
		dc.w id_frame_chopper_shut
		dc.w id_frame_chopper_open
		dc.w id_Anim_Flag_Restart

ani_chopper_fast:
		dc.w 3
		dc.w id_frame_chopper_shut
		dc.w id_frame_chopper_open
		dc.w id_Anim_Flag_Restart

ani_chopper_still:
		dc.w 7
		dc.w id_frame_chopper_shut
		dc.w id_Anim_Flag_Restart
		even
