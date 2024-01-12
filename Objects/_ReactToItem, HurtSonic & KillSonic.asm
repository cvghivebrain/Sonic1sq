; ---------------------------------------------------------------------------
; Subroutine to collide Sonic with objects using ost_col_type(a0)

; input:
;	a0 = address of OST of Sonic

; output:
;	a2 = address of OST of object hurting/killing Sonic

;	uses d0.l, d1.l, d2.w, d3.w, d4.w, d5.l, d6.l, a1
; ---------------------------------------------------------------------------

ReactToItem:	
		move.w	ost_x_pos(a0),d2
		move.w	ost_y_pos(a0),d3
		moveq	#0,d4
		moveq	#0,d5
		move.b	(v_player1_hitbox_width).w,d4
		move.b	(v_player1_hitbox_height).w,d5
		cmpi.b	#id_Roll,ost_anim(a0)
		bne.s	.not_rolling				; branch if Sonic isn't rolling/jumping
		move.b	(v_player1_hitbox_width_roll).w,d4
		move.b	(v_player1_hitbox_height_roll).w,d5
		
	.not_rolling:
		cmpi.b	#id_Duck,ost_anim(a0)
		bne.s	.not_ducking				; branch if Sonic isn't ducking
		addq.w	#6,d3
		subq.b	#6,d5					; smaller hitbox when ducking
		
	.not_ducking:
		lea	(v_ost_level_obj).w,a1			; first OST slot for interactable objects
		move.w	#countof_ost_ert-1,d6			; number of interactable objects

React_Loop:
		tst.b	ost_render(a1)
		bpl.s	React_Next				; branch if object is off screen
		tst.b	ost_col_type(a1)
		beq.s	React_Next				; branch if collision type is 0
		move.w	ost_x_pos(a1),d0
		sub.w	d2,d0					; d0 = x dist between Sonic & object
		moveq	#0,d1
		move.b	ost_col_width(a1),d1
		add.w	d1,d0
		add.w	d4,d0					; add Sonic & object hitboxes
		add.w	d4,d1
		add.w	d1,d1					; d1 = combined hitbox widths
		cmp.w	d1,d0
		bcc.s	React_Next				; branch if no overlap on x
		move.w	ost_y_pos(a1),d0
		sub.w	d3,d0					; d0 = y dist between Sonic & object
		moveq	#0,d1
		move.b	ost_col_height(a1),d1
		add.w	d1,d0
		add.w	d5,d0					; add Sonic & object hitboxes
		add.w	d5,d1
		add.w	d1,d1					; d1 = combined hitbox heights
		cmp.w	d1,d0
		bcc.s	React_Next				; branch if no overlap on y
		moveq	#0,d0
		move.b	ost_col_type(a1),d0
		move.w	React_Index(pc,d0.w),d0
		jmp	React_Index(pc,d0.w)			; collision successful, exit loop

	React_Next:
		lea	sizeof_ost(a1),a1			; next OST slot
		dbf	d6,React_Loop				; repeat $5F more times
		rts	
; ===========================================================================
React_Index:	index *,,2
		ptr React_None					; unused
		ptr React_Enemy					; breakable enemies
		ptr React_Boss					; bosses
		ptr React_Ring					; rings, giant rings
		ptr React_Hurt					; hurts when touched
		ptr React_Routine				; increment routine counter for object
		ptr React_Bumper				; increment ost_col_property
		ptr React_Caterkiller				; caterkiller
		ptr React_Yadrin				; yadrin
; ===========================================================================

React_Ring:
		cmpi.w	#sonic_flash_time-ring_delay,ost_sonic_flash_time(a0) ; has Sonic been hit recently?
		bcc.s	React_None				; if yes, branch
		
React_Routine:
		addq.b	#2,ost_routine(a1)			; goto Ring_Collect (if ring), RLoss_Collect (if bouncing ring), GRing_Collect (if giant ring) next
		
React_None:
		rts
; ===========================================================================

React_Boss:
		tst.w	(v_invincibility).w
		bne.s	.donthurtsonic				; branch if Sonic is invincible
		cmpi.b	#id_Roll,ost_anim(a0)
		bne.w	React_Hurt				; branch if not rolling/jumping

	.donthurtsonic:
		neg.w	ost_x_vel(a0)				; repel Sonic
		neg.w	ost_y_vel(a0)
		asr	ost_x_vel(a0)
		asr	ost_y_vel(a0)
		move.b	#16*2,(v_boss_flash).w			; set ship to flash 16 times
		play.w	1, jsr, sfx_BossHit			; play boss damage sound
		move.b	#0,ost_col_type(a1)			; temporarily make boss harmless
		subq.b	#1,ost_col_property(a1)			; decrement hit counter
		bne.s	.flagnotclear				; branch if not 0
		bset	#status_broken_bit,ost_status(a1)	; set flag for boss beaten

	.flagnotclear:
		rts	
; ===========================================================================

React_Enemy:
		tst.w	(v_invincibility).w
		bne.s	React_Enemy_Break			; branch if Sonic is invincible
		cmpi.b	#id_Roll,ost_anim(a0)
		bne.w	React_Hurt				; branch if not rolling/jumping

React_Enemy_Break:
		move.w	(v_enemy_combo).w,d0
		addq.w	#2,(v_enemy_combo).w			; add 2 to item bonus counter
		cmpi.w	#Enemy_Points_end-Enemy_Points-2,d0
		bcs.s	.bonusokay
		moveq	#Enemy_Points_end-Enemy_Points-2,d0	; max bonus is #6 (1000 points)

	.bonusokay:
		move.w	d0,ost_subtype(a1)			; set frame for points object (spawned by animal object)
		move.w	Enemy_Points(pc,d0.w),d0
		cmpi.w	#combo_max,(v_enemy_combo).w		; have 16 enemies been destroyed?
		bcs.s	.lessthan16				; if not, branch
		move.w	#combo_max_points,d0			; fix bonus to 10000
		move.w	#id_frame_points_10k*2,ost_subtype(a1)	; use 10k frame for points object

	.lessthan16:
		jsr	AddPoints				; update score
		move.l	#ExplosionItem,ost_id(a1)		; change object to explosion
		move.b	#id_ExItem_Animal,ost_routine(a1)	; explosion also spawns an animal
		tst.w	ost_y_vel(a0)
		bmi.s	.bouncedown				; branch if Sonic is moving upwards
		cmp.w	ost_y_pos(a1),d3			; d3 = Sonic's y pos
		bcc.s	.bounceup				; branch if Sonic is below enemy
		neg.w	ost_y_vel(a0)
		rts

	.bouncedown:
		addi.w	#$100,ost_y_vel(a0)
		rts	

	.bounceup:
		subi.w	#$100,ost_y_vel(a0)
		rts	

Enemy_Points:	dc.w 100/10
		dc.w 200/10
		dc.w 500/10
		dc.w 1000/10
	Enemy_Points_end:
; ===========================================================================

React_Caterkiller:
		tst.w	(v_invincibility).w
		bne.s	.break_caterkiller			; branch if Sonic is invincible
		cmpi.b	#id_Roll,ost_anim(a0)
		beq.s	.break_caterkiller			; branch if Sonic is rolling/jumping
		move.b	#id_Cat_Split,ost_mode(a1)		; caterkiller splits apart
		bra.w	React_Hurt_SkipInv
		
	.break_caterkiller:
		pushr	a0-a1
		movea.l	a1,a0					; a0 = OST of caterkiller
		bsr.w	DeleteChildren				; delete caterkiller segments
		popr	a0-a1
		bra.w	React_Enemy_Break
; ===========================================================================

React_Yadrin:
		sub.w	d0,d5					; d5 = Sonic's height, minus y dist between Sonic & yadrin
		cmpi.w	#8,d5
		bcc.w	React_Enemy				; branch if Sonic is below spike level
		move.w	ost_x_pos(a1),d0
		subq.w	#4,d0
		btst	#status_xflip_bit,ost_status(a1)
		beq.s	.no_xflip
		subi.w	#$10,d0

	.no_xflip:
		sub.w	d2,d0					; d0 = x pos of yadrin's face, minus x pos of Sonic's left edge
		bcc.s	.sonic_left				; branch if Sonic is left of the yadrin
		addi.w	#$18,d0
		bcs.s	React_Hurt				; branch if Sonic is inside the yadrin
		bra.w	React_Enemy
; ===========================================================================

.sonic_left:
		cmp.w	d4,d0
		bhi.w	React_Enemy				; branch if Sonic is outside the yadrin
		bra.w	React_Hurt				; check for invincibility, then hurt Sonic
; ===========================================================================

React_Bumper:
		addq.b	#1,ost_col_property(a1)			; set flag for Sonic touching bumper
		rts
; ===========================================================================

React_Hurt:
		tst.w	(v_invincibility).w
		bne.w	React_None				; branch if Sonic is invincible

React_Hurt_SkipInv:
		tst.w	ost_sonic_flash_time(a0)		; is Sonic flashing?
		bne.w	React_None				; if yes, branch
		movea.l	a1,a2

; continue straight to HurtSonic

; ---------------------------------------------------------------------------
; Hurting Sonic	subroutine

; input:
;	a0 = address of OST of Sonic
;	a2 = address of OST of object hurting Sonic

; output:
;	a1 = address of OST of ring loss object (if Sonic had rings)

;	uses d0.l
; ---------------------------------------------------------------------------

HurtSonic:
		tst.b	(v_shield).w
		bne.s	.hasshield				; branch if Sonic has a shield
		tst.w	(v_rings).w
		beq.w	.norings				; branch if Sonic has no rings

		jsr	(FindFreeObj).l				; find free OST slot
		bne.s	.hasshield				; branch if not found
		move.l	#RingLoss,ost_id(a1)			; load bouncing multi rings object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)

	.hasshield:
		move.b	#0,(v_shield).w				; remove shield
		move.b	#id_Sonic_Hurt,ost_routine(a0)		; run hurt animation/action
		bsr.w	Sonic_ResetOnFloor			; reset several of Sonic's flags
		bset	#status_air_bit,ost_status(a0)
		move.w	#-$400,ost_y_vel(a0)			; make Sonic bounce away from the object
		move.w	#-$200,ost_x_vel(a0)
		btst	#status_underwater_bit,ost_status(a0)	; is Sonic underwater?
		beq.s	.isdry					; if not, branch

		move.w	#-$200,ost_y_vel(a0)			; slower bounce
		move.w	#-$100,ost_x_vel(a0)

	.isdry:
		move.w	ost_x_pos(a0),d0
		cmp.w	ost_x_pos(a2),d0
		bcs.s	.isleft					; if Sonic is left of the object, branch
		neg.w	ost_x_vel(a0)				; if Sonic is right of the object, reverse

	.isleft:
		move.w	#0,ost_inertia(a0)
		move.b	#id_Hurt,ost_anim(a0)
		move.w	#sonic_flash_time,ost_sonic_flash_time(a0) ; set temp invincible time to 2 seconds
		move.w	#sfx_Death,d0				; load normal damage sound
		btst	#status_pointy_bit,ost_status(a2)	; check	if you were hit by spikes
		beq.s	.sound					; if not, branch
		move.w	#sfx_SpikeHit,d0			; load spikes damage sound

	.sound:
		jmp	(PlaySound1).l
; ===========================================================================

.norings:
		tst.w	(f_debug_enable).w			; is debug mode	cheat on?
		bne.w	.hasshield				; if yes, branch

; continue straight into KillSonic

; ---------------------------------------------------------------------------
; Subroutine to	kill Sonic

; input:
;	a0 = address of OST of Sonic
;	a2 = address of OST of object killing Sonic

;	uses d0.l
; ---------------------------------------------------------------------------

KillSonic:
		tst.w	(v_debug_active).w			; is debug mode	active?
		bne.s	.dontdie				; if yes, branch
		move.w	#0,(v_invincibility).w			; remove invincibility
		move.b	#0,(f_hud_time_update).w		; stop HUD time counter
		move.b	#id_Sonic_Death,ost_routine(a0)		; run death animation/action
		bsr.w	Sonic_ResetOnFloor			; reset several of Sonic's flags
		bset	#status_air_bit,ost_status(a0)
		move.w	#-$700,ost_y_vel(a0)			; move Sonic up
		move.w	#0,ost_x_vel(a0)
		move.w	#0,ost_inertia(a0)
		move.b	#id_Death,ost_anim(a0)
		bset	#tile_hi_bit,ost_tile(a0)
		move.w	#sfx_Death,d0				; play normal death sound
		btst	#status_pointy_bit,ost_status(a2)	; check	if you were killed by spikes
		beq.s	.sound
		move.w	#sfx_SpikeHit,d0			; play spikes death sound

	.sound:
		jmp	(PlaySound1).l

	.dontdie:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	kill Sonic (from object)

; input:
;	a0 = address of OST of object killing Sonic

; output:
;	a2 = address of OST of Sonic
; ---------------------------------------------------------------------------

ObjectKillSonic:
		movea.l	a0,a2					; object which killed Sonic
		lea	(v_ost_player).w,a0			; make Sonic the current object
		bsr.s	KillSonic				; kill Sonic
		exg	a0,a2					; restore current object
		rts

; ---------------------------------------------------------------------------
; Subroutine to	hurt Sonic (from object)

; input:
;	a0 = address of OST of object hurting Sonic

; output:
;	a2 = address of OST of Sonic
; ---------------------------------------------------------------------------

ObjectHurtSonic:
		movea.l	a0,a2					; object which hurt Sonic
		lea	(v_ost_player).w,a0			; make Sonic the current object
		bsr.w	HurtSonic				; hurt Sonic
		exg	a0,a2					; restore current object
		rts

; ---------------------------------------------------------------------------
; Subroutine to	kill Sonic (from non-object)

; input:
;	a0 = address of OST of Sonic

; output:
;	a2 = address of OST of Sonic
; ---------------------------------------------------------------------------

SelfKillSonic:
		movea.l	a0,a2					; Sonic killed himself (by falling out of the level)
		bsr.s	KillSonic				; kill Sonic
		rts
		