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
		move.w	#screen_left+64,ost_x_pos(a1)
		move.w	#screen_top+40,ost_y_screen(a1)
		move.l	#v_rings_spriteindex,ost_mappings(a1)	; read mappings from RAM
		move.w	#tile_Art_HUDNums,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	#id_HUD_RingsCount,ost_routine(a1)
		move.w	#2,(v_rings_spriteindex).w		; sprite mappings internal pointer
		move.w	#$8000,(v_rings_sprite1+2).w		; sprite mappings priority high
		move.w	#$8000,(v_rings_sprite2+2).w
		move.w	#$8000,(v_rings_sprite3+2).w
		move.w	#16,(v_rings_sprite1+4).w		; mappings position of low digit
		move.w	#8,(v_rings_sprite2+4).w		; mappings position of middle digit
		move.b	#1,(v_rings_sprite1+1).w		; 1x2 sprite size
		move.b	#1,(v_rings_sprite2+1).w
		move.b	#1,(v_rings_sprite3+1).w
		move.b	#1,(v_hud_rings_update).w		; set flag to update
		
		jsr	FindFreeInert
		move.l	#HUD,ost_id(a1)				; load time object
		move.w	#screen_left+56,ost_x_pos(a1)
		move.w	#screen_top+24,ost_y_screen(a1)
		move.l	#v_time_spriteindex,ost_mappings(a1)	; read mappings from RAM
		move.w	#tile_Art_HUDNums,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	#id_HUD_TimeCount,ost_routine(a1)
		move.w	#2,(v_time_spriteindex).w		; sprite mappings internal pointer
		move.w	#3,(v_time_spritecount).w
		move.w	#$8000,(v_time_sprite1+2).w		; sprite mappings priority high
		move.w	#$8000,(v_time_sprite2+2).w
		move.w	#$8000,(v_time_sprite3+2).w
		move.w	#24,(v_time_sprite1+4).w		; mappings position of low digit
		move.w	#16,(v_time_sprite2+4).w		; mappings position of middle digit
		move.b	#1,(v_time_sprite1+1).w			; 1x2 sprite size
		move.b	#1,(v_time_sprite2+1).w
		move.b	#1,(v_time_sprite3+1).w
		
		jsr	FindFreeInert
		move.l	#HUD,ost_id(a1)				; load score object
		move.w	#screen_left+56,ost_x_pos(a1)
		move.w	#screen_top+8,ost_y_screen(a1)
		move.l	#v_score_spriteindex,ost_mappings(a1)	; read mappings from RAM
		move.w	#tile_Art_HUDNums,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	#id_HUD_ScoreCount,ost_routine(a1)
		move.w	#2,(v_score_spriteindex).w		; sprite mappings internal pointer
		move.w	#$8000,(v_score_sprite1+2).w		; sprite mappings priority high
		move.w	#$8000,(v_score_sprite2+2).w
		move.w	#$8000,(v_score_sprite3+2).w
		move.w	#$8000,(v_score_sprite4+2).w
		move.w	#$8000,(v_score_sprite5+2).w
		move.w	#$8000,(v_score_sprite6+2).w
		move.w	#40,(v_score_sprite1+4).w		; mappings positions
		move.w	#32,(v_score_sprite2+4).w
		move.w	#24,(v_score_sprite3+4).w
		move.w	#16,(v_score_sprite4+4).w
		move.w	#8,(v_score_sprite5+4).w
		move.b	#1,(v_score_sprite1+1).w		; 1x2 sprite size
		move.b	#1,(v_score_sprite2+1).w
		move.b	#1,(v_score_sprite3+1).w
		move.b	#1,(v_score_sprite4+1).w
		move.b	#1,(v_score_sprite5+1).w
		move.b	#1,(v_score_sprite6+1).w

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
		set_dma_src	Art_LivesNums+(sizeof_cell*10),0
	
HUD_RingsCount:	; Routine 8
		tst.b	(v_hud_rings_update).w			; does the rings counter need updating?
		beq.w	HUD_Display				; if not, branch
		clr.b	(v_hud_rings_update).w
		moveq	#0,d0
		move.w	(v_rings).w,d0				; load number of rings
		bsr.w	CountDigits				; d1 = number of digits
		move.w	d1,(v_rings_spritecount).w
		cmpi.b	#3,d1
		bne.s	.skip_triple				; branch if not 3 digits
		divu.w	#100,d0					; get hundreds digit
		add.b	d0,d0
		move.b	d0,(v_rings_sprite3+3).w		; set tile for hundreds digit
		clr.w	d0					; remove hundreds digit
		swap	d0					; get tens/low digits from remainder
		
	.skip_triple:
		bsr.w	HexToDec2
		move.b	(a1)+,(v_rings_sprite2+3).w		; set tile for tens digit
		move.b	(a1),(v_rings_sprite1+3).w		; set tile for low digit
		bra.w	HUD_Display
		
HUD_TimeCount:	; Routine $A
		tst.b	(f_hud_time_update).w
		beq.s	.display				; branch if time counter is flagged to stop
		tst.w	(f_pause).w
		bne.s	.display				; branch if game is paused
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
		bne.s	.display				; branch if sec/min counter hasn't changed
		lsr.w	#8,d0					; move seconds into low byte
		bsr.w	HexToDec2				; jump to frame info for specified second
		move.b	(a1)+,(v_time_sprite2+3).w		; set tile for tens digit
		move.b	(a1),(v_time_sprite1+3).w		; set tile for low digit
		swap	d0					; move minutes into low byte
		add.b	d0,d0
		move.b	d0,(v_time_sprite3+3).w			; set tile for minutes digit
		
	.display:
		bra.w	HUD_Display
		
HUD_TimeOver:
		lea	(v_ost_player).w,a0
		movea.l	a0,a2					; a2 = object killing Sonic (himself in this case)
		bsr.w	KillSonic				; kill Sonic
		move.b	#1,(f_time_over).w			; flag for GAME OVER object to use correct frame
		rts
		
HUD_ScoreCount:	; Routine $C
		tst.b	(f_hud_score_update).w			; does score counter need updating?
		beq.w	HUD_Display				; if not, branch
		clr.b	(f_hud_score_update).w
		move.w	#0,(v_score_spritecount).w		; assume 0 digits
		move.l	(v_score).w,d0				; get score
		beq.w	.exit					; branch if 0
		bsr.w	CountDigits				; d1 = number of digits
		move.w	d1,(v_score_spritecount).w
		
		cmpi.b	#5,d0
		beq.s	.skip_digit6				; branch if 5 digits
		bcs.s	.skip_digit5				; branch if 1-4 digits
		moveq	#-1,d2
	.loop_digit6:
		addq.b	#1,d2					; increment digit counter
		sub.l	#100000,d0				; decrement highest digit
		bcc.s	.loop_digit6				; branch if +ve
		add.l	#100000,d0				; restore to +ve
		move.b	d2,(v_score_sprite6+3).w		; set tile for highest digit
		
	.skip_digit6:
		moveq	#-1,d2
	.loop_digit5:
		addq.b	#1,d2					; increment digit counter
		sub.l	#10000,d0				; decrement 5th digit
		bcc.s	.loop_digit5				; branch if +ve
		add.l	#10000,d0				; restore to +ve
		move.b	d2,(v_score_sprite5+3).w		; set tile for 5th digit
		
	.skip_digit5:
		divu.w	#100,d0					; get digits 3 & 4
		bsr.w	HexToDec2
		move.b	(a1)+,(v_score_sprite4+3).w		; set tile for digit 4
		move.b	(a1),(v_score_sprite3+3).w		; set tile for digit 3
		swap	d0					; get last two digits from remainder
		bsr.w	HexToDec2
		move.b	(a1)+,(v_score_sprite2+3).w		; set tile for digit 2
		move.b	(a1),(v_score_sprite1+3).w		; set tile for digit 1
		bra.w	HUD_Display
		
	.exit:
		rts
		