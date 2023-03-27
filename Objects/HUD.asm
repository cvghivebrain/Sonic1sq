; ---------------------------------------------------------------------------
; Object 21 - SCORE, TIME, RINGS

; spawned by:
;	GM_Level, GM_Ending, HUD
; ---------------------------------------------------------------------------

HUD:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	HUD_Index(pc,d0.w),d1
		jmp	HUD_Index(pc,d1.w)
; ===========================================================================
HUD_Index:	index *,,2
		ptr HUD_Main
		ptr HUD_Flash
		ptr HUD_Display
		ptr HUD_LivesCount
		ptr HUD_RingsCount
		ptr HUD_TimeCount
		ptr HUD_ScoreCount
		ptr HUD_Debug
		
		rsobj HUD
ost_hud_sprites:	rs.b 1					; sprite counter from previous frame
		rsobjend
; ===========================================================================

HUD_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto HUD_Flash next
		move.w	#screen_left+16,ost_x_pos(a0)
		move.w	#screen_top+8,ost_y_screen(a0)
		move.l	#Map_HUD,ost_mappings(a0)
		moveq	#id_UPLC_HUD,d0
		jsr	UncPLC
		move.w	(v_tile_hud).w,ost_tile(a0)
		move.b	#render_abs,ost_render(a0)
		move.b	#0,ost_priority(a0)
		
		jsr	FindFreeInert
		move.l	#HUD,ost_id(a1)				; load life icon object
		move.w	#screen_left+16,ost_x_pos(a1)
		move.w	#screen_top+200,ost_y_screen(a1)
		move.l	#Map_HUD,ost_mappings(a1)
		move.b	#id_frame_hud_lifeicon,ost_frame(a1)
		move.w	#tile_Art_Lives,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	#id_HUD_LivesCount,ost_routine(a1)
		move.b	#1,(f_hud_lives_update).w		; set flag to update
		
		jsr	FindFreeInert
		move.l	#HUD,ost_id(a1)				; load ring number object
		move.b	#id_HUD_RingsCount,ost_routine(a1)
		move.b	#1,(v_hud_rings_update).w		; set flag to update
		
		jsr	FindFreeInert
		move.l	#HUD,ost_id(a1)				; load time object
		move.b	#id_HUD_TimeCount,ost_routine(a1)
		move.b	#1,(f_hud_time_update).w		; set flag to update
		
		jsr	FindFreeInert
		move.l	#HUD,ost_id(a1)				; load score object
		move.b	#id_HUD_ScoreCount,ost_routine(a1)
		
		tst.w	(f_debug_enable).w
		beq.s	HUD_Flash				; branch if debug mode is disabled
		jsr	FindFreeInert
		move.l	#HUD,ost_id(a1)				; load debug object
		move.w	#screen_left+16,ost_x_pos(a1)
		move.w	#screen_top+56,ost_y_screen(a1)
		move.l	#Map_HUD,ost_mappings(a1)
		move.b	#id_frame_hud_debug,ost_frame(a1)
		move.w	(v_tile_hud).w,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	#id_HUD_Debug,ost_routine(a1)
		bsr.w	HUD_CameraX				; display camera x pos
		bsr.w	HUD_CameraY				; display camera y pos
		
		jsr	FindFreeInert
		move.l	#DebugOverlay,ost_id(a1)		; load overlay object

HUD_Flash:	; Routine 2
		moveq	#0,d0
		btst	#3,(v_frame_counter_low).w		; check bit that changes every 8 frames
		bne.s	.display				; branch if set
		
		tst.w	(v_rings).w				; do you have any rings?
		bne.s	.gotrings				; if yes, branch
		addq.w	#id_frame_hud_ringred,d0		; make ring counter flash red
		
	.gotrings:
		cmpi.b	#9,(v_time_min).w			; have 9 minutes elapsed?
		bne.s	.display				; if not, branch
		addq.w	#id_frame_hud_timered,d0		; make time counter flash red (only flashes if you also have no rings)

	.display:
		move.b	d0,ost_frame(a0)
		
HUD_Display:	; Routine 4
		tst.b	(f_hide_hud).w
		bne.s	.dont_display				; branch if HUD is set to not display
		jmp	DisplaySprite
		
	.dont_display:
		rts
; ===========================================================================
		
HUD_LivesCount:	; Routine 6
		tst.b	(f_hud_lives_update).w			; does the lives counter need updating?
		beq.s	HUD_Display				; if not, branch
		clr.b	(f_hud_lives_update).w
		moveq	#0,d0
		move.b	(v_lives).w,d0				; load number of lives
		bsr.w	HexToDec
		move.b	(a1)+,d0				; get tens digit
		tst.b	d0
		bne.s	.two_digits				; branch if tens digit is not 0
		move.b	#10,d0					; tens should be blank if 0
	.two_digits:
		lsl.b	#3,d0					; multiply by 8
		lea	HUD_LivesGfxIndex(pc,d0.w),a2
		set_dma_dest	$FBC0,d1			; VRAM address for tens digit
		set_dma_size	sizeof_cell,d2
		jsr	AddDMA					; load tens digit
		
		move.b	(a1),d0					; get low digit
		lsl.b	#3,d0					; multiply by 8
		lea	HUD_LivesGfxIndex(pc,d0.w),a2
		set_dma_dest	$FBE0,d1			; VRAM address for low digit
		jsr	AddDMA					; load low digit
		
		bra.s	HUD_Display
		
HUD_LivesGfxIndex:
		set_dma_src	Art_LivesNums,0
		set_dma_src	Art_LivesNums+sizeof_cell,0
		set_dma_src	Art_LivesNums+(sizeof_cell*2),0
		set_dma_src	Art_LivesNums+(sizeof_cell*3),0
		set_dma_src	Art_LivesNums+(sizeof_cell*4),0
		set_dma_src	Art_LivesNums+(sizeof_cell*5),0
		set_dma_src	Art_LivesNums+(sizeof_cell*6),0
		set_dma_src	Art_LivesNums+(sizeof_cell*7),0
		set_dma_src	Art_LivesNums+(sizeof_cell*8),0
		set_dma_src	Art_LivesNums+(sizeof_cell*9),0
		set_dma_src	Art_LivesNums+(sizeof_cell*36),0
	
HUD_RingsCount:	; Routine 8
		tst.b	(v_hud_rings_update).w			; does the rings counter need updating?
		beq.w	.exit					; if not, branch
		clr.b	(v_hud_rings_update).w
		moveq	#10,d0
		moveq	#0,d3
		moveq	#10,d4
		move.w	(v_rings).w,d3				; load number of rings
		cmpi.w	#100,d3
		bcs.s	.skip_triple				; branch if not 3 digits
		divu.w	#100,d3					; get hundreds digit
		move.w	d3,d0
		swap	d3					; get tens/low digits from remainder
		moveq	#0,d4
		
	.skip_triple:
		set_dma_dest	$DBC0,d1			; VRAM address for hundreds digit
		bsr.s	HUD_ShowDigit				; load hundreds digit gfx
		move.w	d3,d0
		bsr.w	HexToDec				; convert tens/low digits to decimal
		move.b	(a1)+,d0				; get tens digit
		bne.s	.not_zero				; branch if not 0
		move.b	d4,d0					; blank if 0-9 rings, 0 if 100+ rings
		
	.not_zero:
		set_dma_dest	$DC00,d1			; VRAM address for tens digit
		bsr.s	HUD_ShowDigit				; load tens digit gfx
		move.b	(a1),d0					; get low digit
		set_dma_dest	$DC40,d1			; VRAM address for low digit
		bsr.s	HUD_ShowDigit				; load low digit gfx
		
	.exit:
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to load an 8x16px digit into VRAM

; input:
;	d0.w = digit value (0-9; 10 for blank)
;	d1.l = VRAM address (as DMA instruction)

;	uses d0.w, d2.l, a2
; ---------------------------------------------------------------------------

HUD_ShowDigit:
		lsl.b	#3,d0					; multiply by 8
		lea	HUD_DigitGfxIndex(pc,d0.w),a2
		set_dma_size	sizeof_cell*2,d2		; set size to 2 cells
		jmp	AddDMA					; load digit
		
HUD_DigitGfxIndex:
		set_dma_src	Art_HUDNums,0
		set_dma_src	Art_HUDNums+(sizeof_cell*2),0
		set_dma_src	Art_HUDNums+(sizeof_cell*2*2),0
		set_dma_src	Art_HUDNums+(sizeof_cell*3*2),0
		set_dma_src	Art_HUDNums+(sizeof_cell*4*2),0
		set_dma_src	Art_HUDNums+(sizeof_cell*5*2),0
		set_dma_src	Art_HUDNums+(sizeof_cell*6*2),0
		set_dma_src	Art_HUDNums+(sizeof_cell*7*2),0
		set_dma_src	Art_HUDNums+(sizeof_cell*8*2),0
		set_dma_src	Art_HUDNums+(sizeof_cell*9*2),0
		set_dma_src	Art_HUDNums+(sizeof_cell*10*2),0
		
		
HUD_TimeCount:	; Routine $A
		tst.b	(f_hud_time_update).w
		beq.s	.exit					; branch if time counter is flagged to stop
		tst.w	(f_pause).w
		bne.s	.exit					; branch if game is paused
		move.l	(v_time).w,d0
		addq.b	#1,d0					; increment frame counter
		cmpi.b	#60,d0
		bne.s	.update_time				; branch if frame counter is below 60
		move.b	#0,d0					; reset frame counter
		add.w	#$100,d0				; increment seconds counter
		cmpi.w	#60<<8,d0
		bne.s	.update_time				; branch if seconds counter is below 60
		move.w	#0,d0					; reset seconds counter
		add.l	#$10000,d0				; increment minutes counter
		cmpi.l	#10<<16,d0
		beq.w	HUD_TimeOver				; branch if counter hits 10 minutes
		
	.update_time:
		move.l	d0,(v_time).w				; update time
		tst.b	d0
		bne.s	.exit					; branch if sec/min counter hasn't changed
		lsr.w	#8,d0					; move seconds into low byte
		bsr.w	HexToDec				; convert to decimal
		move.b	(a1)+,d0				; get tens digit
		set_dma_dest	$DD00,d1			; VRAM address for tens digit
		bsr.w	HUD_ShowDigit				; load tens digit gfx
		move.b	(a1),d0					; get low digit
		set_dma_dest	$DD40,d1			; VRAM address for low digit
		bsr.w	HUD_ShowDigit				; load low digit gfx
		swap	d0					; move minutes into low byte
		set_dma_dest	$DC80,d1			; VRAM address for minutes digit
		bsr.w	HUD_ShowDigit				; load minutes digit gfx
		
	.exit:
		rts
; ===========================================================================
		
HUD_TimeOver:
		bsr.w	ObjectKillSonic				; kill Sonic
		move.b	#1,(f_time_over).w			; flag for GAME OVER object to use correct frame
		jmp	DeleteObject				; delete time counter object (HUD is unaffected)
; ===========================================================================
		
HUD_ScoreCount:	; Routine $C
		tst.b	(f_hud_score_update).w			; does score counter need updating?
		beq.w	HUD_Exit				; if not, branch
		clr.b	(f_hud_score_update).w
		move.l	(v_score).w,d0				; get score
		beq.w	HUD_Exit				; branch if 0
		moveq	#6-1,d4					; process 6 digits
		set_dma_dest	$DEC0,d1			; VRAM address for lowest digit
		
; ---------------------------------------------------------------------------
; Subroutine to load gfx for a number into VRAM

; input:
;	d0.l = longword to display
;	d1.l = VRAM address of lowest digit (as DMA instruction)
;	d4.l = max. number of digits (minus 1)

;	uses d0.w, d1.l, d2.l, d3.l, d4.l, a1, a2, a4
; ---------------------------------------------------------------------------

HUD_ShowLong:
		bsr.w	CountDigits				; d3 = number of digits
		lea	(v_digit_buffer+2).w,a4
		
		cmpi.b	#5,d3
		beq.s	.skip_digit6				; branch if 5 digits
		bcs.s	.skip_digit5				; branch if 1-4 digits
		moveq	#-1,d2
	.loop_digit6:
		addq.b	#1,d2					; increment digit counter
		sub.l	#100000,d0				; decrement highest digit
		bcc.s	.loop_digit6				; branch if +ve
		add.l	#100000,d0				; restore to +ve
		move.b	d2,-2(a4)				; set highest digit
		
	.skip_digit6:
		moveq	#-1,d2
	.loop_digit5:
		addq.b	#1,d2					; increment digit counter
		sub.l	#10000,d0				; decrement 5th digit
		bcc.s	.loop_digit5				; branch if +ve
		add.l	#10000,d0				; restore to +ve
		move.b	d2,-1(a4)				; set 5th digit
		
	.skip_digit5:
		divu.w	#100,d0					; get digits 3 & 4
		bsr.w	HexToDec
		move.b	(a1)+,(a4)+				; set digit 4
		move.b	(a1),(a4)+				; set digit 3
		swap	d0					; get last two digits from remainder
		bsr.w	HexToDec
		move.b	(a1)+,(a4)+				; set digit 2
		move.b	(a1),(a4)+				; set digit 1
		
	.loop:
		moveq	#10,d0					; assume digit is blank
		subq.b	#1,d3
		bmi.s	.hide_digit				; branch if digit should be blank
		move.b	-(a4),d0				; get digit
	.hide_digit:
		bsr.w	HUD_ShowDigit				; load digit gfx
		sub.l	#$400000,d1				; go back 2 tiles in VRAM
		dbf	d4,.loop				; repeat for all digits
		
	.exit:
	HUD_Exit:
		rts
; ===========================================================================

HUD_Debug:	; Routine $E
		moveq	#0,d0
		move.b	(v_spritecount).w,d0			; get sprite count
		cmp.b	ost_hud_sprites(a0),d0
		beq.s	.skip_sprite				; branch if counter is unchanged
		move.b	d0,ost_hud_sprites(a0)			; save recent sprite count
		set_dma_dest	$DF80,d1			; VRAM address
		bsr.s	HUD_ShowByte				; update sprite counter
		
	.skip_sprite:
		tst.b	(v_camera_x_diff).w
		beq.s	.skip_x					; branch if camera hasn't moved
		bsr.s	HUD_CameraX
		
	.skip_x:
		tst.b	(v_camera_y_diff).w
		beq.s	.skip_y					; branch if camera hasn't moved
		bsr.s	HUD_CameraY
		
	.skip_y:
		bra.w	HUD_Display
		
HUD_CameraY:
		move.w	(v_camera_y_pos).w,d0
		set_dma_dest	$F380,d1			; VRAM address
		bra.s	HUD_ShowWord
		
HUD_CameraX:
		move.w	(v_camera_x_pos).w,d0
		set_dma_dest	$F300,d1			; VRAM address
		
; ---------------------------------------------------------------------------
; Subroutine to load a word into VRAM

; input:
;	d0.w = word value
;	d1.l = VRAM address (as DMA instruction)

;	uses d0.w, d1.l, d2.l, d3.l, a2
; ---------------------------------------------------------------------------

HUD_ShowWord:
		ror.w	#8,d0					; move high byte into low d0
		bsr.s	HUD_ShowByte				; load high byte
		pushr.w	d0
		popr.b	d0
		;lsr.w	#8,d0					; move low byte back
		
; ---------------------------------------------------------------------------
; Subroutine to load a byte into VRAM

; input:
;	d0.b = byte value
;	d1.l = VRAM address (as DMA instruction)

; output:
;	d1.l = VRAM address after byte (as DMA instruction)

;	uses d2.l, d3.l, a2
; ---------------------------------------------------------------------------

HUD_ShowByte:
		moveq	#0,d3
		move.b	d0,d3
		andi.b	#$F0,d3					; read high nybble of byte
		lsr.b	#1,d3					; multiply by 8
		lea	HUD_ByteGfxIndex(pc,d3.w),a2
		set_dma_size	sizeof_cell,d2			; set size to 1 cell
		jsr	AddDMA					; load high digit
		add.l	#$200000,d1				; next tile in VRAM
		
		move.b	d0,d3
		andi.b	#$F,d3					; read low nybble of byte
		lsl.b	#3,d3					; multiply by 8
		lea	HUD_ByteGfxIndex(pc,d3.w),a2
		jsr	AddDMA					; load low digit
		add.l	#$200000,d1				; next tile in VRAM
		rts
		
HUD_ByteGfxIndex:
		set_dma_src	Art_LivesNums,0
		set_dma_src	Art_LivesNums+sizeof_cell,0
		set_dma_src	Art_LivesNums+(sizeof_cell*2),0
		set_dma_src	Art_LivesNums+(sizeof_cell*3),0
		set_dma_src	Art_LivesNums+(sizeof_cell*4),0
		set_dma_src	Art_LivesNums+(sizeof_cell*5),0
		set_dma_src	Art_LivesNums+(sizeof_cell*6),0
		set_dma_src	Art_LivesNums+(sizeof_cell*7),0
		set_dma_src	Art_LivesNums+(sizeof_cell*8),0
		set_dma_src	Art_LivesNums+(sizeof_cell*9),0
		set_dma_src	Art_LivesNums+(sizeof_cell*10),0
		set_dma_src	Art_LivesNums+(sizeof_cell*11),0
		set_dma_src	Art_LivesNums+(sizeof_cell*12),0
		set_dma_src	Art_LivesNums+(sizeof_cell*13),0
		set_dma_src	Art_LivesNums+(sizeof_cell*14),0
		set_dma_src	Art_LivesNums+(sizeof_cell*15),0
		