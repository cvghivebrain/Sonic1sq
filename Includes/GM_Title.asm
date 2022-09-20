; ---------------------------------------------------------------------------
; Title	screen
; ---------------------------------------------------------------------------

GM_Title:
		play.b	1, bsr.w, cmd_Stop			; stop music
		bsr.w	ClearPLC
		bsr.w	PaletteFadeOut				; fade from previous gamemode to black
		disable_ints
		bsr.w	DacDriverLoad
		lea	(vdp_control_port).l,a6
		move.w	#$8004,(a6)				; normal colour mode
		move.w	#$8200+(vram_fg>>10),(a6)		; set foreground nametable address
		move.w	#$8400+(vram_bg>>13),(a6)		; set background nametable address
		move.w	#$9001,(a6)				; 64x32 cell plane size
		move.w	#$9200,(a6)				; window vertical position 0 (i.e. disabled)
		move.w	#$8B03,(a6)				; single pixel line horizontal scrolling
		move.w	#$8720,(a6)				; set background colour (palette line 2, entry 0)
		clr.b	(f_water_pal_full).w
		bsr.w	ClearScreen

		lea	(v_ost_all).w,a1			; RAM address to start clearing
		move.w	#loops_to_clear_ost,d1			; size of RAM block to clear
		bsr.w	ClearRAM				; fill OST with 0

		lea	(v_pal_dry_next).w,a1
		move.w	#loops_to_clear_pal,d1
		bsr.w	ClearRAM				; clear next palette

		moveq	#id_Pal_Sonic,d0			; load Sonic's palette
		bsr.w	PalLoad_Next				; palette will be shown after fading in
		move.l	#CreditsText,(v_ost_credits).w		; load "SONIC TEAM PRESENTS" object
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		bsr.w	PaletteFadeIn				; fade in to "SONIC TEAM PRESENTS" screen from black
		moveq	#id_VBlank_Title,d1
		move.w	#60,d0
		bsr.w	WaitLoop				; freeze for 1 second
		disable_ints

		move.b	#0,(v_last_lamppost).w			; clear lamppost counter
		move.w	#0,(v_debug_active).w			; disable debug item placement mode
		move.w	#0,(v_demo_mode).w			; disable debug mode
		move.w	#id_GHZ_act1,(v_zone).w			; set level to GHZ act 1 (0000)
		move.w	#0,(v_palcycle_time).w			; disable palette cycling
		bsr.w	PaletteFadeOut				; fade out "SONIC TEAM PRESENTS" screen to black
		moveq	#id_KPLC_Title,d0
		jsr	KosPLC
		bsr.w	LoadPerZone				; this must go after KosPLC
		bsr.w	LevelParameterLoad			; set level boundaries and Sonic's start position
		bsr.w	DeformLayers
		bsr.w	LevelLayoutLoad				; load GHZ1 level layout including background
		disable_ints
		bsr.w	ClearScreen
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_bg1_x_pos).w,a3
		lea	(v_level_layout+level_max_width).w,a4	; background layout start address ($FFFFA440)
		move.w	#draw_bg,d2
		bsr.w	DrawChunks				; draw background
		
		lea	($FF0000).l,a1				; RAM buffer
		lea	(KosMap_Title).l,a0			; title screen mappings
		locVRAM	vram_fg+(sizeof_vram_row*4)+(3*2),d0	; foreground, x=3, y=4
		moveq	#$22,d1					; width
		moveq	#$16,d2					; height
		move.w	#tile_Kos_TitleFg,d3			; tile setting
		bsr.w	LoadTilemap

		moveq	#id_Pal_Title,d0			; load title screen palette
		bsr.w	PalLoad_Next
		play.b	1, bsr.w, mus_TitleScreen		; play title screen music
		move.b	#0,(f_debug_enable).w			; disable debug mode
		move.w	#406,(v_countdown).w			; run title screen for 406 frames
		lea	(v_ost_psb).w,a1
		jsr	DeleteChild

		move.l	#TitleSonic,(v_ost_titlesonic).w	; load big Sonic object
		move.l	#PSBTM,(v_ost_psb).w			; load "PRESS START BUTTON" object

		tst.b   (v_console_region).w			; is console Japanese?
		bpl.s   .isjap					; if yes, branch
		move.l	#PSBTM,(v_ost_tm).w			; load "TM" object
		move.b	#id_frame_psb_tm,(v_ost_tm+ost_frame).w
	.isjap:
		move.l	#PSBTM,(v_ost_titlemask).w		; load object which hides part of Sonic
		move.b	#id_frame_psb_mask,(v_ost_titlemask+ost_frame).w
		jsr	(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr	(BuildSprites).l
		move.w	#0,(v_title_d_count).w			; reset d-pad counter
		enable_display
		bsr.w	PaletteFadeIn				; fade in to title screen from black

; ---------------------------------------------------------------------------
; Title	screen main loop
; ---------------------------------------------------------------------------

Title_MainLoop:
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		jsr	(ExecuteObjects).l			; run all objects
		bsr.w	DeformLayers				; scroll background
		jsr	(BuildSprites).l			; create sprite table
		bsr.w	PCycle_Title				; animate water palette
		move.w	(v_ost_player+ost_x_pos).w,d0		; x pos of dummy object (there is no actual object loaded)
		addq.w	#2,d0
		move.w	d0,(v_ost_player+ost_x_pos).w		; move dummy 2px to the right
		bsr.s	Title_Dpad
		tst.w	(v_countdown).w				; has counter hit 0? (started at 406)
		beq.w	PlayDemo				; if yes, branch
		andi.b	#btnStart,(v_joypad_press_actual).w	; check if Start is pressed
		beq.s	Title_MainLoop				; if not, branch
		
		tst.b	(f_levelselect_cheat).w			; check if level select code is on
		beq.w	PlayLevel				; if not, play level
		btst	#bitA,(v_joypad_hold_actual).w		; check if A is pressed
		beq.w	PlayLevel				; if not, play level
		bra.w	LevSel_Init				; goto level select
		
Title_Dpad:
		tst.b	(f_levelselect_cheat).w
		bne.s	.exit					; branch if code has been entered
		lea	(LevSelCode).l,a0			; get cheat code
		move.w	(v_title_d_count).w,d0			; get number of times d-pad has been pressed in correct order
		adda.w	d0,a0					; jump to relevant position in sequence
		move.b	(v_joypad_press_actual).w,d0		; get button press
		andi.b	#btnDir,d0				; read only UDLR buttons
		beq.s	.exit					; branch if not pressed
		cmp.b	(a0),d0					; does button press match the cheat code?
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
		play.b	1, bsr.w, sfx_Ring			; play ring sound
		rts
		
LevSelCode:	dc.b btnUp,btnDn,btnL,btnR,$FF
		even
; ===========================================================================

LevSel_Init:
		moveq	#id_Pal_LevelSel,d0
		bsr.w	PalLoad_Now				; load level select palette
		lea	(v_hscroll_buffer).w,a1
		move.w	#loops_to_clear_hscroll,d1
		bsr.w	ClearRAM				; clear hscroll buffer (in RAM)

		move.l	#0,(v_fg_y_pos_vsram).w
		disable_ints
		
		locVRAM	vram_bg,d0
		move.l	#sizeof_vram_bg,d1
		moveq	#0,d2
		bsr.w	ClearVRAM				; clear bg nametable (in VRAM)

		bsr.w	LevSel_Display

; ---------------------------------------------------------------------------
; Level	Select loop
; ---------------------------------------------------------------------------

LevelSelect:
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bsr.s	LevSel_Control
		bsr.s	LevSel_Hold
		bsr.w	LevSel_Select
		beq.s	.stay					; branch if d0 is 0
		rts						; exit level select if do is 1
	.stay:
		bra.s	LevelSelect

linesize:	equ LevSel_Strings_end1-LevSel_Strings-6	; characters per line
linecount:	equ (LevSel_Strings_end2-LevSel_Strings)/(linesize+6) ; number of lines
lineleft:	equ 1						; where on screen to start drawing
linetop:	equ 4
linestart:	equ (sizeof_vram_row*linetop)+(lineleft*2)	; address in nametable
linecolumn:	equ 19						; lines per column (set as linecount for 1 column)
columnwidth:	equ linesize+2					; spacing between columns
linesound:	equ (LevSel_Strings_sound-LevSel_Strings)/(linesize+6) ; line number with sound test
linecharsel:	equ (LevSel_Strings_charsel-LevSel_Strings)/(linesize+6) ; line number with character select
charselsize:	equ LevSel_CharStrings_end-LevSel_CharStrings	; characters per character name

LevSel_Control:
		move.w	(v_levelselect_item).w,d0
		move.b	(v_joypad_press_actual).w,d1
		beq.s	.exit					; branch if nothing is pressed
		move.w	#8,(v_levelselect_hold_delay).w		; reset timer for autoscroll
		
		btst	#bitDn,d1
		beq.s	.not_down				; branch if down isn't pressed
		bsr.s	LevSel_Down
		
	.not_down:
		btst	#bitUp,d1
		beq.s	.not_up					; branch if up isn't pressed
		bsr.s	LevSel_Up
		
	.not_up:
		btst	#bitR,d1
		beq.s	.not_right				; branch if right isn't pressed
		bsr.s	LevSel_Right
		
	.not_right:
		btst	#bitL,d1
		beq.s	.not_left				; branch if right isn't pressed
		bsr.w	LevSel_Left
		
	.not_left:
		move.w	d0,(v_levelselect_item).w		; set new selection
		bra.w	LevSel_Display
		
	.exit:
		rts

LevSel_Hold:
		move.w	(v_levelselect_item).w,d0
		move.b	(v_joypad_hold_actual).w,d1
		andi.b	#btnUp+btnDn,d1				; is up/down currently held?
		beq.s	.exit					; branch if not
		subq.w	#1,(v_levelselect_hold_delay).w		; decrement timer
		bpl.s	.exit					; branch if time remains
		move.w	#8,(v_levelselect_hold_delay).w		; reset timer
		
		btst	#bitDn,d1
		beq.s	.not_down				; branch if down isn't held
		bsr.s	LevSel_Down
		
	.not_down:
		btst	#bitUp,d1
		beq.s	.not_up					; branch if up isn't held
		bsr.s	LevSel_Up
		
	.not_up:
		move.w	d0,(v_levelselect_item).w		; set new selection
		bra.w	LevSel_Display
		
	.exit:
		rts

LevSel_Down:
		add.w	#1,d0					; goto next item
		cmp.w	#linecount,d0
		bne.s	.exit					; branch if item is valid
		moveq	#0,d0					; jump to start after last item
	.exit:
		rts

LevSel_Up:
		sub.w	#1,d0					; goto previous item
		bpl.s	.exit					; branch if item is valid
		move.w	#linecount-1,d0				; jump to end before first item
	.exit:
		rts

LevSel_Right:
		cmp.w	#linesound,d0
		bne.s	.not_soundtest				; branch if not on sound test
		add.w	#1,(v_levelselect_sound).w		; increment sound test
		cmp.w	#$50,(v_levelselect_sound).w
		bne.s	.exit					; branch if valid
		move.w	#0,(v_levelselect_sound).w		; reset to 0 if above max
		bra.s	.exit
	.not_soundtest:
		cmp.w	#linecharsel,d0
		bne.s	.not_charsel				; branch if not on character select
		add.w	#1,(v_character1).w			; increment character select
		cmp.w	#3,(v_character1).w
		bne.s	.exit					; branch if valid
		move.w	#0,(v_character1).w			; reset to 0 if above max
		bra.s	.exit
	.not_charsel:
		add.w	#linecolumn,d0				; goto next column
		cmp.w	#linecount,d0
		blt.s	.exit					; branch if item is valid
		sub.w	#linecolumn,d0				; undo
	.exit:
		rts

LevSel_Left:
		cmp.w	#linesound,d0
		bne.s	.not_soundtest				; branch if not on sound test
		sub.w	#1,(v_levelselect_sound).w		; increment sound test
		bpl.s	.exit					; branch if valid
		move.w	#$4F,(v_levelselect_sound).w		; jump to $4F if below 0
		bra.s	.exit
	.not_soundtest:
		cmp.w	#linecharsel,d0
		bne.s	.not_charsel				; branch if not on character select
		sub.w	#1,(v_character1).w			; increment character select
		bpl.s	.exit					; branch if valid
		move.w	#2,(v_character1).w			; jump to 2 if below 0
		bra.s	.exit
	.not_charsel:
		sub.w	#linecolumn,d0				; goto previous column
		bpl.s	.exit					; branch if item is valid
		add.w	#linecolumn,d0				; undo
	.exit:
		rts

LevSel_Display:
		lea	(LevSel_Strings).l,a1
		lea	(LevSel_CharStrings).l,a2
		lea	(vdp_data_port).l,a6
		locVRAM	vram_bg+linestart,d3
		move.l	d3,d4
		move.w	#linecount-1,d0
		moveq	#0,d5
		moveq	#0,d6
	
	.loop:
		move.l	d3,4(a6)
		bsr.w	LevSel_Line				; draw line of text
		lea	6(a1),a1				; next string
		addi.l	#sizeof_vram_row<<16,d3			; jump to next line in nametable
		add.w	#1,d5					; count line number in current column
		add.w	#1,d6					; count line number overall
		cmp.w	#linecolumn,d5
		bne.s	.not_last				; branch if not last line in column
		add.l	#(columnwidth*2)<<16,d4			; jump to next column
		move.l	d4,d3					; update drawing position
		moveq	#0,d5
	
	.not_last:
		dbf	d0,.loop				; repeat for all lines
		rts
		
LevSel_Line:
		move.w	#linesize-1,d1
		
	.loop:
		moveq	#0,d2
		move.b	(a1)+,d2				; get character
		cmp.w	#linesound,d6				; d6 = current line being drawn
		bne.s	.not_soundtest				; branch if not the sound test
		cmp.w	#1,d1
		bgt.s	.not_soundtest				; branch if not the last 2 characters on the line
		move.w	(v_levelselect_sound).w,d2		; get current sound test
		add.b	#$80,d2
		lsl.w	#2,d1					; multiply character number by 4 (so it's either 4 or 0)
		lsr.b	d1,d2					; move high nybble to low if d1 is 4
		and.b	#$F,d2					; read single nybble
		add.b	#$30,d2					; convert to character
		lsr.w	#2,d1					; restore d1
		
	.not_soundtest:
		cmp.w	#linecharsel,d6				; d6 = current line being drawn
		bne.s	.not_charsel				; branch if not the character select
		cmp.w	#charselsize-1,d1
		bgt.s	.not_charsel				; branch if not the last 8 characters on the line
		move.w	(v_character1).w,d2			; get character id
		lsl.w	#3,d2					; multiply by 8
		sub.w	#charselsize-1,d1
		neg.w	d1					; invert value d1
		add.w	d1,d2					; add d1
		neg.w	d1
		add.w	#charselsize-1,d1			; restore d1
		move.b	(a2,d2.w),d2				; get character
		
	.not_charsel:
		add.w	#tile_Kos_Text+tile_pal4+tile_hi-$20,d2	; convert to tile
		cmp.w	(v_levelselect_item).w,d6		; d6 = current line being drawn
		bne.s	.unselected				; branch if line is not selected
		sub.w	#$2000,d2				; use yellow text
		
	.unselected:
		move.w	d2,(a6)					; write to nametable in VRAM
		dbf	d1,.loop				; repeat for all characters in line
		rts
		
LevSel_Select:
		move.b	(v_joypad_press_actual).w,d0
		andi.b	#btnABC+btnStart,d0			; is A, B, C, or Start pressed?
		beq.s	.nothing				; branch if not
		lea	(LevSel_Strings).l,a1
		move.w	(v_levelselect_item).w,d1
		mulu.w	#linesize+6,d1
		add.w	#linesize,d1
		lea	(a1,d1.w),a1				; jump to data after string for current line
		move.w	(a1)+,d2				; get item type
		add.w	d2,d2
		move.w	LevSel_Index(pc,d2.w),d2
		jsr	LevSel_Index(pc,d2.w)
		cmp.w	#linesound,(v_levelselect_item).w
		beq.s	.nothing				; don't exit if on the sound test
		moveq	#1,d0					; set flag to exit level select
		rts
		
	.nothing:
		moveq	#0,d0
		rts
		
LevSel_Index:	index *
		ptr LevSel_Level
		ptr LevSel_Special
		ptr LevSel_Ending
		ptr LevSel_Credits
		ptr LevSel_Gamemode
		ptr LevSel_Sound
		
LevSel_Level:
		move.w	(a1)+,d0
		move.b	d0,(v_zone).w				; set zone
		move.w	(a1)+,d0
		move.b	d0,(v_act).w				; set act

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
		play.b	1, bsr.w, cmd_Fade			; fade out music
		rts
		
LevSel_Special:
		move.w	(a1)+,d0
		move.b	d0,(v_last_ss_levelid).w		; set Special Stage number
		move.b	#id_Special,(v_gamemode).w		; set gamemode to $10 (Special Stage)
		clr.w	(v_zone).w				; clear	level
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.l	#5000,(v_score_next_life).w		; extra life is awarded at 50000 points
		rts
		
LevSel_Ending:
		move.w	(a1)+,d0
		move.b	d0,(v_zone).w				; set zone
		move.w	(a1)+,d0
		move.b	d0,(v_act).w				; set act
		move.b	#id_Ending,(v_gamemode).w		; set gamemode to $18 (Ending)
		rts
		
LevSel_Gamemode:
		move.w	(a1)+,d0
		move.b	d0,(v_gamemode).w			; set gamemode
		rts
		
LevSel_Credits:
		move.w	(a1)+,d0
		move.b	d0,(v_credits_num).w			; set credits number
		move.b	#id_Credits,(v_gamemode).w		; set gamemode to credits
		rts
		
LevSel_Sound:
		btst.b	#bitA,(v_joypad_press_actual).w		; is button A pressed?
		beq.s	.play					; branch if not
		add.w	#$10,(v_levelselect_sound).w		; skip $10
		cmp.w	#$4F,(v_levelselect_sound).w
		ble.s	.exit					; branch if valid
		move.w	#0,(v_levelselect_sound).w		; reset to 0
	.exit:
		bra.w	LevSel_Display				; update number
		
	.play:
		move.w	(v_levelselect_sound).w,d0
		addi.w	#$80,d0
		bra.w	PlaySound1

; ---------------------------------------------------------------------------
; Demo mode
; ---------------------------------------------------------------------------

PlayDemo:
		play.b	1, bsr.w, cmd_Fade			; fade out music
		move.w	(v_demo_num).w,d0			; load demo number
		andi.w	#7,d0
		add.w	d0,d0
		move.w	DemoLevelArray(pc,d0.w),d0		; load level number for	demo
		move.w	d0,(v_zone).w
		addq.w	#1,(v_demo_num).w			; add 1 to demo number
		cmpi.w	#4,(v_demo_num).w			; is demo number less than 4?
		blo.s	.demo_0_to_3				; if yes, branch
		move.w	#0,(v_demo_num).w			; reset demo number to	0

	.demo_0_to_3:
		move.w	#1,(v_demo_mode).w			; turn demo mode on
		move.b	#id_Demo,(v_gamemode).w			; set screen mode to 08 (demo)
		cmpi.w	#id_Demo_SS,d0				; is level number 0600 (special	stage)?
		bne.s	.demo_level				; if not, branch
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

		include_demo_list				; Includes\Demo Pointers.asm

; ---------------------------------------------------------------------------
; Level	select menu text strings
; ---------------------------------------------------------------------------

lsline:		macro string,type,zone,act
		if strlen(\string)&1=1
		inform	3,"Level select strings must be of even length."
		endc
		dc.b \string
		even
		dc.w type,zone,act
		endm

LevSel_Strings:	lsline "GREEN HILL ZONE  1",id_LevSel_Level,id_GHZ,0
	LevSel_Strings_end1:
		lsline "                 2",id_LevSel_Level,id_GHZ,1
		lsline "                 3",id_LevSel_Level,id_GHZ,2
		lsline "MARBLE ZONE      1",id_LevSel_Level,id_MZ,0
		lsline "                 2",id_LevSel_Level,id_MZ,1
		lsline "                 3",id_LevSel_Level,id_MZ,2
		lsline "SPRING YARD ZONE 1",id_LevSel_Level,id_SYZ,0
		lsline "                 2",id_LevSel_Level,id_SYZ,1
		lsline "                 3",id_LevSel_Level,id_SYZ,2
		lsline "LABYRINTH ZONE   1",id_LevSel_Level,id_LZ,0
		lsline "                 2",id_LevSel_Level,id_LZ,1
		lsline "                 3",id_LevSel_Level,id_LZ,2
		lsline "STAR LIGHT ZONE  1",id_LevSel_Level,id_SLZ,0
		lsline "                 2",id_LevSel_Level,id_SLZ,1
		lsline "                 3",id_LevSel_Level,id_SLZ,2
		lsline "SCRAP BRAIN ZONE 1",id_LevSel_Level,id_SBZ,0
		lsline "                 2",id_LevSel_Level,id_SBZ,1
		lsline "                 3",id_LevSel_Level,id_LZ,3
		lsline "FINAL ZONE        ",id_LevSel_Level,id_SBZ,2
		lsline "SPECIAL STAGE    1",id_LevSel_Special,0,0
		lsline "                 2",id_LevSel_Special,1,0
		lsline "                 3",id_LevSel_Special,2,0
		lsline "                 4",id_LevSel_Special,3,0
		lsline "                 5",id_LevSel_Special,4,0
		lsline "                 6",id_LevSel_Special,5,0
		lsline "GOOD ENDING       ",id_LevSel_Ending,id_EndZ,0
		lsline "BAD ENDING        ",id_LevSel_Ending,id_EndZ,1
		lsline "CREDITS           ",id_LevSel_Credits,0,0
		lsline "HIDDEN CREDITS    ",id_LevSel_Gamemode,id_HiddenCredits,0
		lsline "END SCREEN        ",id_LevSel_Credits,0,0
		lsline "TRY AGAIN SCREEN  ",id_LevSel_Credits,0,0
		lsline "CONTINUE SCREEN   ",id_LevSel_Gamemode,id_Continue,0
	LevSel_Strings_sound:
		lsline "SOUND SELECT   $XX",id_LevSel_Sound,0,0
	LevSel_Strings_charsel:
		lsline "CHARACTER XXXXXXXX",id_LevSel_Level,id_GHZ,0
	LevSel_Strings_end2:

LevSel_CharStrings:
		dc.b "   SONIC"
	LevSel_CharStrings_end:
		dc.b " KETCHUP"
		dc.b " MUSTARD"
		dc.b "   TAILS"
		dc.b "KNUCKLES"
		even
		