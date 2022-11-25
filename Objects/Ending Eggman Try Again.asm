; ---------------------------------------------------------------------------
; Object 8B - Eggman on "TRY AGAIN" and "END" screens

; spawned by:
;	GM_TryAgain
; ---------------------------------------------------------------------------

EndEggman:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	EEgg_Index(pc,d0.w),d1
		jsr	EEgg_Index(pc,d1.w)
		jmp	(DisplaySprite).l
; ===========================================================================
EEgg_Index:	index *,,2
		ptr EEgg_Main
		ptr EEgg_Animate
; ===========================================================================

EEgg_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto EEgg_Animate next
		move.w	#$120,ost_x_pos(a0)
		move.w	#$F4,ost_y_screen(a0)
		move.l	#Map_EEgg,ost_mappings(a0)
		move.w	#tile_Kos_TryAgain+1,ost_tile(a0)
		move.b	#render_abs,ost_render(a0)
		move.b	#2,ost_priority(a0)
		move.b	#id_ani_eegg_end,ost_anim(a0)		; use "END" animation
		cmpi.l	#emerald_all,(v_emeralds).w		; do you have all 6 emeralds?
		beq.s	EEgg_Animate				; if yes, branch

		jsr	FindFreeInert
		move.l	#CreditsText,ost_id(a1)			; load credits object
		move.w	#id_frame_cred_tryagain,(v_credits_num).w ; use "TRY AGAIN" text
		jsr	FindFreeInert
		move.l	#TryChaos,ost_id(a1)			; load emeralds object on "TRY AGAIN" screen
		jsr	SaveParent
		move.b	#id_ani_eegg_juggle1,ost_anim(a0)	; use "TRY AGAIN" animation

EEgg_Animate:	; Routine 2
		lea	(Ani_EEgg).l,a1
		jmp	(AnimateSprite).l

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_EEgg:	index *
		ptr ani_eegg_juggle1
		ptr ani_eegg_end
		
ani_eegg_juggle1:
		dc.w 5
		dc.w id_frame_eegg_juggle1
		rept 22
		dc.w id_frame_eegg_juggle2
		endr
		dc.w id_frame_eegg_juggle3
		rept 22
		dc.w id_frame_eegg_juggle4
		endr
		dc.w id_Anim_Flag_Restart

ani_eegg_end:
		dc.w 7
		dc.w id_frame_eegg_end1
		dc.w id_frame_eegg_end2
		dc.w id_frame_eegg_end3
		dc.w id_frame_eegg_end2
		dc.w id_frame_eegg_end1
		dc.w id_frame_eegg_end2
		dc.w id_frame_eegg_end3
		dc.w id_frame_eegg_end2
		dc.w id_frame_eegg_end1
		dc.w id_frame_eegg_end2
		dc.w id_frame_eegg_end3
		dc.w id_frame_eegg_end2
		dc.w id_frame_eegg_end4
		dc.w id_frame_eegg_end2
		dc.w id_frame_eegg_end3
		dc.w id_frame_eegg_end2
		dc.w id_Anim_Flag_Restart
		even
