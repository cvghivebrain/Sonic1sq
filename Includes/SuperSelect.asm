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
		cmpi.w	#countof_Select_Settings,d0
		bcc.s	.no_presses				; branch if selected item has no settings
		mulu.w	#sizeof_selset,d0
		lea	Select_Settings,a0
		lea	(a0,d0.w),a0				; jump to settings for selected item
		move.b	(v_joypad_press_actual).w,d0
		move.b	#btnABC+btnStart,d2
		move.b	(a0)+,d4				; read flags
		beq.s	.noflag					; branch if 0
		ori.b	#btnL+btnR,d2				; also read left/right buttons
		
	.noflag:
		and.b	d2,d0
		beq.s	.no_presses				; branch if specified buttons weren't pressed
		moveq	#0,d1
		move.b	(a0)+,d1				; read action type
		move.w	Select_Index(pc,d1.w),d1
		jsr	Select_Index(pc,d1.w)			; perform action
		bne.s	.exit					; branch if exit flag is set
		
	.no_presses:
		moveq	#countof_selectlines,d0
		moveq	#countof_linespercol,d1
		lea	(v_levelselect_item).w,a1
		tst.b	d4
		bne.s	.updownonly				; branch if flag is set
		bsr.w	NavigateMenu				; read control inputs
		beq.s	SuperSelect_Loop			; branch if no inputs
		bsr.w	Select_Draw				; redraw menu
		bra.s	SuperSelect_Loop
		
	.exit:
		rts
		
	.updownonly:
		bsr.w	NavigateMenu_NoLR			; read control inputs
		beq.s	SuperSelect_Loop			; branch if no inputs
		bsr.w	Select_Draw				; redraw menu
		bra.s	SuperSelect_Loop
		
; ---------------------------------------------------------------------------
; Actions when ABC/Start is pressed on level select
; ---------------------------------------------------------------------------

Select_Index:	index *,,2
		ptr Select_Level
		ptr Select_Special
		ptr Select_Ending
		ptr Select_Gamemode
		ptr Select_Credits
		ptr Select_Sound
		ptr Select_Character
		
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
		
Select_Sound:
		lea	(v_levelselect_sound).w,a1
		btst	#bitL,d0
		bne.s	.left					; branch if left pressed
		btst	#bitR,d0
		bne.s	.right					; branch if right pressed
		btst	#bitA,d0
		bne.s	.btn_a					; branch if A pressed
		move.w	(a1),d0
		addi.w	#$80,d0
		play_sound d0					; play selected sound
		moveq	#0,d1					; set flag to not exit menu
		rts
		
	.left:
		subq.w	#1,(a1)					; previous sound
		bpl.s	.snd_ok					; branch if valid
		move.w	#$4F,(a1)				; wrap to end
		
	.snd_ok:
		bsr.w	Select_DrawSnd
		moveq	#0,d1					; set flag to not exit menu
		rts
		
	.right:
		addq.w	#1,(a1)					; next sound
		
	.right_chk:
		cmpi.w	#$4F,(a1)
		bls.s	.snd_ok					; branch if sound is valid
		clr.w	(a1)					; wrap to start
		bra.s	.snd_ok
		
	.btn_a:
		addi.w	#$10,(a1)				; skip $10 sounds
		bra.s	.right_chk
		
Select_Character:
		lea	(v_character1).w,a1
		btst	#bitL,d0
		bne.s	.left					; branch if left pressed
		btst	#bitR,d0
		bne.s	.right					; branch if right pressed
		moveq	#0,d1					; set flag to not exit menu
		rts
		
	.left:
		subq.w	#1,(a1)					; previous character
		bpl.s	.char_ok				; branch if valid
		move.w	#2,(a1)					; wrap to end
		
	.char_ok:
		bsr.w	Select_DrawChar
		moveq	#0,d1					; set flag to not exit menu
		rts
		
	.right:
		addq.w	#1,(a1)					; next character
		cmpi.w	#2,(a1)
		bls.s	.char_ok				; branch if character is valid
		clr.w	(a1)					; wrap to start
		bra.s	.char_ok
		
; ---------------------------------------------------------------------------
; Draw level select text
; ---------------------------------------------------------------------------

countof_selectlines:	equ 34					; number of lines in Select_Text
countof_linespercol:	equ 19					; lines per column
sizeof_selectcol:	equ 20					; column width (including spacing)
select_x:		equ 1
select_y:		equ 4

Select_Draw:
		moveq	#select_x,d0				; x pos
		moveq	#select_y,d1				; y pos
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
		bsr.w	Select_DrawSnd				; draw sound test
		bra.w	Select_DrawChar				; draw character name
		
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
Select_TextSnd:
		dc.b "SOUND SELECT   @XX",0
sizeof_Select_TextSnd: equ *-Select_TextSnd-3
Select_TextChar:
		dc.b "CHARACTER XXXXXXXX",0
sizeof_Select_TextChar: equ *-Select_TextChar-9
		even
		
selset:		macro flags,type,zone,act
		dc.b flags,type
		dc.w zone,act
		endm
		
Select_Settings:
		selset 0,id_Select_Level,id_GHZ,0
sizeof_selset:	equ *-Select_Settings
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
		selset 1,id_Select_Sound,0,0
		selset 1,id_Select_Character,0,0
		
sizeof_Select_Settings: equ *-Select_Settings
countof_Select_Settings: equ sizeof_Select_Settings/sizeof_selset

; ---------------------------------------------------------------------------
; Draw sound test number
; ---------------------------------------------------------------------------

soundtest_linenum: equ 33-1
soundtest_x:	equ ((soundtest_linenum/countof_linespercol)*sizeof_selectcol)+select_x+sizeof_Select_TextSnd
soundtest_y:	equ (soundtest_linenum%countof_linespercol)+select_y

Select_DrawSnd:
		moveq	#soundtest_x,d0				; x pos
		moveq	#soundtest_y,d1				; y pos
		lea	(vdp_data_port).l,a1			; data port
		move.w	(v_levelselect_sound).w,d5		; get sound id
		addi.w	#$80,d5
		moveq	#2,d6					; draw 2 digits
		
		move.w	#tile_pal4+tile_hi,d2
		cmpi.w	#soundtest_linenum,(v_levelselect_item).w
		bne.w	DrawHexString_BG			; branch if current line shouldn't be highlighted
		move.w	#tile_pal3+tile_hi,d2			; use different palette line
		bra.w	DrawHexString_BG

; ---------------------------------------------------------------------------
; Draw character name
; ---------------------------------------------------------------------------

charsel_linenum: equ 34-1
charsel_x:	equ ((charsel_linenum/countof_linespercol)*sizeof_selectcol)+select_x+sizeof_Select_TextChar
charsel_y:	equ (charsel_linenum%countof_linespercol)+select_y

Select_DrawChar:
		moveq	#charsel_x,d0				; x pos
		moveq	#charsel_y,d1				; y pos
		lea	(vdp_data_port).l,a1			; data port
		move.w	(v_character1).w,d5			; get character id
		lsl.w	#3,d5					; multiply by 8
		lea	Select_CharStrings(pc,d5.w),a2		; jump to character string
		
		move.w	#tile_pal4+tile_hi,d2
		cmpi.w	#charsel_linenum,(v_levelselect_item).w
		bne.w	DrawString8_BG				; branch if current line shouldn't be highlighted
		move.w	#tile_pal3+tile_hi,d2			; use different palette line
		bra.w	DrawString8_BG

Select_CharStrings:
		dc.b "   SONIC"
		dc.b " KETCHUP"
		dc.b " MUSTARD"
		dc.b "   TAILS"
		dc.b "KNUCKLES"
		even
		