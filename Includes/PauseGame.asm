; ---------------------------------------------------------------------------
; Subroutine to	pause the game
; ---------------------------------------------------------------------------

PauseGame:
		nop
		tst.b	(f_pause).w
		bne.s	.paused					; branch if already paused
		btst	#bitStart,(v_joypad_press_actual).w
		bne.s	.pause_now				; branch if Start is pressed
		rts

	.pause_now:
		move.b	#1,(f_pause).w				; set pause flag (also stops palette/gfx animations, time)
		
	.paused:
		move.b	#1,(v_snddriver_ram+f_pause_sound).w	; pause music

Pause_Loop:
		move.b	#id_VBlank_Pause,(v_vblank_routine).w
		bsr.w	WaitForVBlank				; wait for next frame
		move.b	(v_joypad_press_actual).w,d0		; read joypad presses
		tst.b	(f_debug_cheat).w
		beq.s	.chk_start				; branch if debug mode is off
		
		btst	#bitA,d0				; is button A pressed?
		beq.s	.chk_bc					; if not, branch

		move.b	#id_Title,(v_gamemode).w		; set game mode to 4 (title screen)
		nop	
		bra.s	Unpause
; ===========================================================================

	.chk_bc:
		btst	#bitB,(v_joypad_hold_actual).w		; is button B held?
		bne.s	Pause_SlowMo				; if yes, branch
		btst	#bitC,d0				; is button C pressed?
		bne.s	Pause_SlowMo				; if yes, branch
		btst	#bitM,(v_joypad_press_actual_xyz).w	; is Mode pressed?
		bne.s	Pause_Debug				; if yes, branch

	.chk_start:
		btst	#bitStart,d0				; is Start button pressed?
		beq.s	Pause_Loop				; if not, branch

Unpause:
		clr.b	(f_pause).w				; unpause the game
		move.b	#$80,(v_snddriver_ram+f_pause_sound).w	; unpause the music
		rts	

; ---------------------------------------------------------------------------
; Run the game for 1 frame and immediately pause again
; ---------------------------------------------------------------------------

Pause_SlowMo:
		move.b	#$80,(v_snddriver_ram+f_pause_sound).w	; unpause the music
		rts	

; ---------------------------------------------------------------------------
; Pause debug menu
; ---------------------------------------------------------------------------

Pause_Debug:
		bsr.w	ClearVRAM_Tiles				; clear fg/bg
		bsr.w	ClearVRAM_HScroll			; clear hscroll table
		bsr.w	ClearRAM_Sprites			; clear sprites
		clr.w	(v_fg_y_pos_vsram).w
		moveq	#id_UPLC_PauseDebug,d0
		jsr	UncPLC					; load debug text gfx on top of HUD gfx
		move.w	#cYellow,(v_pal_dry_line2+12).w		; replace white with yellow in palette line 2
		
Pause_Debug_Main:
		moveq	#1,d0					; x pos
		moveq	#1,d1					; y pos
		moveq	#0,d2
		lea	(vdp_data_port).l,a1			; data port
		lea	Str_DebugMenu(pc),a2			; address of string
		bsr.w	DrawString
		addq.b	#2,d1
		lea	Str_DebugBtns(pc),a2
		bsr.w	DrawString
		bsr.w	Pause_Debug_DrawMain
		
	Pause_Debug_Loop:
		move.b	#id_VBlank_PauseDebug,(v_vblank_routine).w
		bsr.w	WaitForVBlank				; wait for next frame
		btst	#bitM,(v_joypad_press_actual_xyz).w
		bne.s	Pause_Debug_Exit			; branch if Mode is pressed
		lea	(v_debugmenu_item).w,a1
		btst	#bitC,(v_joypad_press_actual).w
		beq.s	.not_c					; branch if C isn't pressed
		cmpi.w	#0,(a1)
		beq.s	Pause_Debug_Obj				; branch if object viewer is selected
		
	.not_c:
		moveq	#3,d0					; number of items in menu
		moveq	#3,d1					; number of items per column
		bsr.w	NavigateMenu				; read control inputs
		beq.s	Pause_Debug_Loop			; branch if no inputs
		bsr.w	Pause_Debug_DrawMain			; redraw menu
		bra.s	Pause_Debug_Loop		

Pause_Debug_Exit:
		moveq	#id_UPLC_HUD,d0
		jsr	UncPLC					; load HUD gfx
		jsr	DrawTilesAtStart			; redraw bg/fg
		bsr.w	ExecuteObjects_DisplayOnly		; read all objects for display
		bsr.w	BuildSprites				; redraw sprites
		move.w	#cWhite,(v_pal_dry_line2+12).w
		move.w	(v_camera_y_pos).w,(v_fg_y_pos_vsram).w
		bra.w	Pause_Loop				; return to regular pause
		
Pause_Debug_Obj:
		bsr.w	ClearVRAM_Tiles_FG			; clear fg
		clr.w	(a1)					; highlight first object in list
		moveq	#1,d0					; x pos
		moveq	#1,d1					; y pos
		moveq	#0,d2
		lea	(vdp_data_port).l,a1			; data port
		lea	Str_ObjMenu(pc),a2			; address of string
		bsr.w	DrawString
		addq.b	#2,d1
		lea	Str_ObjBtns(pc),a2
		bsr.w	DrawString
		bsr.w	Pause_Debug_DrawObj
		
	Pause_Debug_Obj_Loop:
		move.b	#id_VBlank_PauseDebug,(v_vblank_routine).w
		bsr.w	WaitForVBlank				; wait for next frame
		move.w	#countof_ost,d0				; number of items in menu
		moveq	#24,d1					; number of items per column
		lea	(v_debugmenu_item).w,a1
		btst	#bitB,(v_joypad_press_actual).w
		bne.s	.back
		bsr.w	NavigateMenu				; read control inputs
		beq.s	Pause_Debug_Obj_Loop			; branch if no inputs
		bsr.w	Pause_Debug_DrawObj			; redraw menu
		bra.s	Pause_Debug_Obj_Loop
		
	.back:
		bsr.w	ClearVRAM_Tiles_FG			; clear fg
		clr.w	(a1)					; highlight first object in list
		bra.w	Pause_Debug_Main			; return to main menu
		
; ---------------------------------------------------------------------------
; Draw main menu
; ---------------------------------------------------------------------------

Pause_Debug_DrawMain:
		moveq	#1,d0					; x pos
		moveq	#6,d1					; y pos
		moveq	#0,d5
		moveq	#3-1,d6					; number of lines
		lea	Str_Main1(pc),a2			; address of string
		lea	(vdp_data_port).l,a1			; data port
		
	.loop:
		moveq	#0,d2
		cmp.w	(v_debugmenu_item).w,d5
		bne.s	.no_highlight				; branch if current line shouldn't be highlighted
		move.w	#tile_pal2,d2				; use palette line 2
		
	.no_highlight:
		bsr.w	DrawString
		addq.b	#2,d1					; down 2 rows
		addq.w	#1,d5					; next line
		dbf	d6,.loop
		rts

Str_DebugMenu:	dc.b "DEBUG MENU",0
Str_DebugBtns:	dc.b "MODE@ BACK  C@ SELECT",0
Str_Main1:	dc.b "OBJECT VIEWER",0
Str_Main2:	dc.b "VRAM VIEWER",0
Str_Main3:	dc.b "SOMETHING ELSE",0
Str_ObjMenu:	dc.b "OBJECT VIEWER",0
Str_ObjBtns:	dc.b "A@ DELETE  B@ BACK  C@ SELECT",0
		even

; ---------------------------------------------------------------------------
; Draw object viewer
; ---------------------------------------------------------------------------

Pause_Debug_DrawObj:
		moveq	#0,d0					; x pos
		moveq	#4,d1					; y pos
		moveq	#0,d5
		moveq	#countof_ost-1,d6
		lea	(vdp_data_port).l,a1			; data port
		lea	(v_ost_all).w,a0
		
	.loop:
		tst.l	ost_id(a0)
		bne.s	.obj_found				; branch if object is present
		lea	Str_None(pc),a2
		bra.s	.skip_name
		
	.obj_found:
		moveq	#0,d2
		move.b	ost_name(a0),d2				; get name of object
		lsl.w	#3,d2					; multiply by 8
		lea	Str_Names(pc,d2.w),a2			; address of string in table
		
	.skip_name:
		moveq	#0,d2
		cmp.w	(v_debugmenu_item).w,d5
		bne.s	.no_highlight				; branch if current line shouldn't be highlighted
		move.w	#tile_pal2,d2				; use palette line 2
		
	.no_highlight:
		bsr.w	DrawString8
		addq.b	#1,d1					; down 1 row
		addq.w	#1,d5					; next line
		move.w	d5,d2
		beq.s	.no_wrap
		divu.w	#24,d2
		swap	d2
		tst.w	d2
		bne.s	.no_wrap				; branch if d5 isn't a multiple of 24
		addq.b	#8,d0					; next column
		moveq	#4,d1					; return to top
		
	.no_wrap:
		lea	sizeof_ost(a0),a0			; next object
		dbf	d6,.loop
		rts
	
objname:	macro txt,name
		StrId_\name: equ (*-Str_Names)/8
		dc.b \txt
		endm
	
Str_None:	dc.b "[       "
Str_Names:	objname "UNKNOWN ",Unknown
		objname "SONIC   ",Sonic
		objname "PLATFORM",Platform
		objname "RING    ",Ring
		objname "BIGRING ",BigRing
		objname "RINGLOSS",RingLoss
		objname "SPARKLE ",Sparkle
		objname "BONUS   ",Bonus
		objname "LAMPPOST",Lamppost
		objname "SIGNPOST",Signpost
		objname "SPRING  ",Spring
		objname "MONITOR ",Monitor
		objname "POWERUP ",PowerUp
		objname "SHIELD  ",Shield
		objname "INVINCIB",Invincible
		objname "EXPLOSIO",Explosion
		objname "POINTS  ",Points
		objname "BUTTON  ",Button
		objname "SCENERY ",Scenery
		objname "WATERSND",WaterSound
		objname "DROWN   ",Drown
		objname "ANIMAL  ",Animal
		objname "BALLHOG ",BallHog
		objname "BALL    ",Ball
		objname "BATBRAIN",Batbrain
		objname "BOMB    ",Bomb
		objname "BOMBFUSE",Fuse
		objname "BOMBFRAG",Frag
		objname "BURROBOT",Burrobot
		objname "BUZZBOMB",BuzzBomber
		objname "MISSILE ",Missile
		objname "CATERKIL",Caterkiller
		objname "CATERSEG",CaterSegment
		objname "CHOPPER ",Chopper
		objname "CRABMEAT",Crabmeat
		objname "JAWS    ",Jaws
		objname "MOTOBUG ",MotoBug
		objname "SMOKE   ",Smoke
		objname "NEWTRON ",Newtron
		objname "ORBINAUT",Orbinaut
		objname "ORBSPIKE",OrbSpike
		objname "ROLLER  ",Roller
		objname "SPLATS  ",Splats
		objname "YADRIN  ",Yadrin
		objname "FIREBALL",Fireball
		objname "FIREMAKE",FireMaker
		objname "FIRE    ",Fire
		objname "SPIKES  ",Spikes
		objname "BOSS    ",Boss
		objname "PRISON  ",Prison
		objname "CYLINDER",Cylinder
		objname "SMASHWAL",SmashWall
		objname "CHAIN   ",Chain
		objname "BRIDGE  ",Bridge
		objname "LEDGE   ",Ledge
		objname "ROCK    ",Rock
		objname "HELIX   ",Helix
		objname "HELIXSPI",HelixSpike
		objname "WALL    ",Wall
		objname "BLOCK   ",Block
		objname "BUBMAKER",BubbleMaker
		objname "BUBBLE  ",Bubble
		objname "CONVEYOR",Conveyor
		objname "CORK    ",Cork
		objname "DOOR    ",Door
		objname "GARGOYLE",Gargoyle
		objname "HARPOON ",Harpoon
		objname "POLE    ",Pole
		objname "SPLASH  ",Splash
		objname "WATERSUR",WaterSurface
		objname "WATERFAL",Waterfall
		objname "STOMPER ",Stomper
		objname "GRASSBLO",GrassBlock
		objname "GLASSBLO",GlassBlock
		objname "LAVA    ",Lava
		objname "LAVAFALL",LavaFall
		objname "LAVAFOUN",LavaFountain
		objname "LAVAWALL",LavaWall
		objname "PUSHBLOC",PushBlock
		objname "SMASHBLO",SmashBlock
		objname "COLLAPSE",CollapseFloor
		objname "TITLECAR",TitleCard
		objname "GAMEOVER",GameOver
		objname "GATE    ",Gate
		objname "SOLID   ",Solid
		objname "HUD     ",HUD
		objname "DEBUG   ",Debug
