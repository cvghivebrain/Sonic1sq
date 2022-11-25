; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screens
; ---------------------------------------------------------------------------

GM_TryAgain:
		bsr.w	PaletteFadeOut				; fade out from previous gamemode (demo)
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)				; normal colour mode
		move.w	#$8200+(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)		; set background nametable address
		move.w	#$9001,(a6)				; 64x32 cell plane size
		move.w	#$9200,(a6)				; window vertical position
		move.w	#$8B03,(a6)				; line scroll mode
		move.w	#$8720,(a6)				; set background colour (line 3; colour 0)
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
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		move.w	#1800,(v_countdown).w			; show screen for 30 seconds
		bsr.w	PaletteFadeIn				; fade in from black

; ---------------------------------------------------------------------------
; "TRY AGAIN" and "END"	screen main loop
; ---------------------------------------------------------------------------

TryAg_MainLoop:
		bsr.w	PauseGame
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		andi.b	#btnStart,(v_joypad_press_actual).w	; is Start button pressed?
		bne.s	.exit					; if yes, branch
		tst.w	(v_countdown).w				; has 30 seconds elapsed?
		beq.s	.exit					; if yes, branch
		cmpi.b	#id_TryAgain,(v_gamemode).w
		beq.s	TryAg_MainLoop

	.exit:
		move.b	#id_Sega,(v_gamemode).w			; goto Sega screen
		rts	
