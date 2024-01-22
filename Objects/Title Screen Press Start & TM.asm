; ---------------------------------------------------------------------------
; Object 0F - "PRESS START BUTTON" and "TM" from title screen

; spawned by:
;	GM_Title - subtypes 0/1
; ---------------------------------------------------------------------------

PSBTM:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	PSB_Index(pc,d0.w),d1
		jmp	PSB_Index(pc,d1.w)
; ===========================================================================
PSB_Index:	index *,,2
		ptr PSB_Main
		ptr PSB_Animate
		ptr PSB_Display
		
PSB_Types:	dc.w screen_left+80, screen_top+176		; x/y position
		dc.w tile_Kos_TitleFg				; tile setting
		dc.b id_frame_psb_blank, id_PSB_Animate		; frame, routine
		dc.b id_ani_psb_flash				; animation
		even
	PSB_Types_size:
		
		dc.w screen_left+240, screen_top+120
		dc.w tile_Kos_TitleTM+tile_pal2
		dc.b id_frame_psb_tm, id_PSB_Display
		dc.b 0
		even
; ===========================================================================

PSB_Main:	; Routine 0
		move.l	#Map_PSB,ost_mappings(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		mulu.w	#PSB_Types_size-PSB_Types,d0
		lea	PSB_Types(pc,d0.w),a2
		move.w	(a2)+,ost_x_pos(a0)
		move.w	(a2)+,ost_y_screen(a0)
		move.w	(a2)+,ost_tile(a0)
		move.b	(a2)+,ost_frame(a0)
		move.b	(a2)+,ost_routine(a0)
		move.b	(a2)+,ost_anim(a0)
		rts
; ===========================================================================

PSB_Animate:	; Routine 2
		lea	Ani_PSB(pc),a1
		bsr.w	AnimateSprite				; "PRESS START" is animated

PSB_Display:	; Routine 4
		bra.w	DisplaySprite

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_PSB:	index *
		ptr ani_psb_flash
		
ani_psb_flash:	dc.w $1F
		dc.w id_frame_psb_blank
		dc.w id_frame_psb_psb
		dc.w id_Anim_Flag_Restart
