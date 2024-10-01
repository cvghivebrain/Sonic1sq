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
		ptr SSR_WaitBonus
		ptr SSR_Bonus
		ptr SSR_Finish
		ptr SSR_Continue
		ptr SSR_ContAni

		rsobj SSResult
ost_ssr_time:	rs.w 1
		rsobjend

SSR_Settings:	index *
		ptr SSRSet_Special
		ptr SSRSet_Chaos
		ptr SSRSet_Sonic
		ptr SSRSet_Ketchup
		ptr SSRSet_Mustard
		
SSRSet_Special:	autocard "SPECIAL STAGE","",id_frame_card_specialstage,0,52,noact|center
SSRSet_Chaos:	autocard "CHAOS EMERALDS","",id_frame_card_chaosemeralds,0,52,noact|center
SSRSet_Sonic:	autocard "SONIC GOT THEM ALL","",id_frame_card_sonicgot,0,52,noact|center
SSRSet_Ketchup:	autocard "KETCHUP","GOT THEM ALL",id_frame_card_ketchupgot,id_frame_card_gotthemall,40,noact|center
SSRSet_Mustard:	autocard "MUSTARD","GOT THEM ALL",id_frame_card_mustardgot,id_frame_card_gotthemall,40,noact|center
; ===========================================================================

SSR_Main:	; Routine 0
		moveq	#id_UPLC_SSResult,d0
		jsr	UncPLC					; load basic SSR gfx
		
		move.l	(v_emeralds).w,d0
		beq.s	.no_emeralds				; branch if you have no chaos emeralds
		cmpi.l	#emerald_all,d0
		beq.s	.all_emeralds				; branch if you have them all
		
		moveq	#id_UPLC_SSRChaos,d0
		jsr	UncPLC					; load "Chaos Emeralds" gfx
		moveq	#id_SSRSet_Chaos,d0
		bra.s	.load_card
		
	.no_emeralds:
		moveq	#id_UPLC_SSRSS,d0
		jsr	UncPLC					; load "Special Stage" gfx
		moveq	#id_SSRSet_Special,d0
		bra.s	.load_card
		
	.all_emeralds:
		move.w	(v_gotthemall_uplc).w,d0
		jsr	UncPLC					; load "Sonic Got Them All" gfx
		move.w	(v_gotthemall_character).w,d0
		
	.load_card:
		lea	SSR_Settings,a2
		move.b	#1,(v_haspassed_state).w		; keep title card from moving away
		move.l	#TitleCard,ost_id(a0)			; this object becomes the oval
		jsr	Card_Load				; load "SPECIAL STAGE" and oval objects
		jsr	FindFreeInert
		move.l	#HUD,ost_id(a1)				; load HUD object (so that score gfx are loaded)
		move.b	#1,(f_hide_hud).w			; hide the HUD
		
		moveq	#2-1,d1
		move.w	#screen_top+150,d2			; y position
		move.w	#60,d3					; time delay for first line
		
	.loop:
		jsr	FindFreeInert
		move.l	#HasPassedCard,ost_id(a1)		; load bonus text object
		move.b	#id_Has_WaitEnter,ost_routine(a1)
		move.l	#Map_Has,ost_mappings(a1)
		move.w	(v_tile_bonus).w,ost_tile(a1)
		addi.w	#tile_hi,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.w	#priority_0,ost_priority(a1)
		move.b	d1,ost_frame(a1)
		beq.s	.frame_0
		move.b	#2,ost_frame(a1)			; use frames 2 and 0
	.frame_0:
		move.w	#screen_right,ost_x_pos(a1)
		move.w	#screen_left+80,ost_has_x_stop(a1)	; x pos when text stops on screen
		move.w	d2,ost_y_screen(a1)
		addi.w	#16,d2					; spacing between lines of text
		move.w	d3,ost_has_time(a1)
		addq.w	#2,d3					; 2 frame delay between each line
		dbf	d1,.loop
		
		cmpi.w	#rings_for_continue,(v_rings).w
		bcs.s	.no_continue				; branch if you have under 50 rings
		jsr	FindFreeInert
		move.l	#HasPassedCard,ost_id(a1)		; load bonus text object
		move.b	#id_Has_WaitEnter,ost_routine(a1)
		move.l	#Map_Has,ost_mappings(a1)
		move.w	(v_tile_bonus).w,ost_tile(a1)
		addi.w	#tile_hi,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.w	#priority_0,ost_priority(a1)
		move.b	#id_frame_has_continue,ost_frame(a1)
		move.w	#screen_right,ost_x_pos(a1)
		move.w	#screen_left+80,ost_has_x_stop(a1)	; x pos when text stops on screen
		move.w	d2,ost_y_screen(a1)
		move.w	d3,ost_has_time(a1)
		move.w	ost_has_x_stop(a1),d4
		swap	d4
		move.w	ost_y_screen(a1),d4			; d4 = x/y pos of continue
		
	.no_continue:
		jsr	FindFreeInert
		move.l	#HasPassedCard,ost_id(a1)		; load ring bonus object
		move.b	#id_Has_Rings,ost_routine(a1)
		
		jsr	FindFreeInert
		move.l	#SSResult,ost_id(a1)			; load bonus helper object
		move.b	#id_SSR_WaitBonus,ost_routine(a1)
		move.w	#240,ost_ssr_time(a1)			; set delay for bonus counting
		move.l	d4,ost_x_pos(a1)			; copy x/y pos of continue
		move.b	#1,(f_pass_bonus_update).w		; set flag to update
		
		jsr	FindFreeInert
		move.l	#SSRChaos,ost_id(a1)			; load chaos emerald object
		rts
; ===========================================================================
		
SSR_WaitBonus:	; Routine 2
		clr.b	(f_pass_bonus_update).w			; clear ring bonus update flag
		subq.w	#1,ost_ssr_time(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto SSR_Bonus next
		
	.wait:
		rts
; ===========================================================================
		
SSR_Bonus:	; Routine 4
		clr.b	(f_pass_bonus_update).w			; clear time/ring bonus update flag
		moveq	#0,d0
		tst.w	(v_ring_bonus).w			; is ring bonus	= zero?
		beq.s	.skip_ringbonus				; if yes, branch
		addi.w	#10,d0					; add 10 to score
		subi.w	#10,(v_ring_bonus).w			; subtract 10 from ring bonus

	.skip_ringbonus:
		tst.w	d0					; is there any bonus?
		bne.s	.add_bonus				; if yes, branch
		play_sound sfx_Register				; play "ker-ching" sound
		addq.b	#2,ost_routine(a0)			; goto SSR_Finish next
		move.w	#180,ost_ssr_time(a0)			; set time delay to 3 seconds
		cmpi.w	#rings_for_continue,(v_rings).w
		bcs.s	.exit					; branch if you have under 50 rings
		jsr	FindFreeInert
		move.l	#SSResult,ost_id(a1)			; load mini Sonic object
		move.b	#id_SSR_Continue,ost_routine(a1)
		move.l	ost_x_pos(a0),ost_x_pos(a1)		; match x/y pos to continue text
		move.w	#2*60,ost_ssr_time(a1)			; set delay to 2 seconds
		move.w	#7*60,ost_ssr_time(a0)			; set delay to 7 seconds
		
	.exit:
		rts

.add_bonus:
		move.b	#1,(f_pass_bonus_update).w		; set flag to update
		jsr	(AddPoints).w				; add d0 to score and update counter
		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		andi.b	#3,d0					; read bits 0-1
		bne.s	.exit					; branch if either are set
		play_sound sfx_Switch				; play "blip" sound every 4th frame
		rts
; ===========================================================================

SSR_Finish:	; Routine 6
		subq.w	#1,ost_ssr_time(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		move.w	#1,(f_restart).w			; restart level
		
	.wait:
		rts
; ===========================================================================

SSR_Continue:	; Routine 8
		tst.b	(f_pass_bonus_update).w
		bne.s	.wait					; branch if ring bonus is still counting
		subq.w	#1,ost_ssr_time(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		move.l	#Map_SSR,ost_mappings(a0)
		move.w	#tile_Art_MiniSonic+tile_hi,ost_tile(a0)
		move.b	#render_abs,ost_render(a0)
		move.b	#id_frame_ssr_contsonic1,ost_frame(a0)
		move.b	#id_SSR_ContAni,ost_routine(a0)		; goto SSR_ContAni next
		play_sound sfx_Continue				; play continues jingle
		
	.wait:
		rts
; ===========================================================================

SSR_ContAni:	; Routine $A
		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		andi.b	#$F,d0					; read only bits 0-3
		bne.s	.wait					; branch if any bits are set
		bchg	#0,ost_frame(a0)			; Sonic moves his foot every 16th frame

	.wait:
		jmp	DisplaySprite
