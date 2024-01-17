; ---------------------------------------------------------------------------
; Object 89 - "SONIC THE HEDGEHOG" text	on the ending sequence

; spawned by:
;	EndSonic
; ---------------------------------------------------------------------------

EndSTH:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	ESth_Index(pc,d0.w),d1
		jsr	ESth_Index(pc,d1.w)
		jmp	(DisplaySprite).l
; ===========================================================================
ESth_Index:	index *,,2
		ptr ESth_Main
		ptr ESth_Move
		ptr ESth_GotoCredits

		rsobj EndStH
ost_esth_wait_time:	rs.w 1					; time until exit
		rsobjend
; ===========================================================================

ESth_Main:	; Routine 0
		moveq	#id_UPLC_EndStH,d0
		jsr	UncPLC
		addq.b	#2,ost_routine(a0)			; goto ESth_Move next
		move.w	#-$20,ost_x_pos(a0)			; object starts outside the level boundary
		move.w	#$D8,ost_y_screen(a0)
		move.l	#Map_ESTH,ost_mappings(a0)
		move.w	#tile_Art_EndStH,ost_tile(a0)
		move.b	#render_abs,ost_render(a0)
		move.b	#priority_0,ost_priority(a0)

ESth_Move:	; Routine 2
		cmpi.w	#$C0,ost_x_pos(a0)			; has object reached $C0?
		beq.s	.at_target				; if yes, branch
		addi.w	#$10,ost_x_pos(a0)			; move object to the right
		rts

.at_target:
		addq.b	#2,ost_routine(a0)			; goto ESth_GotoCredits next
		move.w	#300,ost_esth_wait_time(a0)		; set duration for delay (5 seconds)

ESth_GotoCredits:
		; Routine 4
		subq.w	#1,ost_esth_wait_time(a0)		; subtract 1 from duration
		bpl.s	.wait					; branch if time remains
		move.b	#id_Credits,(v_gamemode).w		; exit to credits

	.wait:
		rts
