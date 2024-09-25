; ---------------------------------------------------------------------------
; Object 47 - pinball bumper (SYZ)

; spawned by:
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3
; ---------------------------------------------------------------------------

Bumper:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Bump_Index(pc,d0.w),d1
		jmp	Bump_Index(pc,d1.w)
; ===========================================================================
Bump_Index:	index *,,2
		ptr Bump_Main
		ptr Bump_Detect
		ptr Bump_Animate
		ptr Bump_Reset

		rsobj Bumper
ost_bump_count:	rs.b 1						; number of times bumper has been hit
		rsobjend
; ===========================================================================

Bump_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Bump_Detect next
		move.l	#Map_Bump,ost_mappings(a0)
		move.w	(v_tile_bumper).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#StrId_Bumper,ost_name(a0)
		move.w	#priority_1,ost_priority(a0)
		move.b	#id_React_Bumper,ost_col_type(a0)
		move.b	#8,ost_col_width(a0)
		move.b	#8,ost_col_height(a0)
		bsr.w	GetState				; d0 = hit count
		move.b	d0,ost_bump_count(a0)

Bump_Detect:	; Routine 2
		tst.b	ost_col_property(a0)			; has Sonic touched the bumper?
		beq.w	DespawnObject				; if not, branch
		addq.b	#2,ost_routine(a0)			; goto Bump_Animate next

Bump_Hit:
		clr.b	ost_col_property(a0)
		getsonic					; a1 = OST of Sonic
		move.w	ost_x_pos(a0),d1
		move.w	ost_y_pos(a0),d2
		sub.w	ost_x_pos(a1),d1			; get distance betwen Sonic & bumper
		sub.w	ost_y_pos(a1),d2
		jsr	(CalcAngle).w				; convert to angle
		jsr	(CalcSine).w				; convert to sine/cosine
		muls.w	#-bumper_power,d1
		asr.l	#8,d1
		move.w	d1,ost_x_vel(a1)			; bounce Sonic away
		muls.w	#-bumper_power,d0
		asr.l	#8,d0
		move.w	d0,ost_y_vel(a1)			; bounce Sonic away
		bset	#status_air_bit,ost_status(a1)
		bclr	#status_rolljump_bit,ost_status(a1)
		bclr	#status_pushing_bit,ost_status(a1)
		move.b	#id_ani_bump_bumped,ost_anim(a0)	; use "hit" animation
		play.w	1, jsr, sfx_Bumper			; play bumper sound
		move.b	ost_bump_count(a0),d2
		cmpi.b	#10,d2
		beq.w	DespawnObject				; branch if bumper has been hit 10 times
		addq.b	#1,d2					; increment counter
		move.b	d2,ost_bump_count(a0)			; update counter
		moveq	#1,d0
		jsr	(AddPoints).w				; add 10 to score
		bsr.w	FindFreeObj
		bne.s	.skip_points
		move.l	#Points,ost_id(a1)			; load points object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	#id_frame_points_10,ost_frame(a1)
		
	.skip_points:
		bsr.w	SaveState
		beq.w	DespawnObject				; branch if not in respawn table
		ori.b	#$80,d2					; set high bit of hit count
		move.b	d2,(a2)					; save hit count to respawn table
		bra.w	DespawnObject
; ===========================================================================

Bump_Animate:	; Routine 4
		lea	Ani_Bump(pc),a1
		bsr.w	AnimateSprite				; animate & goto Bump_Reset when done
		tst.b	ost_col_property(a0)			; has Sonic touched the bumper?
		beq.w	DespawnObject				; if not, branch
		bra.w	Bump_Hit
; ===========================================================================

Bump_Reset:	; Routine 6
		move.b	#id_frame_bump_normal,ost_frame(a0)
		move.b	#id_Bump_Detect,ost_routine(a0)		; goto Bump_Detect next
		bra.w	Bump_Detect

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Bump:	index *
		ptr ani_bump_bumped
		
ani_bump_bumped:
		dc.w 3
		dc.w id_frame_bump_bumped1
		dc.w id_frame_bump_bumped2
		dc.w id_frame_bump_bumped1
		dc.w id_frame_bump_bumped2
		dc.w id_Anim_Flag_Routine
