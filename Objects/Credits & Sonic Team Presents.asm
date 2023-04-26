; ---------------------------------------------------------------------------
; Object 8A - "SONIC TEAM PRESENTS" and	credits

; spawned by:
;	GM_Title, GM_Credits, EndEggman
; ---------------------------------------------------------------------------

CreditsText:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Cred_Index(pc,d0.w),d1
		jmp	Cred_Index(pc,d1.w)
; ===========================================================================
Cred_Index:	index *,,2
		ptr Cred_Main
		ptr Cred_Display
; ===========================================================================

Cred_Main:	; Routine 0
		moveq	#id_UPLC_Credits,d0
		cmpi.b	#id_TryAgain,(v_gamemode).w
		bne.s	.not_tryagain				; branch if not on Try Again screen
		moveq	#id_UPLC_TryAgain,d0
		
	.not_tryagain:
		jsr	UncPLC
		jsr	ProcessDMA
		addq.b	#2,ost_routine(a0)			; goto Cred_Display next
		move.w	#$120,ost_x_pos(a0)
		move.w	#$F0,ost_y_screen(a0)
		move.l	#Map_Cred,ost_mappings(a0)
		move.w	(v_tile_credits).w,ost_tile(a0)
		move.w	(v_credits_num).w,d0			; load credits index number
		move.b	d0,ost_frame(a0)			; display appropriate sprite
		move.b	#render_abs,ost_render(a0)
		move.b	#0,ost_priority(a0)

		cmpi.b	#id_Title,(v_gamemode).w		; is the mode #4 (title screen)?
		bne.s	Cred_Display				; if not, branch

		move.b	#id_frame_cred_sonicteam,ost_frame(a0)	; display "SONIC TEAM PRESENTS"

Cred_Display:	; Routine 2
		shortcut
		cmpi.b	#id_Title,(v_gamemode).w
		bne.s	.not_title
		tst.w	(v_countdown).w
		bne.s	.delete					; branch if title screen is visible
		
	.not_title:
		jmp	DisplaySprite

	.delete:
		jmp	DeleteObject
		