; ---------------------------------------------------------------------------
; Object 2E - contents of monitors

; spawned by:
;	Monitor - subtype inherited from parent
; ---------------------------------------------------------------------------

PowerUp:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Pow_Index(pc,d0.w),d1
		jmp	Pow_Index(pc,d1.w)
; ===========================================================================
Pow_Index:	index *,,2
		ptr Pow_Main
		ptr Pow_Move
		ptr Pow_Delete

		rsobj PowerUp
ost_pow_slot:	rs.b 1						; slot used by monitor (0-7; -1 if none)
		rsobjend
; ===========================================================================

Pow_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Pow_Move next
		move.w	#tile_Art_Monitors,ost_tile(a0)
		move.b	#render_rel+render_rawmap,ost_render(a0) ; use raw mappings
		move.b	#3,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		move.w	#-$300,ost_y_vel(a0)
		moveq	#0,d0
		move.b	ost_frame(a0),d0
		movea.l	#Map_Monitor,a1
		add.w	d0,d0
		adda.w	(a1,d0.w),a1				; jump to relevant sprite
		addq.w	#2,a1					; jump to sprite piece
		move.l	a1,ost_mappings(a0)

Pow_Move:	; Routine 2
		tst.w	ost_y_vel(a0)
		bpl.s	Pow_Checks				; branch if object has stopped rising
		update_y_fall	$18				; update position & slow ascent
		bra.w	DisplaySprite
; ===========================================================================

Pow_Checks:
		addq.b	#2,ost_routine(a0)			; goto Pow_Delete next
		move.b	#29,ost_anim_time(a0)			; display icon for half a second
		
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		add.w	d0,d0
		move.w	Pow_Index2(pc,d0.w),d1
		jsr	Pow_Index2(pc,d1.w)
		bra.w	DisplaySprite
; ===========================================================================
Pow_Index2:	index *
		ptr Pow_Eggman
		ptr Pow_Sonic
		ptr Pow_Shoes
		ptr Pow_Shield
		ptr Pow_Invincible
		ptr Pow_Rings
		ptr Pow_S
		ptr Pow_Goggles

		if (*-Pow_Index2)/2 <> countof_monitor_types
		inform 3,"Mismatch between monitor count in Monitor and PowerUp objects."
		endc
; ===========================================================================

Pow_Eggman:
		rts						; Eggman monitor does nothing
; ===========================================================================

Pow_Sonic:
ExtraLife:
		addq.b	#1,(v_lives).w				; add 1 to the number of lives you have
		addq.b	#1,(f_hud_lives_update).w		; update the lives counter
		play.w	0, jmp, mus_ExtraLife			; play extra life music
; ===========================================================================

Pow_Shoes:
		move.b	#1,(v_shoes).w				; speed up the BG music
		move.w	#sonic_shoe_time,(v_ost_player+ost_sonic_shoe_time).w ; time limit for the power-up
		move.w	#sonic_max_speed_shoes,(v_sonic_max_speed).w ; change Sonic's top speed
		move.w	#sonic_acceleration_shoes,(v_sonic_acceleration).w ; change Sonic's acceleration
		move.w	#sonic_deceleration_shoes,(v_sonic_deceleration).w ; change Sonic's deceleration
		play.w	0, jmp, cmd_Speedup			; speed up the music
; ===========================================================================

Pow_Shield:
		move.b	#1,(v_shield).w				; give Sonic a shield
		bsr.w	FindFreeInert
		bne.s	.fail
		move.l	#ShieldItem,ost_id(a1)			; load shield object ($38)
		
	.fail:
		play.w	0, jmp, sfx_Shield			; play shield sound
; ===========================================================================

Pow_Invincible:
		move.b	#1,(v_invincibility).w			; make Sonic invincible
		move.w	#sonic_invincible_time,(v_ost_player+ost_sonic_invincible_time).w ; time limit for the power-up
		bsr.w	FindFreeInert
		bne.s	.fail
		move.l	#ShieldItem,ost_id(a1)			; load stars object ($3801)
		move.b	#id_ani_stars1,ost_anim(a1)
		bsr.w	FindFreeInert
		bne.s	.fail
		move.l	#ShieldItem,ost_id(a1)			; load stars object ($3802)
		move.b	#id_ani_stars2,ost_anim(a1)
		bsr.w	FindFreeInert
		bne.s	.fail
		move.l	#ShieldItem,ost_id(a1)			; load stars object ($3803)
		move.b	#id_ani_stars3,ost_anim(a1)
		bsr.w	FindFreeInert
		bne.s	.fail
		move.l	#ShieldItem,ost_id(a1)			; load stars object ($3804)
		move.b	#id_ani_stars4,ost_anim(a1)
		
	.fail:
		moveq	#id_UPLC_Stars,d0
		jsr	UncPLC					; load stars gfx
		tst.b	(f_boss_boundary).w			; is boss mode on?
		bne.s	.skip_music				; if yes, branch
		cmpi.b	#air_alert,(v_air).w
		bls.s	.skip_music
		play.w	0, jmp, mus_Invincible			; play invincibility music

.skip_music:
		rts	
; ===========================================================================

Pow_Rings:
		moveq	#10,d0
		bra.w	CollectRing				; gain 10 rings
; ===========================================================================

Pow_S:
Pow_Goggles:
		rts						; 'S' and goggles monitors do nothing
; ===========================================================================

Pow_Delete:	; Routine 4
		shortcut
		subq.b	#1,ost_anim_time(a0)			; delete after half a second
		bpl.w	DisplaySprite
		
		moveq	#0,d0
		move.b	ost_pow_slot(a0),d0
		bmi.w	DeleteObject				; branch if slot isn't used
		lea	(v_monitor_slots).w,a1
		add.w	d0,d0
		subq.b	#1,(a1,d0.w)				; decrement slot usage counter
		bra.w	DeleteObject
