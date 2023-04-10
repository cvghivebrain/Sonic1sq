; ---------------------------------------------------------------------------
; Hidden Japanese credits screen
; ---------------------------------------------------------------------------

GM_HiddenCredits:
		play.b	1, bsr.w, cmd_Stop			; stop music
		bsr.w	PaletteFadeOut				; fade from previous gamemode to black
		disable_ints
		lea	(vdp_control_port).l,a6
		move.w	#vdp_md_color,(a6)			; normal colour mode
		move.w	#vdp_fg_nametable+(vram_fg>>10),(a6)	; set foreground nametable address
		move.w	#vdp_bg_nametable+(vram_bg>>13),(a6)	; set background nametable address
		move.w	#vdp_plane_width_64|vdp_plane_height_32,(a6) ; 64x32 cell plane size
		move.w	#vdp_full_vscroll|vdp_1px_hscroll,(a6)	; single pixel line horizontal scrolling
		move.w	#vdp_bg_color+$20,(a6)			; set background colour
		clr.b	(f_water_pal_full).w
		bsr.w	ClearScreen
		
		moveq	#id_KPLC_HiddenCredits,d0
		jsr	KosPLC					; load gfx
		lea	($FF0000).l,a1				; RAM buffer
		lea	(KosMap_JapNames).l,a0			; tile mappings
		locVRAM	vram_fg,d0				; foreground, x=0, y=0
		moveq	#$28,d1					; width
		moveq	#$1C,d2					; height
		move.w	#0,d3					; tile setting
		bsr.w	LoadTilemap
		
		lea	(v_pal_dry).w,a1
		move.w	#loops_to_clear_pal,d1
		bsr.w	ClearRAM				; clear palette

		moveq	#id_Pal_HidCred,d0
		bsr.w	PalLoad				; palette will be shown after fading in
		bsr.w	PaletteFadeIn
		
Hidden_MainLoop:
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		move.b	(v_joypad_press_actual).w,d0
		btst	#bitStart,d0
		beq.s	Hidden_MainLoop				; branch if Start isn't pressed
		
		move.b	#id_Title,(v_gamemode).w		; goto title screen
		rts
		