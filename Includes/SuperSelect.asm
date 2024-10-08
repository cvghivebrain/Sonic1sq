; ---------------------------------------------------------------------------
; Level and character select
; ---------------------------------------------------------------------------

SuperSelect:
		moveq	#id_Pal_LevelSel,d0
		bsr.w	PalLoad					; load level select palette
		bsr.w	ClearRAM_HScroll			; clear hscroll buffer (in RAM)
		clr.w	(v_bg_y_pos_vsram).w
		bsr.w	ClearVRAM_Tiles_BG			; clear bg nametable (in VRAM)

		bsr.w	Select_Draw
		
SuperSelect_Loop:
		move.b	#id_VBlank_Title,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		move.w	(v_levelselect_item).w,d0
		cmpi.w	#sizeof_Select_Settings/6,d0
		bcc.s	.no_presses				; branch if selected item has no settings
		mulu.w	#6,d0
		lea	Select_Settings,a0
		lea	(a0,d0.w),a0				; jump to settings for selected item
		move.b	(a0)+,d4				; read flags
		move.b	(v_joypad_press_actual).w,d0
		andi.b	#btnABC+btnStart,d0
		beq.s	.no_presses				; branch if ABC/Start wasn't pressed
		moveq	#0,d1
		move.b	(a0)+,d1				; read action type
		move.w	Select_Index(pc,d1.w),d1
		jsr	Select_Index(pc,d1.w)			; perform action
		bne.s	.exit					; branch if exit flag is set
		
	.no_presses:
		moveq	#countof_selectlines,d0
		moveq	#countof_linespercol,d1
		lea	(v_levelselect_item).w,a1
		bsr.w	NavigateMenu				; read control inputs
		beq.s	SuperSelect_Loop			; branch if no inputs
		bsr.w	Select_Draw				; redraw menu
		bra.s	SuperSelect_Loop
		
	.exit:
		rts
		
Select_Index:	index *,,2
		ptr Select_Level
		ptr Select_Special
		ptr Select_Ending
		ptr Select_Gamemode
		ptr Select_Credits
		
Select_Level:
		move.w	(a0)+,d1
		move.b	d1,(v_zone).w				; set zone
		move.w	(a0)+,d1
		move.b	d1,(v_act).w				; set act
		bsr.w	PlayLevel				; reset lives/rings/etc, set gamemode, fade out music
		moveq	#1,d1					; set flag to exit menu
		rts
		
Select_Special:
		move.w	(a0)+,d1
		move.b	d1,(v_last_ss_levelid).w		; set Special Stage number
		move.b	#id_Special,(v_gamemode).w		; set gamemode to $10 (Special Stage)
		clr.w	(v_zone).w				; clear	level
		move.b	#3,(v_lives).w				; set lives to 3
		moveq	#0,d0
		move.w	d0,(v_rings).w				; clear rings
		move.l	d0,(v_time).w				; clear time
		move.l	d0,(v_score).w				; clear score
		move.l	#5000,(v_score_next_life).w		; extra life is awarded at 50000 points
		moveq	#1,d1					; set flag to exit menu
		rts

Select_Ending:
		move.w	(a0)+,d1
		move.b	d1,(v_zone).w				; set zone
		move.w	(a0)+,d1
		move.b	d1,(v_act).w				; set act
		move.b	#id_Ending,(v_gamemode).w		; set gamemode to $18 (Ending)
		moveq	#1,d1					; set flag to exit menu
		rts

Select_Gamemode:
		move.w	(a0)+,d1
		move.b	d1,(v_gamemode).w			; set gamemode
		move.w	(a0)+,d1
		move.w	d1,(v_emeralds+2).w			; set emeralds
		move.b	#3,(v_continues).w			; give Sonic 3 continues
		moveq	#1,d1					; set flag to exit menu
		rts

Select_Credits:
		move.w	(a0)+,d1
		move.w	d1,(v_credits_num).w			; set credits number
		move.b	#id_Credits,(v_gamemode).w		; set gamemode to credits
		moveq	#1,d1					; set flag to exit menu
		rts
		
; ---------------------------------------------------------------------------
; Draw level select text
; ---------------------------------------------------------------------------

countof_selectlines:	equ 34					; number of lines in Select_Text
countof_linespercol:	equ 19					; lines per column
sizeof_selectcol:	equ 20					; column width (including spacing)

Select_Draw:
		moveq	#1,d0					; x pos
		moveq	#4,d1					; y pos
		moveq	#0,d5
		moveq	#countof_selectlines-1,d6
		lea	(vdp_data_port).l,a1			; data port
		lea	Select_Text(pc),a2			; address of strings
		
	.loop:
		move.w	#tile_pal4+tile_hi,d2
		cmp.w	(v_levelselect_item).w,d5
		bne.s	.no_highlight				; branch if current line shouldn't be highlighted
		move.w	#tile_pal3+tile_hi,d2			; use different palette line
		
	.no_highlight:
		bsr.w	DrawString_BG
		addq.b	#1,d1					; down 1 row
		addq.w	#1,d5					; next line
		move.w	d5,d2
		beq.s	.no_wrap
		divu.w	#countof_linespercol,d2
		swap	d2
		tst.w	d2
		bne.s	.no_wrap				; branch if d5 isn't a multiple of countof_linespercol
		addi.b	#sizeof_selectcol,d0			; next column
		moveq	#4,d1					; return to top
		
	.no_wrap:
		dbf	d6,.loop				; repeat for all lines
		rts
		
Select_Text:
		dc.b "GREEN HILL ZONE  1",0
		dc.b "                 2",0
		dc.b "                 3",0
		dc.b "MARBLE ZONE      1",0
		dc.b "                 2",0
		dc.b "                 3",0
		dc.b "SPRING YARD ZONE 1",0
		dc.b "                 2",0
		dc.b "                 3",0
		dc.b "LABYRINTH ZONE   1",0
		dc.b "                 2",0
		dc.b "                 3",0
		dc.b "STAR LIGHT ZONE  1",0
		dc.b "                 2",0
		dc.b "                 3",0
		dc.b "SCRAP BRAIN ZONE 1",0
		dc.b "                 2",0
		dc.b "                 3",0
		dc.b "FINAL ZONE",0
		dc.b "SPECIAL STAGE    1",0
		dc.b "                 2",0
		dc.b "                 3",0
		dc.b "                 4",0
		dc.b "                 5",0
		dc.b "                 6",0
		dc.b "GOOD ENDING",0
		dc.b "BAD ENDING",0
		dc.b "CREDITS",0
		dc.b "HIDDEN CREDITS",0
		dc.b "END SCREEN",0
		dc.b "TRY AGAIN SCREEN",0
		dc.b "CONTINUE SCREEN",0
		dc.b "SOUND SELECT   @XX",0
		dc.b "CHARACTER XXXXXXXX",0
		even
		
selset:		macro flags,type,zone,act
		dc.b flags,type
		dc.w zone,act
		endm
		
Select_Settings:
		selset 0,id_Select_Level,id_GHZ,0
		selset 0,id_Select_Level,id_GHZ,1
		selset 0,id_Select_Level,id_GHZ,2
		selset 0,id_Select_Level,id_MZ,0
		selset 0,id_Select_Level,id_MZ,1
		selset 0,id_Select_Level,id_MZ,2
		selset 0,id_Select_Level,id_SYZ,0
		selset 0,id_Select_Level,id_SYZ,1
		selset 0,id_Select_Level,id_SYZ,2
		selset 0,id_Select_Level,id_LZ,0
		selset 0,id_Select_Level,id_LZ,1
		selset 0,id_Select_Level,id_LZ,2
		selset 0,id_Select_Level,id_SLZ,0
		selset 0,id_Select_Level,id_SLZ,1
		selset 0,id_Select_Level,id_SLZ,2
		selset 0,id_Select_Level,id_SBZ,0
		selset 0,id_Select_Level,id_SBZ,1
		selset 0,id_Select_Level,id_LZ,3
		selset 0,id_Select_Level,id_SBZ,2
		selset 0,id_Select_Special,0,0
		selset 0,id_Select_Special,1,0
		selset 0,id_Select_Special,2,0
		selset 0,id_Select_Special,3,0
		selset 0,id_Select_Special,4,0
		selset 0,id_Select_Special,5,0
		selset 0,id_Select_Ending,id_EndZ,0
		selset 0,id_Select_Ending,id_EndZ,1
		selset 0,id_Select_Credits,0,0
		selset 0,id_Select_Gamemode,id_HiddenCredits,0
		selset 0,id_Select_Gamemode,id_TryAgain,emerald_all
		selset 0,id_Select_Gamemode,id_TryAgain,0
		selset 0,id_Select_Gamemode,id_Continue,0
		
sizeof_Select_Settings: equ *-Select_Settings
