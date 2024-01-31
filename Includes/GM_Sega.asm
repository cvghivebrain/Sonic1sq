; ---------------------------------------------------------------------------
; Sega screen
; ---------------------------------------------------------------------------

sega_bg_width:	equ $18						; bg dimensions - striped pattern behind logo
sega_bg_height:	equ 8
sega_fg_width:	equ $28						; fg dimensions - white box with logo cutout
sega_fg_height:	equ $1C

countof_stripe:	equ filesize("Palettes\Sega - Stripe.bin")/2	; colours in stripe that moves across logo
countof_sega:	equ $C/2					; colours in Sega logo

GM_Sega:
		play.b	1, jsr, cmd_Stop			; stop music
		bsr.w	PaletteFadeOut				; fade out from previous gamemode
		lea	(vdp_control_port).l,a6
		move.w	#vdp_md_color,(a6)			; use normal colour mode
		move.w	#vdp_fg_nametable+(vram_fg>>10),(a6)	; set foreground nametable address
		move.w	#vdp_bg_nametable+(vram_bg>>13),(a6)	; set background nametable address
		move.w	#vdp_bg_color,(a6)			; set background colour (palette entry 0)
		move.w	#vdp_full_vscroll|vdp_full_hscroll,(a6)	; full-screen horizontal scrolling
		clr.b	(f_water_pal_full).w
		disable_ints
		disable_display
		bsr.w	ClearScreen
		moveq	#id_SPLC_Sega,d0
		jsr	SlowPLC
		jsr	ProcessSlowPLC_All			; load gfx

		lea	($FF0000).l,a1				; RAM buffer
		lea	(KosMap_SegaLogo).l,a0			; Sega logo mappings
		locVRAM	vram_fg+(sizeof_vram_row*0)+(0*2),d0	; foreground, x=0, y=0
		moveq	#sega_fg_width,d1			; width
		moveq	#sega_fg_height,d2			; height
		moveq	#0,d3					; tile setting
		bsr.w	LoadTilemap

		lea	($FF0000).l,a1				; RAM buffer
		lea	(KosMap_SegaLogoBG).l,a0		; Sega logo background mappings
		locVRAM	vram_bg+(sizeof_vram_row*10)+(8*2),d0	; foreground, x=8, y=10
		moveq	#sega_bg_width,d1			; width
		moveq	#sega_bg_height,d2			; height
		moveq	#0,d3					; tile setting
		bsr.w	LoadTilemap

		moveq	#id_Pal_SegaBG,d0
		bsr.w	PalLoad					; load Sega logo palette
		move.w	#0,(v_brightness).w
		move.w	#-((countof_stripe-1)*2),(v_palcycle_num).w ; -$A
		move.w	#0,(v_palcycle_time).w
		move.w	#0,(v_palcycle_buffer+$12).w
		move.w	#0,(v_palcycle_buffer+$10).w
		enable_display

Sega_PaletteLoop:
		move.b	#id_VBlank_Sega,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		bsr.w	PalCycle_Sega				; update palette
		bne.s	Sega_PaletteLoop			; repeat until palette cycle is complete (d0 = 0)

		play.b	1, jsr, cmd_Sega			; play "SEGA" sound
		move.b	#id_VBlank_Sega_SkipLoad,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		move.w	#30,(v_countdown).w			; set timer to 0.5 seconds

Sega_WaitLoop:
		move.b	#id_VBlank_Sega,(v_vblank_routine).w
		bsr.w	WaitForVBlank
		tst.w	(v_countdown).w
		beq.s	.goto_title				; branch if timer hits 0
		andi.b	#btnStart,(v_joypad_press_actual).w	; is Start button pressed?
		beq.s	Sega_WaitLoop				; if not, branch

	.goto_title:
		move.b	#id_Title,(v_gamemode).w		; go to title screen
		rts

; ---------------------------------------------------------------------------
; Palette cycling routine - Sega logo

; output:
;	d0 = 0 when palette routine is complete
; ---------------------------------------------------------------------------

PalCycle_Sega:
PalCycle_Sega_Stripe:
		tst.b	(f_sega_pal_next).w
		bne.s	PalCycle_Sega_Full			; branch if stripe animation is finished
		lea	(v_pal_dry_line2).w,a1			; address for 2nd palette line
		lea	Pal_Sega1(pc),a0			; address of blue gradient palette source
		moveq	#countof_stripe-1,d1			; 6-1
		move.w	(v_palcycle_num).w,d0			; d0 = -$A (initially)

	.loop_findcolour:
		bpl.s	.loop_colours				; branch if d0 = 0
		addq.w	#2,a0					; read next colour from source
		subq.w	#1,d1
		addq.w	#2,d0					; increment d0
		bra.s	.loop_findcolour			; repeat until d0 = 0
; ===========================================================================

.loop_colours:
		move.w	d0,d2					; d0 = position within target palette
		andi.w	#$1E,d2
		bne.s	.no_skip
		addq.w	#2,d0					; skip 1 colour if at the start of a line (1st colour is transparent)

	.no_skip:
		cmpi.w	#sizeof_pal*3,d0
		bhs.s	.end_of_pal				; branch if at the end of the palettes
		move.w	(a0)+,(a1,d0.w)				; copy 1 colour from source to target

	.end_of_pal:
		addq.w	#2,d0
		dbf	d1,.loop_colours

		move.w	(v_palcycle_num).w,d0
		addq.w	#2,d0					; increment counter
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	.no_skip2
		addq.w	#2,d0					; skip 1 colour if at the start of a line

	.no_skip2:
		cmpi.w	#(sizeof_pal*3)+4,d0
		blt.s	.not_at_end				; branch if not at the end
		move.w	#$401,(v_palcycle_time).w		; set timer to 4 and set flag f_sega_pal_next
		moveq	#-(countof_sega*2),d0			; -$C

	.not_at_end:
		move.w	d0,(v_palcycle_num).w
		moveq	#1,d0
		rts
; ===========================================================================

PalCycle_Sega_Full:
		subq.b	#1,(v_palcycle_time).w			; decrement timer
		bpl.s	.wait					; branch if time remains
		move.b	#4,(v_palcycle_time).w
		move.w	(v_palcycle_num).w,d0
		addi.w	#countof_sega*2,d0			; next batch of colours ($C)
		cmpi.w	#countof_sega*2*4,d0			; $30
		blo.s	.update					; branch if animation is incomplete
		moveq	#0,d0					; set flag when animation is complete
		rts
; ===========================================================================

.update:
		move.w	d0,(v_palcycle_num).w			; update counter
		lea	Pal_Sega2(pc),a0
		lea	(a0,d0.w),a0				; jump to source palette
		lea	(v_pal_dry_line1+(2*2)).w,a1		; start on first palette line, 3rd colour
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0)+,(a1)				; write 5 colours
		lea	(v_pal_dry_line2).w,a1
		moveq	#0,d0
		moveq	#((countof_color-1)*3)-1,d1		; colours in 3 lines (without transparent), minus 1 ($2C)

	.loop_fill:
		move.w	d0,d2
		andi.w	#$1E,d2
		bne.s	.no_skip
		addq.w	#2,d0					; skip 1 colour if at the start of a line

	.no_skip:
		move.w	(a0),(a1,d0.w)				; write colour
		addq.w	#2,d0					; next colour
		dbf	d1,.loop_fill				; repeat for lines 2, 3, and 4 (ignoring transparent)

.wait:
		moveq	#1,d0					; set flag for incomplete animation
		rts
