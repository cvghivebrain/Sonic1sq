; ---------------------------------------------------------------------------
; Continue screen
; ---------------------------------------------------------------------------

GM_Continue:
		bsr.w	PaletteFadeOut
		disable_ints
		disable_display
		lea	(vdp_control_port).l,a6
		move.w	#vdp_md_color,(a6)			; normal colour mode
		move.w	#vdp_bg_color,(a6)			; background colour
		bsr.w	ClearScreen

		lea	(v_ost_all).w,a1			; RAM address to start clearing
		move.w	#loops_to_clear_ost,d1			; size of RAM block to clear
		bsr.w	ClearRAM				; fill OST with 0

		moveq	#id_UPLC_Continue,d0
		jsr	UncPLC					; load title card patterns
		jsr	(ProcessDMA).w

		moveq	#id_Pal_Continue,d0
		bsr.w	PalLoad					; load continue	screen palette
		play_music mus_Continue				; play continue	music
		move.w	#659,(v_countdown).w			; set timer to 11 seconds
		clr.l	(v_camera_x_pos).w
		move.l	#$1000000,(v_camera_y_pos).w
		move.l	#ContSonic,(v_ost_player).w		; load Sonic object
		jsr	FindFreeInert
		move.l	#ContScrItem,ost_id(a1)			; load continue screen objects
		jsr	FindFreeInert
		move.l	#ContScrItem,ost_id(a1)			; load oval object
		move.b	#id_CSI_Oval,ost_routine(a1)
		jsr	FindFreeInert
		move.l	#ContScrItem,ost_id(a1)			; load mini Sonic
		move.b	#id_CSI_MakeMiniSonic,ost_routine(a1)	; set routine for mini Sonic
		bsr.w	ExecuteObjects
		bsr.w	BuildSprites
		enable_display
		bsr.w	PaletteFadeIn

; ---------------------------------------------------------------------------
; Continue screen main loop
; ---------------------------------------------------------------------------

Cont_MainLoop:
		move.b	#id_VBlank_Continue,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bsr.w	ExecuteObjects
		bsr.w	BuildSprites
		cmpi.w	#$180,(v_ost_player+ost_x_pos).w	; has Sonic run off screen?
		bhs.s	.goto_level				; if yes, branch
		cmpi.b	#id_CSon_Run,(v_ost_player+ost_routine).w
		bhs.s	Cont_MainLoop
		tst.w	(v_countdown).w				; is time left on countdown?
		bne.w	Cont_MainLoop				; if yes, branch
		move.b	#id_Sega,(v_gamemode).w			; go to Sega screen
		rts
; ===========================================================================

.goto_level:
		move.b	#id_Level,(v_gamemode).w		; set screen mode to $0C (level)
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.b	d0,(v_last_lamppost).w			; clear lamppost count
		subq.b	#1,(v_continues).w			; subtract 1 from continues
		rts
