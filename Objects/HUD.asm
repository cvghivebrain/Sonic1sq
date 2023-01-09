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
		move.b	#id_HUD_Display,ost_routine(a1)
		
		jsr	FindFreeInert
		move.l	#HUD,ost_id(a1)				; load life number object
		move.w	#screen_left+48,ost_x_pos(a1)
		move.w	#screen_top+208,ost_y_screen(a1)
		move.l	#v_lives_spriteindex,ost_mappings(a1)	; read mappings from RAM
		move.w	#tile_Art_LivesNums,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	#id_HUD_LivesCount,ost_routine(a1)
		move.w	#2,(v_lives_spriteindex).w		; sprite mappings internal pointer
		move.w	#$8000,(v_lives_sprite1+2).w		; sprite mappings priority high
		move.w	#$8000,(v_lives_sprite2+2).w
		move.w	#8,(v_lives_sprite1+4).w		; mappings position of low digit
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
		jmp	DisplaySprite
		
HUD_LivesCount:	; Routine 6
		tst.b	(f_hud_lives_update).w			; does the lives counter need updating?
		beq.s	HUD_Display				; if not, branch
		clr.b	(f_hud_lives_update).w
		move.w	#1,(v_lives_spritecount).w		; assume 1 digit
		moveq	#0,d0
		move.b	(v_lives).w,d0				; load number of lives
		cmpi.b	#9,d0
		bls.s	.singledigit				; branch if 9 or fewer
		add.w	#1,(v_lives_spritecount).w		; use 2 digits
		
	.singledigit:
		bsr.w	HexToDec
		move.b	(a1)+,(v_lives_sprite2+3).w		; set tile for tens digit
		move.b	(a1),(v_lives_sprite1+3).w		; set tile for low digit
		jmp	DisplaySprite
		
HUD_RingsCount:	; Routine 8
		tst.b	(v_hud_rings_update).w			; does the rings counter need updating?
		beq.s	HUD_Display				; if not, branch
		clr.b	(v_hud_rings_update).w
		move.w	#1,(v_rings_spritecount).w		; assume 1 digit
		moveq	#0,d0
		move.w	(v_rings).w,d0				; load number of rings
		cmpi.w	#9,d0
		bls.s	.singledigit				; branch if 9 or fewer
		cmpi.w	#99,d0
		bls.s	.doubledigit				; branch if 99 or fewer
		add.w	#1,(v_rings_spritecount).w
		divu.w	#100,d0					; get hundreds digit
		add.b	d0,d0
		move.b	d0,(v_rings_sprite3+3).w		; set tile for hundreds digit
		clr.w	d0					; remove hundreds digit
		swap	d0					; get tens/low digits from remainder
		
	.doubledigit:
		add.w	#1,(v_rings_spritecount).w
		
	.singledigit:
		bsr.w	HexToDec2
		move.b	(a1)+,(v_rings_sprite2+3).w		; set tile for tens digit
		move.b	(a1),(v_rings_sprite1+3).w		; set tile for low digit
		jmp	DisplaySprite
		
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
		jmp	DisplaySprite
		
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
		
		cmpi.l	#99999,d0
		bls.s	.skip_digit6				; branch if 99999 or less
		add.w	#1,(v_score_spritecount).w
		moveq	#-1,d1
	.loop_digit6:
		addq.b	#1,d1					; increment digit counter
		sub.l	#100000,d0				; decrement highest digit
		bcc.s	.loop_digit6				; branch if +ve
		add.l	#100000,d0				; restore to +ve
		move.b	d1,(v_score_sprite6+3).w		; set tile for highest digit
		
	.skip_digit6:
		cmpi.l	#9999,d0
		bls.s	.skip_digit5				; branch if 9999 or less
		add.w	#1,(v_score_spritecount).w
		moveq	#-1,d1
	.loop_digit5:
		addq.b	#1,d1					; increment digit counter
		sub.l	#10000,d0				; decrement 5th digit
		bcc.s	.loop_digit5				; branch if +ve
		add.l	#10000,d0				; restore to +ve
		move.b	d1,(v_score_sprite5+3).w		; set tile for 5th digit
		
	.skip_digit5:
		add.w	#1,(v_score_spritecount).w
		cmpi.w	#9,d0
		bls.s	.display				; branch if 9 or less
		add.w	#1,(v_score_spritecount).w
		cmpi.w	#99,d0
		bls.s	.display				; branch if 99 or less
		add.w	#1,(v_score_spritecount).w
		cmpi.w	#999,d0
		bls.s	.display				; branch if 999 or less
		add.w	#1,(v_score_spritecount).w
		
	.display:
		divu.w	#100,d0					; get digits 3 & 4
		bsr.w	HexToDec2
		move.b	(a1)+,(v_score_sprite4+3).w		; set tile for digit 4
		move.b	(a1),(v_score_sprite3+3).w		; set tile for digit 3
		swap	d0					; get last two digits from remainder
		bsr.w	HexToDec2
		move.b	(a1)+,(v_score_sprite2+3).w		; set tile for digit 2
		move.b	(a1),(v_score_sprite1+3).w		; set tile for digit 1
		jmp	DisplaySprite
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Subroutine to convert hex byte into decimal (up to 99)

; input:
;	d0.w = hex byte

; output:
;	(a1) = decimal tens digit
;	1(a1) = decimal low digit
; ---------------------------------------------------------------------------

HexToDec:
		lea	HUD_TimeList(pc),a1
		bra.w	HexToDec_Run

HUD_TimeList:	dc.b 0,0,0,1,0,2,0,3,0,4,0,5,0,6,0,7,0,8,0,9
		dc.b 1,0,1,1,1,2,1,3,1,4,1,5,1,6,1,7,1,8,1,9
		dc.b 2,0,2,1,2,2,2,3,2,4,2,5,2,6,2,7,2,8,2,9
		dc.b 3,0,3,1,3,2,3,3,3,4,3,5,3,6,3,7,3,8,3,9
		dc.b 4,0,4,1,4,2,4,3,4,4,4,5,4,6,4,7,4,8,4,9
		dc.b 5,0,5,1,5,2,5,3,5,4,5,5,5,6,5,7,5,8,5,9
		dc.b 6,0,6,1,6,2,6,3,6,4,6,5,6,6,6,7,6,8,6,9
		dc.b 7,0,7,1,7,2,7,3,7,4,7,5,7,6,7,7,7,8,7,9
		dc.b 8,0,8,1,8,2,8,3,8,4,8,5,8,6,8,7,8,8,8,9
		dc.b 9,0,9,1,9,2,9,3,9,4,9,5,9,6,9,7,9,8,9,9
		even

HexToDec2:
		lea	HUD_TimeList2(pc),a1
		
	HexToDec_Run:
		add.b	d0,d0
		lea	(a1,d0.w),a1
		rts

HUD_TimeList2:	dc.b 0*2,0*2,0*2,1*2,0*2,2*2,0*2,3*2,0*2,4*2,0*2,5*2,0*2,6*2,0*2,7*2,0*2,8*2,0*2,9*2
		dc.b 1*2,0*2,1*2,1*2,1*2,2*2,1*2,3*2,1*2,4*2,1*2,5*2,1*2,6*2,1*2,7*2,1*2,8*2,1*2,9*2
		dc.b 2*2,0*2,2*2,1*2,2*2,2*2,2*2,3*2,2*2,4*2,2*2,5*2,2*2,6*2,2*2,7*2,2*2,8*2,2*2,9*2
		dc.b 3*2,0*2,3*2,1*2,3*2,2*2,3*2,3*2,3*2,4*2,3*2,5*2,3*2,6*2,3*2,7*2,3*2,8*2,3*2,9*2
		dc.b 4*2,0*2,4*2,1*2,4*2,2*2,4*2,3*2,4*2,4*2,4*2,5*2,4*2,6*2,4*2,7*2,4*2,8*2,4*2,9*2
		dc.b 5*2,0*2,5*2,1*2,5*2,2*2,5*2,3*2,5*2,4*2,5*2,5*2,5*2,6*2,5*2,7*2,5*2,8*2,5*2,9*2
		dc.b 6*2,0*2,6*2,1*2,6*2,2*2,6*2,3*2,6*2,4*2,6*2,5*2,6*2,6*2,6*2,7*2,6*2,8*2,6*2,9*2
		dc.b 7*2,0*2,7*2,1*2,7*2,2*2,7*2,3*2,7*2,4*2,7*2,5*2,7*2,6*2,7*2,7*2,7*2,8*2,7*2,9*2
		dc.b 8*2,0*2,8*2,1*2,8*2,2*2,8*2,3*2,8*2,4*2,8*2,5*2,8*2,6*2,8*2,7*2,8*2,8*2,8*2,9*2
		dc.b 9*2,0*2,9*2,1*2,9*2,2*2,9*2,3*2,9*2,4*2,9*2,5*2,9*2,6*2,9*2,7*2,9*2,8*2,9*2,9*2
		even
		