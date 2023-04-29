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

		rsobj Fireballs
ost_fireball_mz_boss:	rs.b 1					; set to $FF if spawned by MZ boss
ost_fireball_y_start:	rs.w 1					; original y position (2 bytes)
		rsobjend
; ===========================================================================

FBall_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto FBall_Action next
		move.b	#8,ost_height(a0)
		move.b	#8,ost_width(a0)
		move.l	#Map_Fire,ost_mappings(a0)
		move.w	(v_tile_fireball).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		move.b	#id_col_8x8+id_col_hurt,ost_col_type(a0)
		move.w	ost_y_pos(a0),ost_fireball_y_start(a0)
		tst.b	ost_fireball_mz_boss(a0)		; was fireball spawned by MZ boss?
		beq.s	.speed					; if not, branch
		addq.b	#2,ost_priority(a0)			; use lower sprite priority

	.speed:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		andi.b	#%00000111,d0				; read bits 0-2
		lsl.w	#8,d0					; multiply by $100
		neg.w	d0					; move up or left by default
		move.b	ost_status(a0),d1
		andi.b	#status_xflip+status_yflip,d1		; read xflip/yflip from status
		beq.s	.noflip					; branch if neither are set
		neg.w	d0					; move down or right instead
		
	.noflip:
		move.w	d0,ost_y_vel(a0)			; set object speed (vertical)
		move.b	#8,ost_displaywidth(a0)
		btst	#6,ost_subtype(a0)			; is fireball horizontal?
		beq.s	.sound					; if not, branch

		move.b	#$10,ost_displaywidth(a0)
		move.b	#id_ani_fire_horizontal,ost_anim(a0)	; use horizontal animation
		move.w	d0,ost_x_vel(a0)			; set horizontal speed
		move.w	#0,ost_y_vel(a0)			; delete vertical speed

	.sound:
		play.w	1, jsr, sfx_FireBall			; play lava ball sound

FBall_Action:	; Routine 2
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		beq.s	.skip_type				; branch if subtype is 0
		andi.b	#%11000000,d0				; read only bits 6-7
		lsr.b	#5,d0
		move.w	FBall_TypeIndex(pc,d0.w),d1
		jsr	FBall_TypeIndex(pc,d1.w)		; update speed & check for wall collision
		
	.skip_type:
		lea	(Ani_Fire).l,a1
		bsr.w	AnimateSprite
		bra.w	DespawnQuick
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
		rts	
; ===========================================================================

FBall_Type_HoriGrav:
		tst.b	ost_render(a0)
		bmi.s	.keep_falling				; branch if fireball is on screen
		addq.b	#2,ost_routine(a0)			; goto FBall_Delete next

	.keep_falling:
		update_xy_fall	$18				; update position and apply gravity
		rts	
; ===========================================================================

FBall_Type_Vert:
		btst	#status_yflip_bit,ost_status(a0)
		bne.s	.down					; branch if fireball should move down
		
		bsr.w	FindCeilingObj
		tst.w	d1					; distance to ceiling
		bpl.s	.no_ceiling				; branch if > 0
		move.b	#0,ost_subtype(a0)
		move.b	#id_ani_fire_vertcollide,ost_anim(a0)
		move.w	#0,ost_y_vel(a0)			; stop the object when it touches the ceiling
		rts

	.no_ceiling:
		update_y_pos
		rts	
		
	.down:
		bsr.w	FindFloorObj
		tst.w	d1					; distance to floor
		bpl.s	.no_ceiling				; branch if > 0
		move.b	#0,ost_subtype(a0)
		move.b	#id_ani_fire_vertcollide,ost_anim(a0)
		move.w	#0,ost_y_vel(a0)			; stop the object when it touches the floor
		rts	
; ===========================================================================

FBall_Type_Hori:
		btst	#status_xflip_bit,ost_status(a0)
		bne.s	.right					; branch if fireball is moving right
		
		bsr.w	FindWallLeftObj
		tst.w	d1					; distance to wall
		bpl.s	.no_wall				; branch if > 0
		move.b	#0,ost_subtype(a0)
		move.b	#id_ani_fire_horicollide,ost_anim(a0)
		move.w	#0,ost_x_vel(a0)			; stop object when it touches a wall
		rts

	.no_wall:
		update_x_pos
		rts
		
	.right:
		bsr.w	FindWallRightObj
		tst.w	d1					; distance to wall
		bpl.s	.no_wall				; branch if > 0
		move.b	#0,ost_subtype(a0)
		move.b	#id_ani_fire_horicollide,ost_anim(a0)
		move.w	#0,ost_x_vel(a0)			; stop object when it touches a wall
		rts
; ===========================================================================

FBall_Delete:	; Routine 4
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Fire:	index *
		ptr ani_fire_vertical
		ptr ani_fire_vertcollide
		ptr ani_fire_horizontal
		ptr ani_fire_horicollide
		
ani_fire_vertical:
		dc.w 5
		dc.w id_frame_fire_vertical1+afyflip
		dc.w id_frame_fire_vertical1+afxflip+afyflip
		dc.w id_frame_fire_vertical2+afyflip
		dc.w id_frame_fire_vertical2+afxflip+afyflip
		dc.w id_Anim_Flag_Restart

ani_fire_vertcollide:
		dc.w 5
		dc.w id_frame_fire_vertcollide+afyflip
		dc.w id_Anim_Flag_Routine

ani_fire_horizontal:
		dc.w 5
		dc.w id_frame_fire_horizontal1+afxflip
		dc.w id_frame_fire_horizontal1+afyflip+afxflip
		dc.w id_frame_fire_horizontal2+afxflip
		dc.w id_frame_fire_horizontal2+afyflip+afxflip
		dc.w id_Anim_Flag_Restart

ani_fire_horicollide:
		dc.w 5
		dc.w id_frame_fire_horicollide+afxflip
		dc.w id_Anim_Flag_Routine
