; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screens
; ---------------------------------------------------------------------------

GM_TryAgain:
		bsr.w	PaletteFadeOut				; fade out from previous gamemode (demo)
		lea	(vdp_control_port).l,a6
		move.w	#vdp_md_color,(a6)			; normal colour mode
		move.w	#vdp_fg_nametable+(vram_fg>>10),(a6)	; set foreground nametable address
		move.w	#vdp_bg_nametable+(vram_bg>>13),(a6)	; set background nametable address
		move.w	#vdp_plane_width_64|vdp_plane_height_32,(a6) ; 64x32 cell plane size
		move.w	#vdp_full_vscroll|vdp_1px_hscroll,(a6)	; single pixel line horizontal scrolling
		move.w	#vdp_bg_color+$20,(a6)			; set background colour
		clr.b	(f_water_pal_full).w
		bsr.w	ClearScreen

		lea	(v_ost_all).w,a1
		move.w	#loops_to_clear_ost,d1
		bsr.w	ClearRAM

		moveq	#id_KPLC_TryAgain,d0
		jsr	KosPLC					; load "TRY AGAIN"/"END" gfx

		lea	(v_pal_dry).w,a1
		move.w	#loops_to_clear_pal,d1
		bsr.w	ClearRAM

		moveq	#id_Pal_Ending,d0
		bsr.w	PalLoad					; load ending palette
		clr.w	(v_pal_dry+$40).w			; set bg colour to black
		jsr	FindFreeInert
		move.l	#EndEggman,ost_id(a1)			; load Eggman object
		bsr.w	ExecuteObjects
		bsr.w	BuildSprites
		move.w	#1800,(v_countdown).w			; show screen for 30 seconds
		bsr.w	PaletteFadeIn				; fade in from black

; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screen main loop
; ---------------------------------------------------------------------------

TryAg_MainLoop:
		bsr.w	PauseGame
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bsr.w	ExecuteObjects
		bsr.w	BuildSprites
		andi.b	#btnStart,(v_joypad_press_actual).w	; is Start button pressed?
		bne.s	.exit					; if yes, branch
		tst.w	(v_countdown).w				; has 30 seconds elapsed?
		beq.s	.exit					; if yes, branch
		cmpi.b	#id_TryAgain,(v_gamemode).w
		beq.s	TryAg_MainLoop

	.exit:
		move.b	#id_Sega,(v_gamemode).w			; goto Sega screen
		rts
