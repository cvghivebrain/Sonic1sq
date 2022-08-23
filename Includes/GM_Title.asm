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
		moveq	#0,d0
		move.w	#loops_to_clear_ost,d1			; size of RAM block to clear
	.clear_ost:
		move.l	d0,(a1)+
		dbf	d1,.clear_ost				; fill OST ($D000-$EFFF) with 0

		locVRAM	0
		lea	(Nem_JapNames).l,a0			; load Japanese credits
		bsr.w	NemDec
		locVRAM	vram_title_credits			; $14C0
		lea	(Nem_CreditText).l,a0			; load alphabet
		bsr.w	NemDec
		lea	($FF0000).l,a1
		lea	(Eni_JapNames).l,a0			; load mappings for Japanese credits
		move.w	#0,d0
		bsr.w	EniDec

		copyTilemap	$FF0000,vram_fg,0,0,$28,$1C	; copy Japanese credits mappings to fg nametable in VRAM

		lea	(v_pal_dry_next).w,a1
		moveq	#0,d0
		move.w	#loops_to_clear_pal,d1
	.clear_pal:
		move.l	d0,(a1)+
		dbf	d1,.clear_pal				; clear next palette

		moveq	#id_Pal_Sonic,d0			; load Sonic's palette
		bsr.w	PalLoad_Next				; palette will be shown after fading in
		move.l	#CreditsText,(v_ost_credits).w		; load "SONIC TEAM PRESENTS" object
		jsr	(ExecuteObjects).l
		jsr	(BuildSprites).l
		bsr.w	PaletteFadeIn				; fade in to "SONIC TEAM PRESENTS" screen from black
		disable_ints

		move.b	#0,(v_last_lamppost).w			; clear lamppost counter
		move.w	#0,(v_debug_active).w			; disable debug item placement mode
		move.w	#0,(v_demo_mode).w			; disable debug mode
		move.w	#id_GHZ_act1,(v_zone).w			; set level to GHZ act 1 (0000)
		move.w	#0,(v_palcycle_time).w			; disable palette cycling
		moveq	#id_KPLC_Title,d0
		jsr	KosPLC
		bsr.w	LoadPerZone
		bsr.w	LevelParameterLoad			; set level boundaries and Sonic's start position
		bsr.w	DeformLayers
		bsr.w	LevelLayoutLoad				; load GHZ1 level layout including background
		bsr.w	PaletteFadeOut				; fade out "SONIC TEAM PRESENTS" screen to black
		disable_ints
		bsr.w	ClearScreen
		lea	(vdp_control_port).l,a5
		lea	(vdp_data_port).l,a6
		lea	(v_bg1_x_pos).w,a3
		lea	(v_level_layout+level_max_width).w,a4	; background layout start address ($FFFFA440)
		move.w	#draw_bg,d2
		bsr.w	DrawChunks				; draw background
		lea	($FF0000).l,a1
		lea	(KosMap_Title).l,a0			; load title screen mappings
		bsr.w	KosDec
		move.w	#(sizeof_KosMap_Title/2)-1,d0
		
	.loop_titlemap:
		add.w	#tile_Kos_TitleFg,(a1)+			; update tilemap with address of gfx
		dbf	d0,.loop_titlemap

		copyTilemap	$FF0000,vram_fg,3,4,$22,$16	; copy title screen mappings to fg nametable in VRAM

		moveq	#id_Pal_Title,d0			; load title screen palette
		bsr.w	PalLoad_Next
		play.b	1, bsr.w, mus_TitleScreen		; play title screen music
		move.b	#0,(f_debug_enable).w			; disable debug mode
		move.w	#$178,(v_countdown).w			; run title screen for $178 frames
		lea	(v_ost_psb).w,a1
		moveq	#0,d0
		move.w	#$F,d1					; should be $F; 7 only clears half the OST

	.clear_ost_psb:
		move.l	d0,(a1)+
		dbf	d1,.clear_ost_psb

		move.l	#TitleSonic,(v_ost_titlesonic).w	; load big Sonic object
		move.l	#PSBTM,(v_ost_psb).w			; load "PRESS START BUTTON" object

		if Revision=0
		else
			tst.b   (v_console_region).w		; is console Japanese?
			bpl.s   .isjap				; if yes, branch
		endc

		move.l	#PSBTM,(v_ost_tm).w			; load "TM" object
		move.b	#id_frame_psb_tm,(v_ost_tm+ost_frame).w
	.isjap:
		move.l	#PSBTM,(v_ost_titlemask).w		; load object which hides part of Sonic
		move.b	#id_frame_psb_mask,(v_ost_titlemask+ost_frame).w
		jsr	(ExecuteObjects).l
		bsr.w	DeformLayers
		jsr	(BuildSprites).l
		moveq	#id_PLC_Main,d0				; load lamppost, HUD, lives, ring & points graphics
		bsr.w	NewPLC					; do it over the next few frames
		move.w	#0,(v_title_d_count).w			; reset d-pad counter
		move.w	#0,(v_title_c_count).w			; reset C button counter
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
		bsr.w	RunPLC					; trigger decompression of items in PLC buffer
		move.w	(v_ost_player+ost_x_pos).w,d0		; x pos of dummy object (there is no actual object loaded)
		addq.w	#2,d0
		move.w	d0,(v_ost_player+ost_x_pos).w		; move dummy 2px to the right
		cmpi.w	#$1C00,d0
		blo.s	Title_Cheat				; branch if dummy is still left of $1C00

		move.b	#id_Sega,(v_gamemode).w			; go to Sega screen (takes approx. 1 min for dummy to reach $1C00)
		rts	
; ===========================================================================

Title_Cheat:
		tst.b	(v_console_region).w			; check	if the machine is US/EU or Japanese
		bpl.s	.japanese				; if Japanese, branch

		lea	(LevSelCode_US).l,a0			; load US/EU code
		bra.s	.overseas

	.japanese:
		lea	(LevSelCode_J).l,a0			; load JP code

	.overseas:
		move.w	(v_title_d_count).w,d0			; get number of times d-pad has been pressed in correct order
		adda.w	d0,a0					; jump to relevant position in sequence
		move.b	(v_joypad_press_actual).w,d0		; get button press
		andi.b	#btnDir,d0				; read only UDLR buttons
		cmp.b	(a0),d0					; does button press match the cheat code?
		bne.s	.reset_cheat				; if not, branch
		addq.w	#1,(v_title_d_count).w			; next button press
		tst.b	d0					; is d-pad currently pressed?
		bne.s	.count_c				; if yes, branch

		lea	(f_levelselect_cheat).w,a0		; cheat flag array
		move.w	(v_title_c_count).w,d1			; d1 = number of times C was pressed
		lsr.w	#1,d1					; divide by 2
		andi.w	#3,d1					; read only bits 0/1
		beq.s	.levelselect_only			; branch if 0
		tst.b	(v_console_region).w
		bpl.s	.levelselect_only			; branch if region is Japanese
		moveq	#1,d1
		move.b	d1,1(a0,d1.w)				; enable debug mode (C is pressed 2 or more times)

	.levelselect_only:
		move.b	#1,(a0,d1.w)				; activate cheat: no C = level select; CC+ = slowmo (US/EU); CC = slowmo (JP); CCCC = debug (JP); CCCCCC = hidden credits (JP)
		play.b	1, bsr.w, sfx_Ring			; play ring sound when code is entered
		bra.s	.count_c
; ===========================================================================

.reset_cheat:
		tst.b	d0					; is d-pad currently pressed?
		beq.s	.count_c				; if not, branch
		cmpi.w	#9,(v_title_d_count).w
		beq.s	.count_c
		move.w	#0,(v_title_d_count).w			; reset UDLR counter

.count_c:
		move.b	(v_joypad_press_actual).w,d0
		andi.b	#btnC,d0				; is C button pressed?
		beq.s	.c_not_pressed				; if not, branch
		addq.w	#1,(v_title_c_count).w			; increment C counter

	.c_not_pressed:
		tst.w	(v_countdown).w				; has counter hit 0? (started at $178)
		beq.w	PlayDemo				; if yes, branch
		andi.b	#btnStart,(v_joypad_press_actual).w	; check if Start is pressed
		beq.w	Title_MainLoop				; if not, branch

Title_PressedStart:
		tst.b	(f_levelselect_cheat).w			; check if level select code is on
		beq.w	PlayLevel				; if not, play level
		btst	#bitA,(v_joypad_hold_actual).w		; check if A is pressed
		beq.w	PlayLevel				; if not, play level

		moveq	#id_Pal_LevelSel,d0
		bsr.w	PalLoad_Now				; load level select palette
		lea	(v_hscroll_buffer).w,a1
		moveq	#0,d0
		move.w	#loops_to_clear_hscroll,d1

	.clear_hscroll:
		move.l	d0,(a1)+
		dbf	d1,.clear_hscroll			; clear hscroll buffer (in RAM)

		move.l	d0,(v_fg_y_pos_vsram).w
		disable_ints
		lea	(vdp_data_port).l,a6
		locVRAM	vram_bg
		move.w	#(sizeof_vram_bg/4)-1,d1

	.clear_bg:
		move.l	d0,(a6)
		dbf	d1,.clear_bg				; clear bg nametable (in VRAM)

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
		bsr.s	LevSel_Left
		
	.not_left:
		move.w	d0,(v_levelselect_item).w		; set new selection
		bra.s	LevSel_Display
		
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
		bra.s	LevSel_Display
		
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
		add.w	#linecolumn,d0				; goto next column
		cmp.w	#linecount,d0
		blt.s	.exit					; branch if item is valid
		sub.w	#linecolumn,d0				; undo
	.exit:
		rts

LevSel_Left:
		sub.w	#linecolumn,d0				; goto previous column
		bpl.s	.exit					; branch if item is valid
		add.w	#linecolumn,d0				; undo
	.exit:
		rts

LevSel_Display:
		lea	(LevSel_Strings).l,a1
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
		beq.s	.exit					; branch if not
		lea	(LevSel_Strings).l,a1
		move.w	(v_levelselect_item).w,d1
		mulu.w	#linesize+6,d1
		add.w	#linesize,d1
		lea	(a1,d1.w),a1				; jump to data after string for current line
		move.w	(a1)+,d2				; get item type
		add.w	d2,d2
		move.w	LevSel_Index(pc,d2.w),d2
		jsr	LevSel_Index(pc,d2.w)
		moveq	#1,d0					; set flag to exit level select
		rts
		
	.exit:
		moveq	#0,d0
		rts
		
LevSel_Index:	index *
		ptr LevSel_Level
		ptr LevSel_Special
		ptr LevSel_Ending
		ptr LevSel_Credits
		ptr LevSel_Gamemode
		
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
; ---------------------------------------------------------------------------
; Level	select codes
; ---------------------------------------------------------------------------
LevSelCode_J:	if Revision=0
		dc.b btnUp,btnDn,btnL,btnR,0,$FF
		else
		dc.b btnUp,btnDn,btnDn,btnDn,btnL,btnR,0,$FF
		endc
		even

LevSelCode_US:	dc.b btnUp,btnDn,btnL,btnR,0,$FF
		even

; ---------------------------------------------------------------------------
; Demo mode
; ---------------------------------------------------------------------------

PlayDemo:
		move.w	#30,(v_countdown).w			; set delay to half a second

.loop_delay:
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bsr.w	DeformLayers
		bsr.w	PaletteCycle
		bsr.w	RunPLC
		move.w	(v_ost_player+ost_x_pos).w,d0		; dummy object x pos
		addq.w	#2,d0					; increment
		move.w	d0,(v_ost_player+ost_x_pos).w		; update
		cmpi.w	#$1C00,d0				; has dummy object reached $1C00?
		blo.s	.chk_start				; if not, branch
		move.b	#id_Sega,(v_gamemode).w			; goto Sega screen
		rts	
; ===========================================================================

.chk_start:
		andi.b	#btnStart,(v_joypad_press_actual).w	; is Start button pressed?
		bne.w	Title_PressedStart			; if yes, branch
		tst.w	(v_countdown).w				; has delay timer hit 0?
		bne.w	.loop_delay				; if not, branch

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
		if Revision=0
		else
			move.l	#5000,(v_score_next_life).w	; extra life is awarded at 50000 points
		endc
		rts	

		include_demo_list				; Includes\Demo Pointers.asm

; ---------------------------------------------------------------------------
; Level	select menu text strings
; ---------------------------------------------------------------------------

lsline:		macro string,type,zone,act
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
		lsline "HIDDEN CREDITS    ",id_LevSel_Gamemode,0,0
		lsline "END SCREEN        ",id_LevSel_Credits,0,0
		lsline "TRY AGAIN SCREEN  ",id_LevSel_Credits,0,0
		lsline "CONTINUE SCREEN   ",id_LevSel_Gamemode,id_Continue,0
	LevSel_Strings_sound:
		lsline "SOUND SELECT   $80",id_LevSel_Level,id_GHZ,0
	LevSel_Strings_end2:
