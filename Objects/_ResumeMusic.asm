; ---------------------------------------------------------------------------
; Subroutine to play music for LZ/SBZ3 after a countdown

; output:
;	d0 = track number
; ---------------------------------------------------------------------------

ResumeMusic:
		cmpi.w	#air_alert,(v_air).w			; more than 12 seconds of air left?
		bhi.s	.over12					; if yes, branch
		move.b	(v_bgm).w,d0
		tst.b	(v_invincibility).w			; is Sonic invincible?
		beq.s	.notinvinc				; if not, branch
		move.w	#mus_Invincible,d0

	.notinvinc:
		tst.b	(f_boss_boundary).w			; is Sonic at a boss?
		beq.s	.playselected				; if not, branch
		move.w	#mus_Boss,d0

	.playselected:
		jsr	(PlaySound0).l

	.over12:
		move.w	#air_full,(v_air).w			; reset air to 30 seconds
		rts
