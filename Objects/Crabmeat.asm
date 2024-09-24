; ---------------------------------------------------------------------------
; Object 1F - Crabmeat enemy (GHZ, SYZ)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3 
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3

; subtypes:
;	%I000TTTT
;	I = 1 to ignore slopes
;	TTTT = type (see Crab_Settings)
; ---------------------------------------------------------------------------

Crabmeat:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Crab_Index(pc,d0.w),d1
		jmp	Crab_Index(pc,d1.w)
; ===========================================================================
Crab_Index:	index *,,2
		ptr Crab_Main
		ptr Crab_Move
		ptr Crab_Wait
		ptr Crab_Fire

		rsobj Crabmeat
ost_crab_time:		rs.w 1					; time until next action
ost_crab_walk_time:	rs.w 1					; time spent walking
		rsobjend
		
crab_width:	equ 8
crab_height:	equ $10
		
Crab_Settings:	dc.w 127, 128					; walk time (in frames), walk speed
; ===========================================================================

Crab_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Crab_Move next
		move.b	#crab_height,ost_height(a0)
		move.b	#crab_width,ost_width(a0)
		move.l	#Map_Crab,ost_mappings(a0)
		move.w	(v_tile_crabmeat).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_3,ost_priority(a0)
		move.b	#id_React_Enemy,ost_col_type(a0)
		move.b	#16,ost_col_width(a0)
		move.b	#16,ost_col_height(a0)
		move.b	#$15,ost_displaywidth(a0)
		move.b	#StrId_Crabmeat,ost_name(a0)
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0					; read low nybble of subtype
		lsl.b	#2,d0					; multiply by 4
		lea	Crab_Settings(pc,d0.w),a2
		move.w	(a2)+,ost_crab_walk_time(a0)
		move.w	ost_crab_walk_time(a0),ost_crab_time(a0)
		move.w	(a2)+,ost_x_vel(a0)
		btst	#status_xflip_bit,ost_status(a0)
		bne.s	.noflip
		neg.w	ost_x_vel(a0)
		
	.noflip:
		jmp	SnapFloor
; ===========================================================================

Crab_Move:	; Routine 2
		subq.w	#1,ost_crab_time(a0)			; decrement timer
		bmi.w	.halt					; branch if -1
		update_x_pos					; update position
		btst	#0,(v_vblank_counter_byte).w
		bne.s	.findfloor_here				; branch on odd frames
		getpos_bottomforward crab_width,crab_height	; d0 = x pos of left/right side; d1 = y pos of bottom
		moveq	#1,d6
		jsr	FloorDist
		cmpi.w	#-8,d5					; is there a wall ahead?
		blt.s	.halt					; if yes, branch
		cmpi.w	#$C,d5					; is there a drop ahead?
		bge.s	.halt					; if yes, branch
		lea	Ani_Crab(pc),a1
		bsr.w	AnimateSprite				; animate
		bra.w	DespawnObject
; ===========================================================================

.findfloor_here:
		getpos_bottom crab_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		jsr	FloorDist
		add.w	d5,ost_y_pos(a0)			; snap to floor
		tst.b	ost_subtype(a0)
		bmi.s	.noslope				; don't check for slope
		
		move.b	ost_anim(a0),d0
		move.b	ost_status(a0),d1
		andi.b	#$FC,d0					; assume floor is flat
		jsr	FloorAngle
		addq.b	#6,d2
		cmpi.b	#12,d2
		bcs.s	.flat					; branch if floor is flat(ish)
		addq.b	#1,d0					; floor isn't flat
		tst.b	d2
		bmi.s	.upright				; branch if floor slopes up-right
		andi.b	#status_xflip,d1
		bne.s	.flat
		addq.b	#1,d0					; flip animation
		
	.flat:
		move.b	d0,ost_anim(a0)
		
	.noslope:
		lea	Ani_Crab(pc),a1
		bsr.w	AnimateSprite				; animate
		bra.w	DespawnObject
		
	.upright:
		andi.b	#status_xflip,d1
		beq.s	.flat
		addq.b	#1,d0					; flip animation
		bra.s	.flat
; ===========================================================================

.halt:
		addq.b	#2,ost_routine(a0)			; goto Crab_Wait next
		move.w	#59,ost_crab_time(a0)			; stop for 1 second before firing
		bclr	#0,ost_frame(a0)
		bra.w	DespawnObject
; ===========================================================================

Crab_Wait:	; Routine 4
		subq.w	#1,ost_crab_time(a0)			; decrement timer
		bpl.w	DespawnObject				; branch if time remains
		
		addq.b	#2,ost_routine(a0)			; goto Crab_Fire next
		move.w	#59,ost_crab_time(a0)			; stop for 1 second before walking
		tst.b	ost_mode(a0)
		bne.s	.fire					; branch if not on first action cycle
		move.b	#1,ost_mode(a0)				; fire on subsequent cycles
		bra.s	Crab_ChgDir
		
	.fire:
		move.b	#id_frame_crab_firing,ost_frame(a0)
		
		bsr.w	FindFreeObj
		bne.w	DespawnObject
		move.l	#CrabBall,ost_id(a1)			; load left fireball
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		subi.w	#$10,ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	#-$100,ost_x_vel(a1)

		bsr.w	FindFreeObj
		bne.w	DespawnObject
		move.l	#CrabBall,ost_id(a1)			; load right fireball
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		addi.w	#$10,ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	#$100,ost_x_vel(a1)
		bra.w	DespawnObject
; ===========================================================================

Crab_Fire:	; Routine 6
		subq.w	#1,ost_crab_time(a0)			; decrement timer
		bpl.w	DespawnObject				; branch if time remains
		
Crab_ChgDir:
		bchg	#status_xflip_bit,ost_status(a0)
		neg.w	ost_x_vel(a0)				; change direction
		move.b	#id_Crab_Move,ost_routine(a0)		; goto Crab_Move next
		move.w	ost_crab_walk_time(a0),ost_crab_time(a0)
		bra.w	DespawnObject

; ---------------------------------------------------------------------------
; Crabmeat missile object
; ---------------------------------------------------------------------------

CrabBall:
		move.l	#Map_Crab,ost_mappings(a0)
		move.w	(v_tile_crabmeat).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_3,ost_priority(a0)
		move.b	#id_React_Hurt,ost_col_type(a0)
		move.b	#6,ost_col_width(a0)
		move.b	#6,ost_col_height(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#StrId_Missile,ost_name(a0)
		move.w	#-$400,ost_y_vel(a0)
		move.b	#id_frame_crab_ball1,ost_frame(a0)

		shortcut
		toggleframe	1				; animate
		update_xy_fall					; update position & apply gravity
		move.w	(v_boundary_bottom).w,d0
		addi.w	#screen_height,d0
		cmp.w	ost_y_pos(a0),d0			; has object moved below the level boundary?
		bcs.w	DeleteObject				; if yes, branch
		bra.w	DisplaySprite

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Crab:	index *
		ptr ani_crab_walk
		ptr ani_crab_walkslope
		ptr ani_crab_walksloperev

ani_crab_walk:
		dc.w $F
		dc.w id_frame_crab_walk
		dc.w id_frame_crab_walk+afxflip
		dc.w id_frame_crab_stand
		dc.w id_Anim_Flag_Restart

ani_crab_walkslope:
		dc.w $F
		dc.w id_frame_crab_walk+afxflip
		dc.w id_frame_crab_slope2
		dc.w id_frame_crab_slope1
		dc.w id_Anim_Flag_Restart

ani_crab_walksloperev:
		dc.w $F
		dc.w id_frame_crab_walk
		dc.w id_frame_crab_slope2+afxflip
		dc.w id_frame_crab_slope1+afxflip
		dc.w id_Anim_Flag_Restart
