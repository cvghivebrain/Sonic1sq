; ---------------------------------------------------------------------------
; Object 14 - fireballs (MZ, SLZ)

; spawned by:
;	FireMaker, BossMarble

; subtypes:
;	%GH000SSS
;	G - 1 if affected by gravity
;	H - 1 if horizontal, 0 if vertical
;	SSS - initial speed (1 = $100)
; ---------------------------------------------------------------------------

FireBall:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	FBall_Index(pc,d0.w),d1
		jmp	FBall_Index(pc,d1.w)
; ===========================================================================
FBall_Index:	index *,,2
		ptr FBall_Main
		ptr FBall_Action
		ptr FBall_Delete
		ptr FBall_Collide

		rsobj Fireballs
ost_fireball_y_start:	rs.w 1					; original y position
		rsobjend
		
fire_width:	equ 8
fire_height:	equ 8
; ===========================================================================

FBall_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto FBall_Action next
		move.b	#fire_height,ost_height(a0)
		move.b	#fire_width,ost_width(a0)
		move.l	#Map_Fire,ost_mappings(a0)
		move.w	(v_tile_fireball).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		tst.w	ost_priority(a0)
		bne.s	.keep_priority				; branch if priority was set
		move.w	#priority_3,ost_priority(a0)
		
	.keep_priority:
		move.b	#id_React_Hurt,ost_col_type(a0)
		move.b	#8,ost_col_width(a0)
		move.b	#8,ost_col_height(a0)
		move.w	ost_y_pos(a0),ost_fireball_y_start(a0)
		move.b	ost_subtype(a0),d0
		move.b	d0,d1
		andi.w	#%00000111,d0				; read bits 0-2
		lsl.w	#8,d0					; multiply by $100
		andi.b	#type_fire_gravity+type_fire_horizontal,d1 ; read only bits 6-7
		lsr.b	#5,d1
		move.b	d1,ost_mode(a0)				; save gravity/direction settings
		move.b	ost_status(a0),d1
		andi.b	#status_xflip+status_yflip,d1		; read xflip/yflip from status
		bne.s	.flipped				; branch if either are set
		neg.w	d0					; move up or left (down or right if flipped)
		
	.flipped:
		move.w	d0,ost_y_vel(a0)			; set object speed (vertical)
		move.b	#8,ost_displaywidth(a0)
		btst	#type_fire_horizontal_bit,ost_subtype(a0) ; is fireball horizontal?
		beq.s	.sound					; if not, branch

		move.b	#$10,ost_displaywidth(a0)
		move.b	#id_ani_fire_horizontal,ost_anim(a0)	; use horizontal animation
		move.w	d0,ost_x_vel(a0)			; set horizontal speed
		move.w	#0,ost_y_vel(a0)			; delete vertical speed

	.sound:
		play.w	1, jsr, sfx_FireBall			; play lava ball sound

FBall_Action:	; Routine 2
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		move.w	FBall_TypeIndex(pc,d0.w),d1
		jmp	FBall_TypeIndex(pc,d1.w)		; update speed & check for wall collision
; ===========================================================================
FBall_TypeIndex:index *
		ptr FBall_Type_Vert
		ptr FBall_Type_Hori
		ptr FBall_Type_VertGrav
		ptr FBall_Type_HoriGrav
; ===========================================================================

FBall_Type_VertGrav:
		move.w	ost_fireball_y_start(a0),d0
		cmp.w	ost_y_pos(a0),d0			; has object fallen back to its original position?
		bcc.s	.keep_falling				; if not, branch
		addq.b	#2,ost_routine(a0)			; goto FBall_Delete next

	.keep_falling:
		update_y_fall	$18				; update position and apply gravity
		bmi.s	.upwards				; branch if fireball is moving up
		bset	#status_yflip_bit,ost_status(a0)	; face down

	.upwards:
		lea	Ani_Fire(pc),a1
		bsr.w	AnimateSprite
		bra.w	DespawnQuick
; ===========================================================================

FBall_Type_HoriGrav:
		tst.b	ost_render(a0)
		bmi.s	.keep_falling				; branch if fireball is on screen
		addq.b	#2,ost_routine(a0)			; goto FBall_Delete next

	.keep_falling:
		update_xy_fall	$18				; update position and apply gravity
		lea	Ani_Fire(pc),a1
		bsr.w	AnimateSprite
		bra.w	DespawnQuick
; ===========================================================================

FBall_Type_Vert:
		tst.w	ost_y_vel(a0)
		bpl.s	.down					; branch if fireball should move down
		
		getpos_top fire_height				; d0 = x pos; d1 = y pos of top
		moveq	#1,d6
		bsr.w	CeilingDist
		tst.w	d5					; distance to ceiling
		bpl.s	.no_ceiling				; branch if > 0
		move.b	#id_FBall_Collide,ost_routine(a0)	; goto FBall_Collide next
		move.b	#id_frame_fire_vertcollide,ost_frame(a0)
		bra.w	DespawnQuick

	.no_ceiling:
		update_y_pos
		lea	Ani_Fire(pc),a1
		bsr.w	AnimateSprite
		bra.w	DespawnQuick
		
	.down:
		getpos_bottom fire_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		bsr.w	FloorDist
		tst.w	d5					; distance to floor
		bpl.s	.no_ceiling				; branch if > 0
		move.b	#id_FBall_Collide,ost_routine(a0)	; goto FBall_Collide next
		move.b	#id_frame_fire_vertcollide,ost_frame(a0)
		bra.w	DespawnQuick
; ===========================================================================

FBall_Type_Hori:
		tst.w	ost_x_vel(a0)
		bpl.s	.right					; branch if fireball is moving right
		
		getpos_left fire_width				; d0 = x pos of left; d1 = y pos
		moveq	#1,d6
		bsr.w	WallLeftDist
		tst.w	d5					; distance to wall
		bpl.s	.no_wall				; branch if > 0
		move.b	#id_FBall_Collide,ost_routine(a0)	; goto FBall_Collide next
		move.b	#id_frame_fire_horicollide,ost_frame(a0)
		bra.w	DespawnQuick

	.no_wall:
		update_x_pos
		lea	Ani_Fire(pc),a1
		bsr.w	AnimateSprite
		bra.w	DespawnQuick
		
	.right:
		getpos_right fire_width				; d0 = x pos of right; d1 = y pos
		moveq	#1,d6
		bsr.w	WallRightDist
		tst.w	d5					; distance to wall
		bpl.s	.no_wall				; branch if > 0
		move.b	#id_FBall_Collide,ost_routine(a0)	; goto FBall_Collide next
		move.b	#id_frame_fire_horicollide,ost_frame(a0)
		bra.w	DespawnQuick
; ===========================================================================

FBall_Collide:	; Routine 6
		move.b	#5,ost_anim_time(a0)
		shortcut
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bpl.w	DisplaySprite				; branch if time remains

FBall_Delete:	; Routine 4
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Fire:	index *
		ptr ani_fire_vertical
		ptr ani_fire_horizontal
		
ani_fire_vertical:
		dc.w 5
		dc.w id_frame_fire_vertical1+afyflip
		dc.w id_frame_fire_vertical1+afxflip+afyflip
		dc.w id_frame_fire_vertical2+afyflip
		dc.w id_frame_fire_vertical2+afxflip+afyflip
		dc.w id_Anim_Flag_Restart

ani_fire_horizontal:
		dc.w 5
		dc.w id_frame_fire_horizontal1+afxflip
		dc.w id_frame_fire_horizontal1+afyflip+afxflip
		dc.w id_frame_fire_horizontal2+afxflip
		dc.w id_frame_fire_horizontal2+afyflip+afxflip
		dc.w id_Anim_Flag_Restart
