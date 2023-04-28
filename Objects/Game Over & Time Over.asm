; ---------------------------------------------------------------------------
; Object 39 - "GAME OVER" and "TIME OVER"

; spawned by:
;	SonicPlayer
; ---------------------------------------------------------------------------

GameOverCard:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Over_Index(pc,d0.w),d1
		jmp	Over_Index(pc,d1.w)
; ===========================================================================
Over_Index:	index *,,2
		ptr Over_Main
		ptr Over_Move
		ptr Over_Wait

		rsobj GameOverCard
ost_over_time:	rs.w 1
		rsobjend
; ===========================================================================

Over_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Over_Move next
		move.w	#$50,ost_x_pos(a0)			; set x position
		btst	#0,ost_frame(a0)			; is the object "OVER"?
		beq.s	.not_over				; if not, branch
		move.w	#$1F0,ost_x_pos(a0)			; set x position for "OVER"
		moveq	#id_UPLC_GameOver,d0
		jsr	UncPLC					; load GAME/TIME OVER gfx

	.not_over:
		move.w	#$F0,ost_y_screen(a0)
		move.l	#Map_Over,ost_mappings(a0)
		move.w	#tile_Art_GameOver+tile_hi,ost_tile(a0)
		move.b	#render_abs,ost_render(a0)
		move.b	#0,ost_priority(a0)

Over_Move:	; Routine 2
		moveq	#$10,d1					; set horizontal speed
		cmpi.w	#$120,ost_x_pos(a0)			; has object reached its target position?
		beq.s	.next					; if yes, branch
		bcs.s	.not_over				; branch if object is left of target (GAME/TIME)
		neg.w	d1					; move left instead

	.not_over:
		add.w	d1,ost_x_pos(a0)			; update x position
		jmp	DisplaySprite

.next:
		move.w	#720,ost_over_time(a0)			; set time delay to 12 seconds
		addq.b	#2,ost_routine(a0)			; goto Over_Wait next
		rts	
; ===========================================================================

Over_Wait:	; Routine 4
		shortcut
		move.b	(v_joypad_press_actual).w,d0
		andi.b	#btnABC,d0				; is button A, B or C pressed?
		bne.s	Over_ChgMode				; if yes, branch
		btst	#0,ost_frame(a0)			; is object "OVER"?
		bne.s	Over_Display				; if yes, branch
		tst.w	ost_over_time(a0)			; has time delay reached zero?
		beq.s	Over_ChgMode				; if yes, branch
		subq.w	#1,ost_over_time(a0)			; subtract 1 from time delay
		jmp	DisplaySprite
; ===========================================================================

Over_ChgMode:
		tst.b	(f_time_over).w				; is time over flag set?
		bne.s	Over_ResetLvl				; if yes, branch
		move.b	#id_Continue,(v_gamemode).w		; set mode to $14 (continue screen)
		tst.b	(v_continues).w				; do you have any continues?
		bne.s	Over_Display				; if yes, branch
		move.b	#id_Sega,(v_gamemode).w			; set mode to 0 (Sega screen)
		bra.s	Over_Display
; ===========================================================================

Over_ResetLvl:
		clr.l	(v_time_lampcopy).w
		move.w	#1,(f_restart).w			; restart level

Over_Display:
		jmp	DisplaySprite
