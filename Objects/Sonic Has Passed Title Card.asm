; ---------------------------------------------------------------------------
; Object 3A - "SONIC HAS PASSED" title card

; spawned by:
;	Signpost, HasPassedCard
; ---------------------------------------------------------------------------

HasPassedCard:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Has_Index(pc,d0.w),d1
		jmp	Has_Index(pc,d1.w)
; ===========================================================================
Has_Index:	index *,,2
		ptr Has_Main
		ptr Has_WaitEnter
		ptr Has_Enter
		ptr Has_Display
		ptr Has_Score
		ptr Has_Time
		ptr Has_Rings
		ptr Has_WaitBonus
		ptr Has_Bonus
		ptr Has_Finish
		ptr Has_Boundary

		rsobj HasPassedCard
ost_has_x_stop:	rs.w 1						; on screen x position
ost_has_time:	rs.w 1						; time delay
		rsobjend
		
Has_Settings:	index *
		ptr HasSet_Sonic
		ptr HasSet_Ketchup
		ptr HasSet_Mustard
		
HasSet_Sonic:	autocard "SONIC HAS","PASSED",,60
HasSet_Ketchup:	autocard "KETCHUP HAS","PASSED",,60
HasSet_Mustard:	autocard "MUSTARD HAS","PASSED",,60
; ===========================================================================

Has_Main:	; Routine 0
		move.b	#1,(v_haspassed_state).w
		moveq	#id_UPLC_SonicCard,d0
		add.w	(v_haspassed_character).w,d0
		jsr	UncPLC					; load title card patterns
		move.w	(v_titlecard_act).w,d0
		sub.w	#2,d0
		bcs.s	.keep_act				; branch if act is 0 or 1
		add.w	#id_UPLC_Act2Card,d0
		jsr	UncPLC					; load act 2/3 gfx
		
	.keep_act:
		move.l	#TitleCard,ost_id(a0)			; this object becomes the oval
		lea	Has_Settings,a2
		move.w	(v_haspassed_character).w,d0
		bsr.w	Card_Load				; load "SONIC HAS PASSED" and oval objects
		
		moveq	#3-1,d1
		move.w	#screen_top+100,d2			; y position
		move.w	#60,d3					; time delay for first line
		
	.loop:
		jsr	FindFreeInert
		move.l	#HasPassedCard,ost_id(a1)		; load yellow bonus text object
		move.b	#id_Has_WaitEnter,ost_routine(a1)
		move.l	#Map_Has,ost_mappings(a1)
		move.w	(v_tile_bonus).w,ost_tile(a1)
		add.w	#tile_hi,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	d1,ost_frame(a1)			; use frames 2, 1 and 0
		move.w	#screen_right,ost_x_pos(a1)
		move.w	#screen_left+80,ost_has_x_stop(a1)	; x pos when text stops on screen
		move.w	d2,ost_y_screen(a1)
		add.w	#16,d2					; spacing between lines of text
		move.w	d3,ost_has_time(a1)
		add.w	#2,d3					; 2 frame delay between each line
		pushr.w	a1					; save OST address to stack
		dbf	d1,.loop
		
		jsr	FindFreeInert
		move.l	#HasPassedCard,ost_id(a1)		; load ring bonus object
		move.b	#id_Has_Rings,ost_routine(a1)
		move.l	#v_ringbonus_spriteindex,ost_mappings(a1) ; use mappings in RAM
		move.w	#2,(v_ringbonus_spriteindex).w		; sprite mappings internal pointer
		move.w	#$8000,(v_ringbonus_sprite1+2).w	; sprite mappings priority high
		move.w	#$8000,(v_ringbonus_sprite2+2).w
		move.w	#$8000,(v_ringbonus_sprite3+2).w
		move.w	#$8000,(v_ringbonus_sprite4+2).w
		move.w	#40,(v_ringbonus_sprite1+4).w		; mappings position of low digit
		move.w	#32,(v_ringbonus_sprite2+4).w
		move.w	#24,(v_ringbonus_sprite3+4).w
		move.w	#16,(v_ringbonus_sprite4+4).w
		move.b	#1,(v_ringbonus_sprite1+1).w		; 1x2 sprite size
		move.b	#1,(v_ringbonus_sprite2+1).w
		move.b	#1,(v_ringbonus_sprite3+1).w
		move.b	#1,(v_ringbonus_sprite4+1).w
		move.w	#tile_Art_HUDNums,ost_tile(a1)
		popr.w	ost_parent(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		
		jsr	FindFreeInert
		move.l	#HasPassedCard,ost_id(a1)		; load time bonus object
		move.b	#id_Has_Time,ost_routine(a1)
		move.l	#v_timebonus_spriteindex,ost_mappings(a1) ; use mappings in RAM
		move.w	#2,(v_timebonus_spriteindex).w		; sprite mappings internal pointer
		move.w	#$8000,(v_timebonus_sprite1+2).w	; sprite mappings priority high
		move.w	#$8000,(v_timebonus_sprite2+2).w
		move.w	#$8000,(v_timebonus_sprite3+2).w
		move.w	#$8000,(v_timebonus_sprite4+2).w
		move.w	#40,(v_timebonus_sprite1+4).w		; mappings position of low digit
		move.w	#32,(v_timebonus_sprite2+4).w
		move.w	#24,(v_timebonus_sprite3+4).w
		move.w	#16,(v_timebonus_sprite4+4).w
		move.b	#1,(v_timebonus_sprite1+1).w		; 1x2 sprite size
		move.b	#1,(v_timebonus_sprite2+1).w
		move.b	#1,(v_timebonus_sprite3+1).w
		move.b	#1,(v_timebonus_sprite4+1).w
		move.w	#tile_Art_HUDNums,ost_tile(a1)
		popr.w	ost_parent(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		
		jsr	FindFreeInert
		move.l	#HasPassedCard,ost_id(a1)		; load score object
		move.b	#id_Has_Score,ost_routine(a1)
		move.l	#v_score_spriteindex,ost_mappings(a1)	; use same mappings as score
		move.w	#tile_Art_HUDNums,ost_tile(a1)
		popr.w	ost_parent(a1)				; get parent OST address from stack
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	#1,(f_pass_bonus_update).w		; set flag to update
		
		jsr	FindFreeInert
		move.l	#HasPassedCard,ost_id(a1)		; load bonus helper object
		move.b	#id_Has_WaitBonus,ost_routine(a1)
		move.w	#240,ost_has_time(a1)			; set delay for bonus counting
		rts
		
Has_WaitEnter:	; Routine 2
		subq.w	#1,ost_has_time(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		add.b	#2,ost_routine(a0)			; goto Has_Enter next
		
	.wait:
		rts
		
Has_Enter:	; Routine 4
		move.w	ost_x_pos(a0),d0
		sub.w	#16,d0					; move 16px left
		move.w	ost_has_x_stop(a0),d1
		cmp.w	d0,d1
		bcs.s	.not_at_stop				; branch if not at target x pos
		add.b	#2,ost_routine(a0)			; goto Has_Display next
		move.w	d1,d0					; snap to target
		
	.not_at_stop:
		move.w	d0,ost_x_pos(a0)			; update x pos
		
Has_Display:	; Routine 6
		jmp	DisplaySprite
; ===========================================================================
		
Has_Score:	; Routine 8
		jsr	GetParent
		move.l	ost_x_pos(a1),ost_x_pos(a0)		; match parent x/y pos
		add.w	#104,ost_x_pos(a0)
		bra.s	Has_Display
; ===========================================================================
		
Has_Time:	; Routine $A
		moveq	#0,d0
		move.w	(v_time_bonus).w,d0
		beq.w	Has_Delete				; branch if time bonus is 0
		tst.b	(f_pass_bonus_update).w
		beq.s	Has_Score				; branch if update flag isn't set
		jsr	CountDigits				; d1 = number of digits
		move.w	d1,(v_timebonus_spritecount).w
		divu.w	#100,d0					; get digits 3 & 4
		jsr	HexToDec2
		move.b	(a1)+,(v_timebonus_sprite4+3).w		; set tile for digit 4
		move.b	(a1),(v_timebonus_sprite3+3).w		; set tile for digit 3
		swap	d0					; get last two digits from remainder
		jsr	HexToDec2
		move.b	(a1)+,(v_timebonus_sprite2+3).w		; set tile for digit 2
		move.b	(a1),(v_timebonus_sprite1+3).w		; set tile for digit 1
		bra.s	Has_Score
; ===========================================================================
		
Has_Rings:	; Routine $C
		moveq	#0,d0
		move.w	(v_ring_bonus).w,d0
		beq.s	Has_Delete				; branch if ring bonus is 0
		tst.b	(f_pass_bonus_update).w
		beq.s	Has_Score				; branch if update flag isn't set
		jsr	CountDigits				; d1 = number of digits
		move.w	d1,(v_ringbonus_spritecount).w
		divu.w	#100,d0					; get digits 3 & 4
		jsr	HexToDec2
		move.b	(a1)+,(v_ringbonus_sprite4+3).w		; set tile for digit 4
		move.b	(a1),(v_ringbonus_sprite3+3).w		; set tile for digit 3
		swap	d0					; get last two digits from remainder
		jsr	HexToDec2
		move.b	(a1)+,(v_ringbonus_sprite2+3).w		; set tile for digit 2
		move.b	(a1),(v_ringbonus_sprite1+3).w		; set tile for digit 1
		bra.w	Has_Score
		
Has_Delete:
		jmp	DeleteObject
; ===========================================================================
		
Has_WaitBonus:	; Routine $E
		clr.b	(f_pass_bonus_update).w			; clear time/ring bonus update flag
		subq.w	#1,ost_has_time(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		add.b	#2,ost_routine(a0)			; goto Has_Bonus next
		
	.wait:
		rts
; ===========================================================================
		
Has_Bonus:	; Routine $10
		clr.b	(f_pass_bonus_update).w			; clear time/ring bonus update flag
		moveq	#0,d0
		tst.w	(v_time_bonus).w			; is time bonus	= zero?
		beq.s	.skip_timebonus				; if yes, branch
		addi.w	#10,d0					; add 10 to score
		subi.w	#10,(v_time_bonus).w			; subtract 10 from time bonus

	.skip_timebonus:
		tst.w	(v_ring_bonus).w			; is ring bonus	= zero?
		beq.s	.skip_ringbonus				; if yes, branch
		addi.w	#10,d0					; add 10 to score
		subi.w	#10,(v_ring_bonus).w			; subtract 10 from ring bonus

	.skip_ringbonus:
		tst.w	d0					; is there any bonus?
		bne.s	.add_bonus				; if yes, branch
		play.w	1, jsr, sfx_Register			; play "ker-ching" sound
		add.b	#2,ost_routine(a0)			; goto Has_Finish next
		move.w	#180,ost_has_time(a0)			; set time delay to 3 seconds
		rts
		
		addq.b	#2,ost_routine(a0)			; goto Has_Wait next, and then Has_NextLevel
		cmpi.w	#id_SBZ_act2,(v_zone).w			; is current level SBZ2?
		bne.s	.not_sbz2				; if not, branch
		addq.b	#4,ost_routine(a0)			; goto Has_Wait next, and then Has_MoveBack
		move.b	#2,(v_haspassed_state).w

	.not_sbz2:
		
.exit:
		rts	
; ===========================================================================

.add_bonus:
		move.b	#1,(f_pass_bonus_update).w		; set flag to update
		jsr	(AddPoints).l				; add d0 to score and update counter
		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		andi.b	#3,d0					; read bits 0-1
		bne.s	.exit					; branch if either are set
		play.w	1, jmp, sfx_Switch			; play "blip" sound every 4th frame
; ===========================================================================

Has_Finish:	; Routine $12
		subq.w	#1,ost_has_time(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		cmpi.w	#id_SBZ_act2,(v_zone).w
		beq.s	.sbz2					; branch if on SBZ2
		move.w	(v_zone_next).w,d0
		move.w	d0,(v_zone).w				; set level number
		clr.b	(v_last_lamppost).w			; clear	lamppost counter
		tst.b	(f_giantring_collected).w		; has Sonic jumped into	a giant	ring?
		beq.s	.restart				; if not, branch
		move.b	#id_Special,(v_gamemode).w		; set game mode to Special Stage ($10)

	.restart:
		move.w	#1,(f_restart).w			; restart level
		
	.wait:
		rts
		
	.sbz2:
		clr.b	(v_haspassed_state).w			; flag text objects to move off screen
		addq.b	#2,ost_routine(a0)			; goto Has_Boundary next
		clr.b	(f_lock_controls).w			; unlock controls
		play.w	0, jmp, mus_FZ				; play FZ music
; ===========================================================================

Has_Boundary:	; Routine $14
		addq.w	#2,(v_boundary_right).w			; extend right level boundary 2px
		cmpi.w	#$2100,(v_boundary_right).w
		beq.w	Has_Delete				; if boundary reaches $2100, delete object
		rts
