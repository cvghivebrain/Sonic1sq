; ---------------------------------------------------------------------------
; Object 23 - missile that Buzz	Bomber and Newtron throws

; spawned by:
;	BuzzBomber - subtype 0
;	Newtron - subtype 1

; subtypes:
;	%0000TTTT
;	TTTT - type (see Msl_Types)
; ---------------------------------------------------------------------------

Missile:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Msl_Index(pc,d0.w),d1
		jmp	Msl_Index(pc,d1.w)
; ===========================================================================
Msl_Index:	index *,,2
		ptr Msl_Main
		ptr Msl_BuzzFire
		ptr Msl_Diagonal
		ptr Msl_Horizontal

		rsobj Missile
ost_missile_wait_time:	rs.w 1					; time delay
		rsobjend
		
Msl_Types:	dc.b id_Msl_BuzzFire, id_Msl_Horizontal
		even
; ===========================================================================

Msl_Main:	; Routine 0
		subq.w	#1,ost_missile_wait_time(a0)		; decrement timer
		bpl.s	.verify					; branch if time remains
		move.l	#Map_Missile,ost_mappings(a0)
		move.w	(v_tile_buzzbomber).w,ost_tile(a0)
		add.w	#tile_pal2,ost_tile(a0)
		move.b	#render_rel+render_onscreen,ost_render(a0)
		move.b	#3,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		andi.b	#status_xflip+status_yflip,ost_status(a0)
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0
		move.b	Msl_Types(pc,d0.w),ost_routine(a0)	; goto specified routine next
		rts
		
	.verify:
		getparent					; a1 = OST of parent
		tst.b	ost_col_type(a1)			; has Buzz Bomber been destroyed?
		beq.w	DeleteObject				; if yes, branch
		rts
; ===========================================================================

Msl_BuzzFire:	; Routine 2
		getparent					; a1 = OST of parent
		tst.b	ost_col_type(a1)			; has Buzz Bomber been destroyed?
		beq.w	DeleteObject				; if yes, branch
		lea	Ani_Missile(pc),a1
		bsr.w	AnimateSprite				; goto Msl_Diagonal after animation is finished
		bra.w	DisplaySprite
; ===========================================================================

Msl_Diagonal:	; Routine 4
		move.b	#id_frame_buzz_ball1,ost_frame(a0)
		move.b	#id_col_6x6+id_col_hurt,ost_col_type(a0)
		shortcut
		toggleframe	1				; animate
		update_xy_pos					; update position
		move.w	(v_boundary_bottom).w,d0
		addi.w	#224,d0
		cmp.w	ost_y_pos(a0),d0			; has object moved below the level boundary?
		bcs.w	DeleteObject				; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

Msl_Horizontal:	; Routine 6
		move.b	#id_frame_buzz_ball1,ost_frame(a0)
		move.b	#id_col_6x6+id_col_hurt,ost_col_type(a0)
		shortcut
		toggleframe	1				; animate
		tst.b	ost_render(a0)				; is object on-screen?
		bpl.w	DeleteObject				; if not, branch
		update_x_pos					; update position
		bra.w	DisplaySprite	

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Missile:	index *
		ptr ani_buzz_flare
		
ani_buzz_flare:
		dc.w 7
		dc.w id_frame_buzz_flare1
		dc.w id_frame_buzz_flare2
		dc.w id_Anim_Flag_Routine
