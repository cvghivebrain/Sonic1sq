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
		moveq	#id_UPLC_PauseDebug,d0
		jsr	UncPLC					; load debug text gfx on top of HUD gfx
		move.w	#cYellow,(v_pal_dry_line2+12).w		; replace white with yellow in palette line 2
		
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
		moveq	#3,d0					; number of items in menu
		moveq	#3,d1					; number of items per column
		lea	(v_debugmenu_item).w,a1
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
		bra.w	Pause_Loop				; return to regular pause
		
; ---------------------------------------------------------------------------
; Draw main menu
; ---------------------------------------------------------------------------

Pause_Debug_DrawMain:
		moveq	#1,d0					; x pos
		moveq	#6,d1					; y pos
		moveq	#0,d5
		bsr.s	Pause_Debug_Highlight
		lea	(vdp_data_port).l,a1			; data port
		lea	Str_Main1(pc),a2			; address of string
		bsr.w	DrawString
		addq.b	#2,d1
		bsr.s	Pause_Debug_Highlight
		lea	Str_Main2(pc),a2
		bsr.w	DrawString
		addq.b	#2,d1
		bsr.s	Pause_Debug_Highlight
		lea	Str_Main3(pc),a2
		bsr.w	DrawString
		
Pause_Debug_Highlight:
		moveq	#0,d2
		cmp.w	(v_debugmenu_item).w,d5
		bne.s	.no_highlight				; branch if current line shouldn't be highlighted
		move.w	#tile_pal2,d2				; use palette line 2
		
	.no_highlight:
		addq.w	#1,d5					; next line
		rts

Str_DebugMenu:	dc.b "DEBUG MENU",0
Str_DebugBtns:	dc.b "MODE@ BACK  C@ SELECT",0
Str_Main1:	dc.b "OBJECT VIEWER",0
Str_Main2:	dc.b "VRAM VIEWER",0
Str_Main3:	dc.b "SOMETHING ELSE",0
		even

; ---------------------------------------------------------------------------
; Draw string on screen

; input:
;	d0.w = x pos (1 = 8px)
;	d1.w = y pos
;	d2.w = x/y flip or palette setting
;	a1 = vdp_data_port
;	a2 = address of string, terminated by 0

;	uses d2.b, d3.l, d4.w, a2
; ---------------------------------------------------------------------------

DrawString:
		move.l	#(vram_fg&$3FFF)+((vram_fg&$C000)<<2)+$4000,d3
		add.w	d0,d3
		add.w	d0,d3
		move.w	d1,d4
		mulu.w	#sizeof_vram_row,d4
		add.w	d4,d3					; d3 = address within fg table
		swap	d3					; create VRAM write instruction for VDP
		move.l	d3,4(a1)				; send to vdp_control_port
		
	.loop:
		move.b	(a2)+,d2				; get char
		beq.s	.exit					; branch if 0
		cmpi.b	#$20,d2
		beq.s	.space					; branch if it's a space
		move.w	(v_tile_hud).w,d4			; tile address for 0-Z gfx
		subi.w	#$30,d4					; adjust for ASCII starting at 0
		add.w	d2,d4					; create final tile
		move.w	d4,(a1)					; send to vdp_data_port
		bra.s	.loop					; repeat until 0 is reached
		
	.exit:
		rts
		
	.space:
		move.w	#0,(a1)					; write blank tile
		bra.s	.loop
		