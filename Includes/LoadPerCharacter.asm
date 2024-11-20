; ---------------------------------------------------------------------------
; Subroutine to load character data

;	uses d0.l, d1.l, d2.w, a1, a2, a3, a4
; ---------------------------------------------------------------------------

LoadPerCharacter:
		move.w	(v_character1).w,d0			; get character number
		mulu.w	#CharacterDefs_size-CharacterDefs,d0	; get offset for character
		lea	CharacterDefs(pc),a4
		adda.w	d0,a4					; jump to relevant character data

		move.l	(a4),(v_ost_player).w			; load player object
		move.l	(a4)+,(v_player1_ptr).w			; save pointer to player object
		cmpi.b	#id_Special,(v_gamemode).w
		bne.s	.not_special				; branch if not on Special Stage
		move.l	(a4),(v_ost_player).w			; load Special Stage player object
	.not_special:
		addq.w	#4,a4

		move.w	(a4)+,d0
		bmi.s	.skip_pal
		bsr.w	PalLoad					; load character palette

	.skip_pal:
		move.w	(a4)+,d0
		jsr	UncPLC					; load life icon graphics

		move.w	(a4)+,(v_haspassed_character).w		; set settings id for "Sonic has passed"
		move.w	(a4)+,(v_haspassed_uplc).w		; set UPLC id for "Sonic has passed"
		move.w	(a4)+,(v_gotthemall_character).w	; set settings id for "Sonic got them all"
		move.w	(a4)+,(v_gotthemall_uplc).w		; set UPLC id for "Sonic got them all"

		moveq	#0,d0
		move.b	(a4)+,(v_player1_width).w		; set width
		move.b	(a4),d0
		move.b	(a4)+,(v_player1_height).w		; set height
		move.b	(a4)+,(v_player1_width_roll).w		; set width (rolling/jumping)
		sub.b	(a4),d0
		move.w	d0,(v_player1_height_diff).w		; set height difference
		move.b	(a4)+,(v_player1_height_roll).w		; set height (rolling/jumping)
		move.b	(a4)+,(v_player1_hitbox_width).w	; set hitbox
		move.b	(a4)+,(v_player1_hitbox_height).w
		move.b	(a4)+,(v_player1_hitbox_width_roll).w
		move.b	(a4)+,(v_player1_hitbox_height_roll).w

		rts
