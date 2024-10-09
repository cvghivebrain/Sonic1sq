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
		moveq	#countof_selectlines,d0
		moveq	#countof_linespercol,d1
		lea	(v_levelselect_item).w,a1
		bsr.w	NavigateMenu				; read control inputs
		beq.s	SuperSelect_Loop			; branch if no inputs
		bsr.w	Select_Draw				; redraw menu
		bra.s	SuperSelect_Loop
		
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
		dc.b "SOUND SELECT   [XX",0
		dc.b "CHARACTER XXXXXXXX",0
		even
		