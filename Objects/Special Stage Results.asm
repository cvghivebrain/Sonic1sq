; ---------------------------------------------------------------------------
; Object 7E - special stage results screen

; spawned by:
;	GM_Special, SSResult
; ---------------------------------------------------------------------------

SSResult:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	SSR_Index(pc,d0.w),d1
		jmp	SSR_Index(pc,d1.w)
; ===========================================================================
SSR_Index:	index *,,2
		ptr SSR_Main
		ptr SSR_Move
		ptr SSR_Wait
		ptr SSR_RingBonus
		ptr SSR_Wait
		ptr SSR_Exit
		ptr SSR_Wait
		ptr SSR_Continue
		ptr SSR_Wait
		ptr SSR_Exit
		ptr SSR_ContAni

		rsobj SSResult
ost_ssr_x_stop:		rs.w 1 ; $30				; on screen x position (2 bytes)
ost_ssr_time:		rs.w 1 ; $3E
		rsobjend

		; x pos start, x pos stop, y pos
		; routine number, frame number
SSR_Config:	dc.w $20, $120,	$C4
		dc.b id_SSR_Move, id_frame_ssr_chaos

		dc.w $320, $120, $118
		dc.b id_SSR_Move, id_frame_ssr_score

		dc.w $360, $120, $128
		dc.b id_SSR_Move, id_frame_ssr_ringbonus

		dc.w $1EC, $11C, $C4
		dc.b id_SSR_Move, id_frame_ssr_oval

		dc.w $3A0, $120, $138
		dc.b id_SSR_Move, id_frame_ssr_continue
		
SSR_Settings:	index *
		ptr SSRSet_Special
		ptr SSRSet_Chaos
		ptr SSRSet_Sonic
		ptr SSRSet_Ketchup
		ptr SSRSet_Mustard
		
SSRSet_Special:	autocard "SPECIAL STAGE","",0,0,60,noact|center
SSRSet_Chaos:	autocard "CHAOS EMERALDS","",0,0,60,noact|center
SSRSet_Sonic:	autocard "SONIC GOT THEM ALL","",0,0,60,noact|center
SSRSet_Ketchup:	autocard "KETCHUP","GOT THEM ALL",0,0,60,noact|center
SSRSet_Mustard:	autocard "MUSTARD","GOT THEM ALL",0,0,60,noact|center
; ===========================================================================

SSR_Main:	; Routine 0
		moveq	#id_UPLC_SSResult,d0
		jsr	UncPLC
		moveq	#id_UPLC_SSRSS,d0
		tst.l	(v_emeralds).w
		beq.s	.no_emeralds				; branch if you have no chaos emeralds
		moveq	#id_UPLC_SSRChaos,d0
		cmpi.l	#emerald_all,(v_emeralds).w
		bne.s	.no_emeralds				; branch if you don't have all emeralds
		moveq	#id_UPLC_SSRSonic,d0
		
	.no_emeralds:
		jsr	UncPLC					; load results screen patterns
		
		move.b	#1,(v_haspassed_state).w		; keep title card from moving away
		move.l	#TitleCard,ost_id(a0)			; this object becomes the oval
		moveq	#id_SSRSet_Special,d0
		tst.l	(v_emeralds).w
		beq.s	.no_emeralds2				; branch if you have no chaos emeralds
		moveq	#id_SSRSet_Chaos,d0
		
	.no_emeralds2:
		lea	SSR_Settings,a2
		jsr	Card_Load				; load "SPECIAL STAGE" and oval objects
		jsr	FindFreeInert
		move.l	#HUD,ost_id(a1)				; load HUD object (so that score mappings are generated)
		move.b	#1,(f_hide_hud).w			; hide the HUD
		rts
		
		
		movea.l	a0,a1					; replace current object with 1st from list
		lea	(SSR_Config).l,a2			; position, routine & frame settings
		moveq	#3,d1					; 3 additional items
		cmpi.w	#5,(v_rings).w				; do you have 50 or more rings?
		bcs.s	.loop					; if no, branch
		addq.w	#1,d1					; if yes, add 1	item (continue)
		bra.s	.skip_findost

	.loop:
		;bsr.w	FindFreeInert
		move.l	#SSResult,ost_id(a1)
		
	.skip_findost:
		move.w	(a2)+,ost_x_pos(a1)			; set actual x position
		move.w	(a2)+,ost_ssr_x_stop(a1)		; set stop x position
		move.w	(a2)+,ost_y_screen(a1)			; set y position
		move.b	(a2)+,ost_routine(a1)			; goto SSR_Move next
		move.b	(a2)+,ost_frame(a1)			; set frame number
		move.l	#Map_SSR,ost_mappings(a1)
		move.w	(v_tile_titlecard).w,ost_tile(a1)
		add.w	#tile_hi,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		dbf	d1,.loop				; repeat 3 or 4 times

		moveq	#7,d0
		move.l	(v_emeralds).w,d1
		beq.s	.skip_emeralds				; branch if you have no chaos emeralds
		moveq	#id_frame_ssr_chaos,d0			; use "CHAOS EMERALDS" text
		cmpi.l	#emerald_all,d1				; do you have all chaos	emeralds?
		bne.s	.skip_emeralds				; if not, branch
		moveq	#id_frame_ssr_gotthemall,d0		; use "SONIC GOT THEM ALL" text
		move.w	#$18,ost_x_pos(a0)
		move.w	#$118,ost_ssr_x_stop(a0)		; change position of text

	.skip_emeralds:
		move.b	d0,ost_frame(a0)			; set frame for 1st object

SSR_Move:	; Routine 2
		moveq	#$10,d1					; set horizontal speed (moves right)
		move.w	ost_ssr_x_stop(a0),d0
		cmp.w	ost_x_pos(a0),d0			; has object reached its target position?
		beq.s	.at_target				; if yes, branch
		bge.s	.is_left				; branch if object is left of target position
		neg.w	d1					; move left instead

	.is_left:
		add.w	d1,ost_x_pos(a0)			; update position

	.chk_visible:
		move.w	ost_x_pos(a0),d0
		bmi.s	.exit					; branch if object is at -ve x pos
		cmpi.w	#$200,d0				; is object further right than $200?
		;bcc.s	.exit					; if yes, branch
		;bra.w	DisplaySprite
; ===========================================================================

.exit:
		rts	
; ===========================================================================

.at_target:
		cmpi.b	#id_frame_ssr_ringbonus,ost_frame(a0)	; is object the ring bonus?
		bne.s	.chk_visible				; if not, branch

		addq.b	#2,ost_routine(a0)			; goto SSR_Wait next, and then SSR_RingBonus
		move.w	#180,ost_ssr_time(a0)			; set time delay to 3 seconds
		;bsr.w	FindFreeInert
		move.l	#SSRChaos,ost_id(a1)			; load chaos emerald object

SSR_Wait:	; Routine 4, 8, $C, $10
		subq.w	#1,ost_ssr_time(a0)			; decrement timer
		bne.s	.wait					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto SSR_RingBonus/SSR_Exit/SSR_Continue next

	.wait:
		;bra.w	DisplaySprite
; ===========================================================================

SSR_RingBonus:	; Routine 6
		;bsr.w	DisplaySprite
		move.b	#1,(f_pass_bonus_update).w		; set ring bonus update flag
		tst.w	(v_ring_bonus).w			; is ring bonus	= zero?
		beq.s	.finish_bonus				; if yes, branch
		subi.w	#10,(v_ring_bonus).w			; subtract 10 from ring bonus
		moveq	#10,d0					; add 10 to score
		jsr	(AddPoints).l				; add d0 to score and update counter

		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		andi.b	#3,d0					; read bits 0-1
		bne.s	.exit					; branch if either are set
		play.w	1, jmp, sfx_Switch			; play "blip" sound every 4th frame
; ===========================================================================

.finish_bonus:
		play.w	1, jsr, sfx_Register			; play "ker-ching" sound
		addq.b	#2,ost_routine(a0)			; goto SSR_Wait next, and then SSR_Exit
		move.w	#180,ost_ssr_time(a0)			; set time delay to 3 seconds
		cmpi.w	#5,(v_rings).w				; do you have at least 50 rings?
		bcs.s	.exit					; if not, branch
		move.w	#60,ost_ssr_time(a0)			; set time delay to 1 second
		addq.b	#4,ost_routine(a0)			; goto SSR_Continue next

.exit:
		rts	
; ===========================================================================

SSR_Exit:	; Routine $A, $12
		move.w	#1,(f_restart).w			; restart level
		;bra.w	DisplaySprite
; ===========================================================================

SSR_Continue:	; Routine $E
		;bsr.w	FindFreeInert
		move.l	#SSResult,ost_id(a1)
		move.w	#$120,ost_x_pos(a1)
		move.w	#$138,ost_y_screen(a1)
		move.l	#Map_SSR,ost_mappings(a1)
		move.w	(v_tile_titlecard).w,ost_tile(a1)
		add.w	#tile_hi,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#id_frame_ssr_contsonic1,ost_frame(a1)	; make Sonic sprite appear
		move.b	#id_SSR_ContAni,ost_routine(a1)		; "CONTINUE" object goto SSR_ContAni next
		play.w	1, jsr, sfx_Continue			; play continues jingle
		addq.b	#2,ost_routine(a0)			; goto SSR_Wait next, and then SSR_Exit
		move.w	#360,ost_ssr_time(a0)			; set time delay to 6 seconds
		;bra.w	DisplaySprite
; ===========================================================================

SSR_ContAni:	; Routine $14
		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		andi.b	#$F,d0					; read only bits 0-3
		bne.s	.wait					; branch if any bits are set
		bchg	#0,ost_frame(a0)			; Sonic moves his foot every 16th frame

	.wait:
		;bra.w	DisplaySprite
