; ---------------------------------------------------------------------------
; Vertical interrupt
; ---------------------------------------------------------------------------

VBlank:
		pushr	d0-a6					; save all registers to stack
		tst.b	(v_vblank_routine).w			; is routine number 0?
		beq.s	VBlank_Lag				; if yes, branch
		lea	(vdp_control_port).l,a6
		move.l	#$40000010+(0<<16),(a6)			; set write destination to VSRAM address 0
		move.l	(v_fg_y_pos_vsram).w,-4(a6)		; send screen y-axis pos. to VSRAM
		btst	#6,(v_console_region).w			; is Mega Drive PAL?
		beq.s	.notPAL					; if not, branch

		move.w	#$700,d0
	.waitPAL:
		dbf	d0,.waitPAL				; wait here in a loop doing nothing for a while...

	.notPAL:
		moveq	#0,d0
		move.b	(v_vblank_routine).w,d0			; get routine number
		move.b	#id_VBlank_Lag,(v_vblank_routine).w	; reset to 0
		move.b	#1,(f_hblank_pal_change).w		; set flag to let HBlank know a frame has finished
		move.w	VBlank_Index(pc,d0.w),d0
		jsr	VBlank_Index(pc,d0.w)			; jsr to relevant VBlank routine

VBlank_Music:
		jsr	(UpdateSound).l

VBlank_Exit:
		addq.l	#1,(v_vblank_counter).w			; increment frame counter
		popr	d0-a6					; restore all registers from stack
		rte						; end of VBlank
; ===========================================================================
VBlank_Index:	index *,,2
		ptr VBlank_Lag
		ptr VBlank_Sega
		ptr VBlank_Title
		ptr VBlank_Level
		ptr VBlank_Special
		ptr VBlank_TitleCard
		ptr VBlank_Pause
		ptr VBlank_PauseDebug
		ptr VBlank_Fade
		ptr VBlank_Sega_SkipLoad
		ptr VBlank_Continue
		ptr VBlank_Ending
; ===========================================================================

; runs when a frame ends before WaitForVBlank triggers (i.e. the game is lagging)
VBlank_Lag:
		cmpi.b	#$80+id_Level,(v_gamemode).w		; is game on level init sequence?
		beq.s	.islevel				; if yes, branch
		cmpi.b	#id_Level,(v_gamemode).w		; is game on a level proper?
		bne.w	VBlank_Music				; if not, branch

	.islevel:
		tst.b	(f_water_enable).w			; is water enabled?
		beq.w	VBlank_Music				; if not, branch

		move.w	(vdp_control_port).l,d0
		btst	#6,(v_console_region).w			; is Mega Drive PAL?
		beq.s	.notPAL					; if not, branch

		move.w	#$700,d0
	.waitPAL:
		dbf	d0,.waitPAL

	.notPAL:
		move.b	#1,(f_hblank_pal_change).w		; set flag to let HBlank know a frame has finished
		stopZ80
		waitZ80
		bsr.w	UpdatePalette
		move.w	(v_vdp_hint_counter).w,(a6)		; set water palette position by sending VDP register $8Axx to control port (vdp_control_port)
		startZ80
		bra.w	VBlank_Music
; ===========================================================================

; GM_Sega> Sega_WaitPal, Sega_WaitEnd
VBlank_Sega:
		bsr.w	ReadPad_Palette_Sprites_HScroll		; read joypad, DMA palettes, sprites and hscroll

; GM_Sega> Sega_WaitPal (once)
VBlank_Sega_SkipLoad:
		tst.w	(v_countdown).w
		beq.w	.end
		subq.w	#1,(v_countdown).w			; decrement timer

	.end:
		rts
; ===========================================================================

; GM_Title> Tit_MainLoop, LevelSelect, GotoDemo; GM_Credits> Cred_WaitLoop, TryAg_MainLoop
VBlank_Title:
		bsr.w	ReadPad_Palette_Sprites_HScroll		; read joypad, DMA palettes, sprites and hscroll
		bsr.w	DrawTilesWhenMoving_BGOnly		; update background
		jsr	(ProcessDMA).w
		tst.w	(v_countdown).w
		beq.w	.end
		subq.w	#1,(v_countdown).w			; decrement timer

	.end:
		rts
; ===========================================================================

; PauseGame> Pause_Loop
VBlank_Pause:
		cmpi.b	#id_Special,(v_gamemode).w		; is game on special stage?
		beq.w	VBlank_Special				; if yes, branch

; GM_Level> Level_MainLoop, Level_FDLoop, Level_DelayLoop
VBlank_Level:
		stopZ80
		waitZ80
		jsr	(ReadJoypads).w
		bsr.w	UpdatePalette
		move.w	(v_vdp_hint_counter).w,(a6)		; set water palette position by sending VDP register $8Axx to control port (vdp_control_port)

		dma	v_hscroll_buffer,sizeof_vram_hscroll,vram_hscroll
		dma	v_sprite_buffer,sizeof_vram_sprites,vram_sprites
		jsr	(ProcessDMA).w
		startZ80
		movem.l	(v_camera_x_pos).w,d0-d7		; copy all camera & bg x/y positions to d0-d7
		movem.l	d0-d7,(v_camera_x_pos_copy).w		; create duplicates in RAM
		movem.l	(v_fg_redraw_direction).w,d0-d1		; copy all fg/bg redraw direction flags to d0-d1
		movem.l	d0-d1,(v_fg_redraw_direction_copy).w	; create duplicates in RAM
		cmpi.b	#96,(v_vdp_hint_line).w			; is HBlank set to run on line 96 or below? (42% of the way down the screen)
		bhs.s	DrawTiles_LevelGfx_HUD_PLC		; if yes, branch
		move.b	#1,(f_hblank_run_snd).w			; set flag to run sound driver on HBlank
		addq.l	#4,sp					; don't play sound from VBlank
		bra.w	VBlank_Exit

; ---------------------------------------------------------------------------
; Subroutine to	update fg/bg, run tile animations
; ---------------------------------------------------------------------------

DrawTiles_LevelGfx_HUD_PLC:
		bsr.w	DrawTilesWhenMoving			; display new tiles if camera has moved
		bsr.w	AnimateLevelGfx				; update animated level graphics
		tst.w	(v_countdown).w
		beq.w	.end
		subq.w	#1,(v_countdown).w			; decrement timer

	.end:
		rts

; ===========================================================================

; GM_Special> SS_MainLoop
VBlank_Special:
		stopZ80
		waitZ80
		jsr	(ReadJoypads).w
		jsr	(PalCycle_SS).w				; update cycling palette
		bsr.w	UpdatePalette
		dma	v_sprite_buffer,sizeof_vram_sprites,vram_sprites
		dma	v_hscroll_buffer,sizeof_vram_hscroll,vram_hscroll
		jsr	(ProcessDMA).w
		startZ80
		tst.w	(v_countdown).w
		beq.w	.end
		subq.w	#1,(v_countdown).w			; decrement timer

	.end:
		rts	
; ===========================================================================

; GM_Level> Level_TtlCardLoop; GM_Special> SS_NormalExit
; GM_Ending> End_LoadSonic (once), End_MainLoop
VBlank_TitleCard:
VBlank_Ending:
		stopZ80
		waitZ80
		jsr	(ReadJoypads).w
		bsr.w	UpdatePalette
		move.w	(v_vdp_hint_counter).w,(a6)		; set water palette position by sending VDP register $8Axx to control port (vdp_control_port)
		dma	v_hscroll_buffer,sizeof_vram_hscroll,vram_hscroll
		dma	v_sprite_buffer,sizeof_vram_sprites,vram_sprites
		jsr	(ProcessDMA).w
		startZ80
		movem.l	(v_camera_x_pos).w,d0-d7		; copy all camera & bg x/y positions to d0-d7
		movem.l	d0-d7,(v_camera_x_pos_copy).w		; create duplicates in RAM
		movem.l	(v_fg_redraw_direction).w,d0-d1		; copy all fg/bg redraw direction flags to d0-d1
		movem.l	d0-d1,(v_fg_redraw_direction_copy).w	; create duplicates in RAM
		bsr.w	DrawTilesWhenMoving			; display new tiles if camera has moved
		bsr.w	AnimateLevelGfx				; update animated level graphics
		rts
; ===========================================================================

; PaletteFadeIn, PaletteWhiteOut, PaletteFadeOut
VBlank_Fade:
		bsr.w	ReadPad_Palette_Sprites_HScroll		; read joypad, DMA palettes, sprites and hscroll
		move.w	(v_vdp_hint_counter).w,(a6)		; set water palette position by sending VDP register $8Axx to control port (vdp_control_port)
; ===========================================================================

; GM_Special> SS_FinLoop; GM_Continue> Cont_MainLoop
VBlank_Continue:
		stopZ80
		waitZ80
		jsr	(ReadJoypads).w
		bsr.w	UpdatePalette
		dma	v_sprite_buffer,sizeof_vram_sprites,vram_sprites
		dma	v_hscroll_buffer,sizeof_vram_hscroll,vram_hscroll
		jsr	(ProcessDMA).w
		startZ80
		tst.w	(v_countdown).w
		beq.w	.end
		subq.w	#1,(v_countdown).w			; decrement timer

	.end:
		rts
; ===========================================================================

; Pause_Debug
VBlank_PauseDebug:
		stopZ80
		waitZ80
		jsr	(ReadJoypads).w
		bsr.w	UpdatePalette
		dma	v_sprite_buffer,sizeof_vram_sprites,vram_sprites
		jsr	(ProcessDMA).w
		startZ80
		rts

; ---------------------------------------------------------------------------
; Subroutine to read joypad and DMA palettes, sprite table and hscroll table
; ---------------------------------------------------------------------------

ReadPad_Palette_Sprites_HScroll:
		stopZ80
		waitZ80
		jsr	(ReadJoypads).w
		bsr.s	UpdatePalette
		dma	v_sprite_buffer,sizeof_vram_sprites,vram_sprites
		dma	v_hscroll_buffer,sizeof_vram_hscroll,vram_hscroll
		startZ80
		rts

; ---------------------------------------------------------------------------
; Subroutine to copy palette to CRAM
; ---------------------------------------------------------------------------

UpdatePalette:
		tst.w	(v_brightness).w
		bne.s	.use_brightness				; branch if brightness isn't default (0)
		tst.b	(f_water_pal_full).w
		bne.s	.allwater				; branch if water is covering the whole screen
		dma	v_pal_dry,sizeof_pal_all,cram		; copy normal palette to CRAM (water palette will be copied by HBlank later)
		rts

	.allwater:
		dma	v_pal_water,sizeof_pal_all,cram		; copy water palette to CRAM
		rts
		
	.use_brightness:
		tst.b	(f_water_pal_full).w
		bne.s	.allwater2				; branch if water is covering the whole screen
		dma	v_pal_dry_final,sizeof_pal_all,cram	; copy normal palette to CRAM (water palette will be copied by HBlank later)
		rts

	.allwater2:
		dma	v_pal_water_final,sizeof_pal_all,cram	; copy water palette to CRAM
		rts

; ---------------------------------------------------------------------------
; Horizontal interrupt
; ---------------------------------------------------------------------------

HBlank:
		disable_ints
		tst.b	(f_hblank_pal_change).w			; is palette set to change during HBlank?
		beq.s	.nochg					; if not, branch
		clr.b	(f_hblank_pal_change).w
		pushr	a0-a1					; save a0-a1 to stack
		lea	(vdp_data_port).l,a1
		lea	(v_pal_water).w,a0			; get palette from RAM
		tst.b	(v_brightness).w
		beq.s	.default_brightness			; branch if brightness is default (0)
		lea	(v_pal_water_final).w,a0
		
	.default_brightness:
		move.l	#$C0000000,4(a1)			; set VDP to CRAM write
		rept sizeof_pal_all/4
		move.l	(a0)+,(a1)				; copy palette to CRAM
		endr
		move.w	#vdp_hint_counter+223,4(a1)		; reset HBlank register
		popr	a0-a1					; restore a0-a1 from stack
		tst.b	(f_hblank_run_snd).w			; is flag set to update sound & some graphics during HBlank?
		bne.s	.update_hblank				; if yes, branch

	.nochg:
		rte						; end of HBlank
; ===========================================================================

; The following only runs during a level and HBlank is set to run on line 96 or below
.update_hblank:
		clr.b	(f_hblank_run_snd).w
		pushr	d0-a6					; save registers to stack
		bsr.w	DrawTiles_LevelGfx_HUD_PLC		; display new tiles, update animated gfx, update HUD, decompress 3 cells of Nemesis gfx
		jsr	(UpdateSound).l				; update audio
		popr	d0-a6					; restore registers from stack
		rte						; end of HBlank
