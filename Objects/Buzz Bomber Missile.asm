; ---------------------------------------------------------------------------
; Object 23 - missile that Buzz	Bomber and Newtron throws

; spawned by:
;	BuzzBomber - subtype 0
;	Newtron - subtype 1
; ---------------------------------------------------------------------------

Missile:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Msl_Index(pc,d0.w),d1
		jmp	Msl_Index(pc,d1.w)
; ===========================================================================
Msl_Index:	index *,,2
		ptr Msl_Main
		ptr Msl_Animate
		ptr Msl_FromBuzz
		ptr Msl_FromNewt

		rsobj Missile
ost_missile_wait_time:	rs.w 1					; time delay (2 bytes)
		rsobjend
; ===========================================================================

Msl_Main:	; Routine 0
		subq.w	#1,ost_missile_wait_time(a0)		; decrement timer
		bpl.s	Msl_ChkCancel				; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Msl_Animate next
		move.l	#Map_Missile,ost_mappings(a0)
		move.w	(v_tile_buzzbomber).w,ost_tile(a0)
		add.w	#tile_pal2,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#3,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		andi.b	#status_xflip+status_yflip,ost_status(a0)
		tst.b	ost_subtype(a0)				; was object created by	a Newtron?
		beq.s	Msl_Animate				; if not, branch

		move.b	#id_Msl_FromNewt,ost_routine(a0)	; goto Msl_FromNewt next
		move.b	#id_col_6x6+id_col_hurt,ost_col_type(a0)
		move.b	#id_ani_buzz_missile,ost_anim(a0)
		bra.w	Msl_Animate2
		
Msl_ChkCancel:
		getparent
		cmpi.l	#ExplosionItem,ost_id(a1)		; has Buzz Bomber been destroyed?
		beq.w	DeleteObject				; if yes, branch
		rts
; ===========================================================================

Msl_Animate:	; Routine 2
		getparent
		cmpi.l	#ExplosionItem,ost_id(a1)		; has Buzz Bomber been destroyed?
		beq.w	DeleteObject				; if yes, branch
		lea	Ani_Missile(pc),a1
		bsr.w	AnimateSprite				; goto Msl_FromBuzz after animation is finished
		bra.w	DisplaySprite
; ===========================================================================

Msl_FromBuzz:	; Routine 4
		move.b	#id_col_6x6+id_col_hurt,ost_col_type(a0)
		move.b	#id_ani_buzz_missile,ost_anim(a0)
		shortcut
		update_xy_pos
		lea	Ani_Missile(pc),a1
		bsr.w	AnimateSprite
		move.w	(v_boundary_bottom).w,d0
		addi.w	#224,d0
		cmp.w	ost_y_pos(a0),d0			; has object moved below the level boundary?
		bcs.w	DeleteObject				; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

Msl_FromNewt:	; Routine 8
		shortcut
		tst.b	ost_render(a0)				; is object on-screen?
		bpl.w	DeleteObject				; if not, branch
		update_x_pos					; update position

Msl_Animate2:
		lea	Ani_Missile(pc),a1
		bsr.w	AnimateSprite
		bra.w	DisplaySprite	

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Missile:	index *
		ptr ani_buzz_flare
		ptr ani_buzz_missile
		
ani_buzz_flare:
		dc.w 7
		dc.w id_frame_buzz_flare1
		dc.w id_frame_buzz_flare2
		dc.w id_Anim_Flag_Routine
		even

ani_buzz_missile:
		dc.w 1
		dc.w id_frame_buzz_ball1
		dc.w id_frame_buzz_ball2
		dc.w id_Anim_Flag_Restart
		even
