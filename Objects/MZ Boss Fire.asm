; ---------------------------------------------------------------------------
; Object 74 - fireball that Eggman drops (MZ)

; spawned by:
;	Boss
; ---------------------------------------------------------------------------

BossFire:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	BFire_Index(pc,d0.w),d0
		jmp	BFire_Index(pc,d0.w)
; ===========================================================================
BFire_Index:	index *,,2
		ptr BFire_Main
		ptr BFire_Wait
		ptr BFire_Fall
		ptr BFire_Slide
		ptr BFire_Ledge

		rsobj BossFire
ost_bfire_x_start:	rs.w 1					; original x position
ost_bfire_x_last:	rs.w 1					; x position where last static flame spawned
ost_bfire_wait_time:	rs.b 1					; time to wait between events
		rsobjend
; ===========================================================================

BFire_Main:	; Routine 0
		getparent					; a1 = OST of boss ship
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		addi.w	#$18,ost_y_pos(a0)
		move.b	#8,ost_height(a0)
		move.b	#8,ost_width(a0)
		move.l	#Map_Fire,ost_mappings(a0)
		move.w	(v_tile_fireball).w,ost_tile(a0)
		move.b	#render_rel+render_onscreen,ost_render(a0)
		move.b	#priority_5,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#id_React_Hurt,ost_col_type(a0)
		move.b	#8,ost_col_width(a0)
		move.b	#8,ost_col_height(a0)
		addq.b	#2,ost_routine(a0)			; goto BFire_Wait next
		move.b	#30,ost_bfire_wait_time(a0)		; wait half a second before dropping
		play.w	1, jsr, sfx_FireBall			; play fireball sound
		bset	#status_yflip_bit,ost_status(a0)	; invert fireball so only tail is visible

BFire_Wait:	; Routine 2
		subq.b	#1,ost_bfire_wait_time(a0)		; decrement timer
		bpl.s	BFire_Display				; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto BFire_Fall next
		move.w	#0,ost_parent(a0)			; disown parent
		bclr	#status_yflip_bit,ost_status(a0)	; yflip fireball so it's pointing down
		
BFire_Display:
		tst.b	ost_render(a0)
		bmi.s	BFire_Display2				; branch if fireball is visible
		jmp	DeleteObject				; delete if off screen
		
BFire_Display2:
		lea	(Ani_GFire).l,a1
		jsr	(AnimateSprite).l
		jmp	(DisplaySprite).l
; ===========================================================================
		
BFire_Fall:	; Routine 4
		update_y_fall	$18				; update position & apply gravity
		getpos_bottom					; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		bsr.w	FloorDist
		tst.w	d5					; has fireball hit the floor?
		bpl.s	BFire_Display				; if not, branch
		add.w	d5,ost_y_pos(a0)			; snap to floor
		addq.b	#2,ost_routine(a0)			; goto BFire_Slide next
		move.w	#$A0,ost_x_vel(a0)			; move right
		move.w	#0,ost_y_vel(a0)
		move.w	ost_x_pos(a0),ost_bfire_x_start(a0)
		jsr	CloneObject				; create clone
		move.w	ost_x_pos(a0),ost_bfire_x_last(a1)	; don't let the clone create static fire
		neg.w	ost_x_vel(a1)				; move left
		bra.s	BFire_Display
; ===========================================================================
		
BFire_Slide:	; Routine 6
		move.w	ost_bfire_x_start(a0),d0
		sub.w	ost_x_pos(a0),d0
		andi.w	#$F,d0
		bne.s	.skip_fire				; branch if not aligned to 16px
		move.w	ost_x_pos(a0),d1
		cmp.w	ost_bfire_x_last(a0),d1
		beq.s	.skip_fire				; branch if fire already spawned at this x pos
		move.w	d1,ost_bfire_x_last(a0)			; prevent fire spawning here again
		jsr	(FindNextFreeObj).l			; find free OST slot
		bne.s	.skip_fire				; branch if not found
		move.l	#TempFire,ost_id(a1)			; load stationary fireball object
		move.w	d1,ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	a1,ost_linked(a0)			; link to moving fireball
		
	.skip_fire:
		update_x_pos
		getpos_bottom					; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		bsr.w	FloorDist
		cmpi.w	#-8,d5
		blt.s	.wall					; branch if wall is found
		cmpi.w	#$C,d5
		bge.s	.drop					; branch if ledge is found
		add.w	d5,ost_y_pos(a0)			; snap to floor
		bra.w	BFire_Display
		
	.wall:
	.drop:
		addq.b	#2,ost_routine(a0)			; goto BFire_Ledge next
		
BFire_Ledge:	; Routine 8
		update_xy_fall	$24				; update position & apply gravity
		tst.b	ost_render(a0)
		bmi.w	BFire_Display2				; branch if fireball is visible
		tst.w	ost_linked(a0)
		beq.s	.delete					; branch if no static fireball was spawned
		getlinked					; a1 = OST of last static fireball
		cmpi.b	#id_ani_gfire_collide,ost_anim(a1)
		bne.s	.return					; branch if static fireball isn't vanishing
		
	.delete:
		jmp	DeleteObject				; delete if off screen & static fireball is done
		
	.return:
		addq.b	#1,ost_subtype(a0)			; increment return counter
		cmpi.b	#3,ost_subtype(a0)
		beq.s	.delete					; delete after returning twice
		subq.b	#2,ost_routine(a0)			; goto BFire_Slide next
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)		; jump back to position of static fireball
		move.w	#0,ost_y_vel(a0)			; stop falling
		bra.w	BFire_Display2
		
; ---------------------------------------------------------------------------
; Stationary fireball that vanishes

; spawned by:
;	BossFire
; ---------------------------------------------------------------------------

TempFire:
		move.l	#Map_Fire,ost_mappings(a0)
		move.w	(v_tile_fireball).w,ost_tile(a0)
		move.b	#render_rel+render_onscreen,ost_render(a0)
		move.b	#priority_6,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#id_React_Hurt,ost_col_type(a0)
		move.b	#8,ost_col_width(a0)
		move.b	#8,ost_col_height(a0)
		move.b	#103,ost_bfire_wait_time(a0)		; timer 1.7 seconds
		
		shortcut
		subq.b	#1,ost_bfire_wait_time(a0)		; decrement timer
		bpl.w	BFire_Display				; branch if time remains
		move.b	#id_ani_gfire_collide,ost_anim(a0)	; use animation for vertical fireball disappearing
		shortcut
		tst.b	ost_routine(a0)
		beq.w	BFire_Display
		jmp	DeleteObject				; delete when animation completes
