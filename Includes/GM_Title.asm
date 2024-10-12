; ---------------------------------------------------------------------------
; Title	screen
; ---------------------------------------------------------------------------

GM_Title:
		play_stop					; stop music
		bsr.w	PaletteFadeOut				; fade from previous gamemode to black
		disable_ints
		bsr.w	DacDriverLoad
		lea	(vdp_control_port).l,a6
		move.w	#vdp_md_color,(a6)			; normal colour mode
		move.w	#vdp_fg_nametable+(vram_fg>>10),(a6)	; set foreground nametable address
		move.w	#vdp_bg_nametable+(vram_bg>>13),(a6)	; set background nametable address
		move.w	#vdp_plane_width_64|vdp_plane_height_32,(a6) ; 64x32 cell plane size
		move.w	#vdp_full_vscroll|vdp_1px_hscroll,(a6)	; single pixel line horizontal scrolling
		move.w	#vdp_bg_color+$20,(a6)			; set background colour (palette line 2, entry 0)
		clr.b	(f_water_pal_full).w
		bsr.w	ClearScreen

		lea	(v_ost_all).w,a1			; RAM address to start clearing
		move.w	#loops_to_clear_ost,d1			; size of RAM block to clear
		bsr.w	ClearRAM				; fill OST with 0

		lea	(v_pal_dry).w,a1
		moveq	#loops_to_clear_pal,d1
		bsr.w	ClearRAM

		moveq	#id_Pal_Sonic,d0			; load Sonic's palette
		bsr.w	PalLoad					; palette will be shown after fading in
		jsr	FindFreeInert
		move.l	#CreditsText,ost_id(a1)			; load "SONIC TEAM PRESENTS" object
		bsr.w	ExecuteObjects
		bsr.w	BuildSprites
		bsr.w	PaletteFadeIn				; fade in to "SONIC TEAM PRESENTS" screen from black
		moveq	#id_VBlank_Title,d1
		moveq	#60,d0
		bsr.w	WaitLoop				; freeze for 1 second
		disable_ints

		moveq	#0,d0
		move.b	d0,(v_last_lamppost).w			; clear lamppost counter
		move.w	d0,(v_debug_active).w			; disable debug item placement mode
		move.w	d0,(v_demo_mode).w			; disable debug mode
		move.w	#id_GHZ_act1,(v_zone).w			; set level to GHZ act 1 (0000)
		move.w	d0,(v_palcycle_time).w			; disable palette cycling
		bsr.w	PaletteFadeOut				; fade out "SONIC TEAM PRESENTS" screen to black
		moveq	#id_SPLC_Title,d0
		jsr	SlowPLC_Now				; load title screen gfx
		bsr.w	LoadPerZone
		bsr.w	LevelParameterLoad			; set level boundaries and Sonic's start position
		bsr.w	DeformLayers
		lea	Level_GHZ_bg,a1
		lea	(v_bg_layout).w,a2
		bsr.w	HiveDec					; load GHZ background
		disable_ints
		bsr.w	ClearScreen
		lea	(vdp_control_port).l,a6
		lea	(v_bg1_x_pos).w,a3
		lea	(v_bg_layout).w,a4			; background layout start address
		move.w	#draw_bg,d2
		jsr	DrawChunks				; draw background

		lea	($FF0000).l,a1				; RAM buffer
		lea	(KosMap_Title).l,a0			; title screen mappings
		locVRAM	vram_fg+(sizeof_vram_row*4)+(3*2),d0	; foreground, x=3, y=4
		moveq	#$22,d1					; width
		moveq	#$16,d2					; height
		move.w	#tile_Kos_TitleFg,d3			; tile setting
		bsr.w	LoadTilemap

		moveq	#id_Pal_Title,d0			; load title screen palette
		bsr.w	PalLoad
		play_music mus_TitleScreen			; play title screen music
		clr.b	(f_debug_enable).w			; disable debug mode
		move.w	#406,(v_countdown).w			; run title screen for 406 frames

		jsr	FindFreeInert
		bne.s	.no_slots
		move.l	#TitleSonic,ost_id(a1)			; load big Sonic object
		move.b	#104,(v_spritemask_pos).w
		move.b	#80,(v_spritemask_height).w

		jsr	FindFreeInert
		bne.s	.no_slots
		move.l	#PSBTM,ost_id(a1)			; load "PRESS START BUTTON" object
		move.b	#0,ost_subtype(a1)

		jsr	FindFreeInert
		bne.s	.no_slots
		move.l	#PSBTM,ost_id(a1)			; load "TM" object
		move.b	#1,ost_subtype(a1)

	.no_slots:
		bsr.w	ExecuteObjects
		bsr.w	DeformLayers
		bsr.w	BuildSprites
		clr.w	(v_title_d_count).w			; reset d-pad counter
		enable_display
		bsr.w	PaletteFadeIn				; fade in to title screen from black

; ---------------------------------------------------------------------------
; Title	screen main loop
; ---------------------------------------------------------------------------

Title_MainLoop:
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bsr.w	ExecuteObjects				; run all objects
		bsr.w	DeformLayers				; scroll background
		bsr.w	BuildSprites				; create sprite table
		bsr.w	PCycle_Title				; animate water palette
		addq.w	#2,(v_ost_player+ost_x_pos).w		; move dummy object 2px to the right (there is no actual object loaded)
		bsr.s	Title_Dpad
		tst.w	(v_countdown).w				; has counter hit 0? (started at 406)
		beq.w	PlayDemo				; if yes, branch
		andi.b	#btnStart,(v_joypad_press_actual).w	; check if Start is pressed
		beq.s	Title_MainLoop				; if not, branch

		tst.b	(f_levelselect_cheat).w			; check if level select code is on
		beq.w	PlayLevel				; if not, play level
		btst	#bitA,(v_joypad_hold_actual).w		; check if A is pressed
		beq.w	PlayLevel				; if not, play level
		bra.w	SuperSelect				; goto level select
; ===========================================================================

Title_Dpad:
		tst.b	(f_levelselect_cheat).w
		bne.s	.exit					; branch if code has been entered
		move.w	(v_title_d_count).w,d0			; get number of times d-pad has been pressed in correct order
		lea	LevSelCode(pc,d0.w),a0			; jump to relevant position in cheat code
		move.b	(v_joypad_press_actual).w,d1		; get button press
		andi.b	#btnDir,d1				; read only UDLR buttons
		beq.s	.exit					; branch if not pressed
		cmp.b	(a0),d1					; does button press match the cheat code?
		bne.s	.reset_cheat				; if not, branch
		addq.w	#1,(v_title_d_count).w			; next input
		tst.b	1(a0)
		bmi.s	.complete				; branch if next input is $FF

	.exit:
		rts

	.reset_cheat:
		move.w	#0,(v_title_d_count).w			; reset cheat counter
		rts

	.complete:
		move.b	#1,(f_levelselect_cheat).w		; set level select flag
		move.b	#1,(f_debug_cheat).w			; set debug mode flag
		play_sound sfx_Ring				; play ring sound
		rts

LevSelCode:	dc.b btnUp,btnDn,btnL,btnR,$FF
		even

; ---------------------------------------------------------------------------
; Go to level
; ---------------------------------------------------------------------------

PlayLevel:
		move.b	#id_Level,(v_gamemode).w		; set gamemode to $0C (level)
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.b	d0,(v_last_ss_levelid).w		; clear special stage number
		move.l	d0,(v_emeralds).w			; clear emeralds
		move.b	d0,(v_continues).w			; clear continues
		move.l	#5000,(v_score_next_life).w		; extra life is awarded at 50000 points
		play_fadeout					; fade out music
		rts

; ---------------------------------------------------------------------------
; Go to demo
; ---------------------------------------------------------------------------

PlayDemo:
		play_fadeout					; fade out music
		bsr.w	LoadPerDemo
		addq.w	#1,(v_demo_num).w			; add 1 to demo number
		cmpi.w	#countof_demo,(v_demo_num).w		; is demo number less than 4?
		blo.s	.demo_0_to_3				; if yes, branch
		clr.w	(v_demo_num).w				; reset demo number to 0

	.demo_0_to_3:
		move.w	#1,(v_demo_mode).w			; turn demo mode on
		move.b	#id_Demo,(v_gamemode).w			; set screen mode to 08 (demo)
		tst.b	(v_zone).w				; is level a special stage?
		bpl.s	.demo_level				; if not, branch
		move.b	#id_Special,(v_gamemode).w		; set screen mode to $10 (Special Stage)
		clr.w	(v_zone).w				; clear	level number
		clr.b	(v_last_ss_levelid).w			; clear special stage number

	.demo_level:
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.l	#5000,(v_score_next_life).w		; extra life is awarded at 50000 points
		rts
