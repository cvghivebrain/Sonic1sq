; ---------------------------------------------------------------------------
; Level
; ---------------------------------------------------------------------------

GM_Level:
GM_Demo:
		tst.w	(v_demo_mode).w				; is this an ending demo?
		bmi.s	.keep_music				; if yes, branch
		play.b	1, jsr, cmd_Fade			; fade out music

	.keep_music:
		bsr.w	PaletteFadeOut				; fade out from previous gamemode
		bset	#7,(v_gamemode).w			; add $80 to gamemode (for title card sequence)
		tst.w	(v_demo_mode).w				; is this an ending demo?
		bmi.s	.skip_gfx				; if yes, branch
		moveq	#id_UPLC_Monitors,d0
		jsr	UncPLC					; load graphics for monitors

	.skip_gfx:
		lea	(v_ost_all).w,a1			; RAM address to start clearing
		move.w	#loops_to_clear_ost,d1			; size of RAM block to clear
		bsr.w	ClearRAM				; fill OST with 0

		lea	(v_vblank_routine).w,a1
		move.w	#loops_to_clear_vblankstuff,d1
		bsr.w	ClearRAM

		lea	(v_camera_x_pos).w,a1
		move.w	#loops_to_clear_levelinfo,d1
		bsr.w	ClearRAM

		lea	(v_oscillating_table).w,a1
		move.w	#loops_to_clear_synctables2,d1
		bsr.w	ClearRAM

		disable_ints
		bsr.w	ClearScreen
		lea	(vdp_control_port).l,a6
		move.w	#vdp_full_vscroll|vdp_1px_hscroll,(a6)	; single pixel line horizontal scrolling
		move.w	#vdp_fg_nametable+(vram_fg>>10),(a6)	; set foreground nametable address
		move.w	#vdp_bg_nametable+(vram_bg>>13),(a6)	; set background nametable address
		move.w	#vdp_sprite_table+(vram_sprites>>9),(a6) ; set sprite table address
		move.w	#vdp_plane_width_64|vdp_plane_height_32,(a6) ; 64x32 cell plane size
		move.w	#vdp_md_color,(a6)			; normal colour mode
		move.w	#vdp_bg_color+$20,(a6)			; set background colour (line 3; colour 0)
		move.w	#vdp_hint_counter+223,(v_vdp_hint_counter).w ; set palette change position (for water)
		move.w	(v_vdp_hint_counter).w,(a6)
		bsr.w	LoadPerZone
		move.b	#air_full,(v_air).w
		tst.b	(f_water_enable).w			; is water enabled?
		beq.s	.skip_water				; if not, branch

		move.w	#vdp_md_color|vdp_enable_hint,(a6)	; enable horizontal interrupts
		clr.b	(v_water_routine).w			; clear water routine counter
		clr.b	(f_water_pal_full).w			; clear	water state
		move.b	#1,(v_water_direction).w		; enable water
		tst.b	(v_last_lamppost).w			; has a lamppost been used?
		beq.s	.no_lamp				; if not, branch
		move.b	(f_water_pal_full_lampcopy).w,(f_water_pal_full).w ; retrieve flag for whole screen being underwater

	.skip_water:
	.no_lamp:
		enable_ints
		tst.w	(v_demo_mode).w				; is this an ending demo?
		bmi.s	Level_Skip_TtlCard			; if yes, branch
		jsr	FindFreeInert
		move.l	#TitleCard,ost_id(a1)			; load title card object
		move.b	#1,(f_brightness_update).w		; show Sonic/title card palette
		move.b	(v_bgm).w,d0
		jsr	(PlaySound0).w				; play music

Level_TtlCardLoop:
		move.b	#id_VBlank_TitleCard,(v_vblank_routine).w
		bsr.w	WaitForVBlank_CPU
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		move.b	(v_titlecard_loaded).w,d0
		cmp.b	(v_titlecard_state).w,d0
		bne.s	Level_TtlCardLoop			; branch if title card is still moving

Level_Skip_TtlCard:
		bsr.w	LevelParameterLoad			; load level boundaries and start positions
		bsr.w	DeformLayers
		bset	#redraw_left_bit,(v_fg_redraw_direction).w
		bsr.w	LevelDataLoad				; load block mappings and palettes
		bsr.w	DrawTilesAtStart
		jsr	(ConvertCollisionArray).l
		bsr.w	LZWaterFeatures
		bsr.w	LoadPerCharacter
		bsr.w	WaterFilter
		tst.w	(v_demo_mode).w				; is this an ending demo?
		bmi.s	.skip_hud				; if yes, branch
		jsr	FindFreeInert
		bne.s	.skip_hud
		move.l	#HUD,ost_id(a1)				; load HUD object

	.skip_hud:
		tst.b	(f_debug_cheat).w			; has debug cheat been entered?
		beq.s	.skip_debug				; if not, branch
		btst	#bitA,(v_joypad_hold_actual).w		; is A button held?
		beq.s	.skip_debug				; if not, branch
		move.b	#1,(f_debug_enable).w			; enable debug mode

	.skip_debug:
		move.w	#0,(v_joypad_hold).w
		move.w	#0,(v_joypad_hold_actual).w
		tst.b	(f_water_enable).w			; is water enabled?
		beq.s	.skip_water_surface			; if not, branch
		jsr	FindFreeInert
		bne.s	.skip_water_surface
		move.l	#WaterSurface,ost_id(a1)		; load water surface object
		jsr	FindFreeInert
		bne.s	.skip_water_surface
		move.l	#DrownCount,ost_id(a1)			; load object that tracks air and spawns bubbles

	.skip_water_surface:
		moveq	#0,d0
		tst.b	(v_last_lamppost).w			; are you starting from	a lamppost?
		bne.s	.skip_clear				; if yes, branch
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.b	d0,(v_ring_reward).w			; clear lives counter

	.skip_clear:
		move.b	d0,(f_time_over).w
		move.b	d0,(v_shield).w				; clear shield
		move.w	d0,(v_debug_active).w
		move.w	d0,(f_restart).w
		move.w	d0,(v_frame_counter).w
		jsr	(ObjPosLoad).l
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		bsr.w	OscillateNumInit

		move.w	#0,(v_demo_input_counter).w
		movea.l	(v_demo_ptr).w,a1			; get pointer for demo data
		move.b	1(a1),(v_demo_input_time).w		; load button press duration
		subq.b	#1,(v_demo_input_time).w		; subtract 1 from duration
		move.w	#1800,(v_countdown).w			; run demo for 30 seconds max
		tst.w	(v_demo_mode).w				; is this an ending demo?
		bpl.s	.not_endingdemo				; if not, branch
		move.w	#540,(v_countdown).w			; run demo for 9 seconds instead
		cmpi.w	#4,(v_credits_num).w			; is this the SLZ ending demo?
		bne.s	.not_endingdemo				; if not, branch
		move.w	#510,(v_countdown).w			; run for 8.5 seconds instead

	.not_endingdemo:
		move.w	#4-1,d1

	.delayloop:
		move.b	#id_VBlank_Level,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		dbf	d1,.delayloop				; wait 4 frames for things to process

		bsr.w	PaletteFadeIn				; fade in from black
		tst.w	(v_demo_mode).w				; is this an ending demo?
		bmi.s	.skip_titlecard				; if yes, branch
		bra.s	.end_prelevel
; ===========================================================================

.skip_titlecard:
		moveq	#id_UPLC_Explode,d0
		jsr	UncPLC					; load explosion gfx

.end_prelevel:
		bclr	#7,(v_gamemode).w			; subtract $80 from gamemode to end pre-level stuff

; ---------------------------------------------------------------------------
; Main level loop (when	all title card and loading sequences are finished)
; ---------------------------------------------------------------------------

Level_MainLoop:
		bsr.w	PauseGame				; check for pause (enters another loop if paused)
		move.b	#id_VBlank_Level,(v_vblank_routine).w
		bsr.w	WaitForVBlank_CPU
		addq.w	#1,(v_frame_counter).w			; increment level timer
		bsr.w	MoveSonicInDemo
		bsr.w	LZWaterFeatures
		jsr	(ExecuteObjects).l
		jsr	ProcessSlowPLC
		tst.w	(f_restart).w				; is level restart flag set?
		bne.w	GM_Level				; if yes, branch
		tst.w	(v_debug_active).w			; is debug mode being used?
		bne.s	.skip_death				; if yes, branch
		cmpi.b	#id_Sonic_Death,(v_ost_player+ost_routine).w ; has Sonic just died?
		bhs.s	.skip_scroll				; if yes, branch

	.skip_death:
		bsr.w	DeformLayers

	.skip_scroll:
		jsr	(BuildSprites).l			; create sprite table
		jsr	(ObjPosLoad).l				; load objects for level
		bsr.w	PaletteCycle
		bsr.w	OscillateNumDo				; update oscillatory values for objects
		bsr.w	SynchroAnimate				; update values for synchronised object animations
		bsr.w	SignpostArtLoad				; check for level end, and load signpost graphics if needed

		cmpi.b	#id_Demo,(v_gamemode).w			; is this a demo?
		beq.s	Level_Demo				; if yes, branch
		cmpi.b	#id_Level,(v_gamemode).w
		beq.w	Level_MainLoop				; if gamemode is still $C (level), branch
		rts
; ===========================================================================

Level_Demo:
		tst.w	(f_restart).w				; is level set to restart?
		bne.s	.end_of_demo				; if yes, branch
		tst.w	(v_countdown).w				; is there time left on the demo?
		beq.s	.end_of_demo				; if not, branch
		cmpi.b	#id_Demo,(v_gamemode).w
		beq.w	Level_MainLoop				; if gamemode is 8 (demo), branch
		move.b	#id_Sega,(v_gamemode).w			; go to Sega screen
		rts
; ===========================================================================

.end_of_demo:
		cmpi.b	#id_Demo,(v_gamemode).w			; is gamemode still 8 (demo)?
		bne.s	.fade_out				; if not, branch
		move.b	#id_Sega,(v_gamemode).w			; go to Sega screen
		tst.w	(v_demo_mode).w				; is this a regular demo & not ending sequence?
		bpl.s	.fade_out				; if yes, branch
		move.b	#id_Credits,(v_gamemode).w		; go to credits

	.fade_out:
		move.w	#60,(v_countdown).w			; set timer to 1 second
		clr.w	(v_palfade_time).w

	.fade_loop:
		move.b	#id_VBlank_Level,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bsr.w	MoveSonicInDemo
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		jsr	(ObjPosLoad).l
		subq.w	#1,(v_palfade_time).w			; decrement time until next palette update
		bpl.s	.wait					; branch if positive
		move.w	#2,(v_palfade_time).w			; set timer to 2 frames
		bsr.w	Darken					; decrease brightness

	.wait:
		tst.w	(v_countdown).w				; has main timer hit 0?
		bne.s	.fade_loop				; if not, branch
		rts

; ---------------------------------------------------------------------------
; Subroutine to check Sonic's position and load signpost graphics
; ---------------------------------------------------------------------------

SignpostArtLoad:
		tst.w	(v_debug_active).w			; is debug mode	being used?
		bne.w	.exit					; if yes, branch
		cmpi.b	#2,(v_act).w				; is act number 02 (act 3)?
		beq.s	.exit					; if yes, branch

		move.w	(v_camera_x_pos).w,d0
		move.w	(v_boundary_right).w,d1
		subi.w	#$100,d1
		cmp.w	d1,d0					; has Sonic reached the	edge of	the level?
		blt.s	.exit					; if not, branch
		tst.b	(f_hud_time_update).w
		beq.s	.exit
		cmp.w	(v_boundary_left).w,d1
		beq.s	.exit
		move.w	d1,(v_boundary_left).w			; move left boundary to current screen position

	.exit:
		rts
