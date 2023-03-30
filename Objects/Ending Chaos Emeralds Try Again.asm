; ---------------------------------------------------------------------------
; Object 8C - chaos emeralds on	the "TRY AGAIN"	screen

; spawned by:
;	EndEggman
; ---------------------------------------------------------------------------

TryChaos:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	TCha_Index(pc,d0.w),d1
		jsr	TCha_Index(pc,d1.w)
		jmp	(DisplaySprite).l
; ===========================================================================
TCha_Index:	index *,,2
		ptr TCha_Main
		ptr TCha_Move
		ptr TCha_Wait
		ptr TCha_Arc
		ptr TCha_Stop

		rsobj TryChaos
ost_ectry_time_master:	rs.b 1 ; $37
ost_ectry_x_start:	rs.w 1 ; $38				; x-axis centre of emerald circle (2 bytes)
ost_ectry_y_start:	rs.w 1 ; $3A				; y-axis centre of emerald circle (2 bytes)
ost_ectry_radius:	rs.b 1 ; $3C				; radius
ost_ectry_speed:	rs.w 1 ; $3E				; speed at which emeralds rotate around central point (2 bytes)
		rsobjend
; ===========================================================================

TCha_Main:	; Routine 0
		movea.l	a0,a1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#emerald_count-1,d1
		move.l	(v_emeralds).w,d4			; get emerald bitfield
		bra.s	.skipfindost

.makeemerald:
		jsr	FindFreeInert
		
	.skipfindost:
		move.l	#0,ost_id(a1)				; set object to none by default
		btst	d2,d4					; check if emerald was collected
		bne.s	.sonic_has_emerald			; branch if yes

		move.l	#TryChaos,ost_id(a1)			; load emerald object
		move.b	#id_TCha_Move,ost_routine(a1)		; goto TCha_Move next
		move.l	#Map_ECha,ost_mappings(a1)
		move.w	(v_tile_emeralds).w,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#1,ost_priority(a1)
		move.w	#$104,ost_x_pos(a1)
		move.w	#$120,ost_ectry_x_start(a1)
		move.w	#$EC,ost_y_screen(a1)
		move.w	ost_y_screen(a1),ost_ectry_y_start(a1)
		move.b	#$1C,ost_ectry_radius(a1)
		move.b	#$80,ost_angle(a1)
		move.b	d2,ost_frame(a1)
		addq.b	#id_frame_echaos_blue,ost_frame(a1)	; set frame based on emerald id
		move.b	d3,ost_anim_time(a1)
		move.b	d3,ost_ectry_time_master(a1)
		move.w	ost_parent(a0),ost_parent(a1)

	.sonic_has_emerald:
		addq.b	#1,d2					; next emerald
		addi.w	#10,d3
		dbf	d1,.makeemerald				; repeat for remaining emeralds

TCha_Move:	; Routine 2
		getparent					; a1 = OST of Eggman
		cmpi.b	#id_frame_eegg_juggle2,ost_frame(a1)
		bne.s	.not_right				; branch if Eggman isn't throwing right
		move.b	#$90,ost_angle(a0)			; match angle to Eggman's hand
		bsr.w	TCha_Update
		move.b	#2,ost_ectry_speed(a0)			; set direction of rotation
		move.b	#id_TCha_Wait,ost_routine(a0)		; goto TCha_Wait next
		rts
		
	.not_right:
		cmpi.b	#id_frame_eegg_juggle4,ost_frame(a1)
		bne.s	.not_left				; branch if Eggman isn't throwing left
		move.b	#$F0,ost_angle(a0)			; match angle to Eggman's hand
		bsr.w	TCha_Update
		move.b	#-2,ost_ectry_speed(a0)			; set direction of rotation
		move.b	#id_TCha_Wait,ost_routine(a0)		; goto TCha_Wait next
		
	.not_left:
		rts

TCha_Wait:	; Routine 4
		subq.b	#1,ost_anim_time(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		move.b	ost_ectry_time_master(a0),ost_anim_time(a0) ; reset timer
		move.b	#id_TCha_Arc,ost_routine(a0)		; goto TCha_Arc next
	.wait:
		rts
		
TCha_Arc:	; Routine 6
		move.w	ost_ectry_speed(a0),d0			; 2 or -2
		add.w	d0,ost_angle(a0)			; update angle
		bsr.s	TCha_Update				; update position
		move.b	ost_angle(a0),d0
		beq.s	.stopmoving
		cmp.b	#$80,d0
		bne.s	.keepmoving				; branch if emerald has been caught
		
	.stopmoving:
		move.b	#id_TCha_Stop,ost_routine(a0)		; goto TCha_Stop next
		
	.keepmoving:
		rts
		
TCha_Update:
		move.b	ost_angle(a0),d0			; get angle
		jsr	(CalcSine).l				; convert angle (d0) to sine (d0) and cosine (d1)
		moveq	#0,d4
		move.b	ost_ectry_radius(a0),d4
		muls.w	d4,d1
		asr.l	#8,d1
		muls.w	d4,d0
		asr.l	#8,d0
		add.w	ost_ectry_x_start(a0),d1
		add.w	ost_ectry_y_start(a0),d0
		move.w	d1,ost_x_pos(a0)
		move.w	d0,ost_y_screen(a0)			; update position
		rts
		
TCha_Stop:	; Routine 8
		getparent					; a1 = OST of Eggman
		cmpi.b	#id_frame_eegg_juggle1,ost_frame(a1)
		beq.s	.goto_move				; branch if Eggman is preparing to throw
		cmpi.b	#id_frame_eegg_juggle3,ost_frame(a1)
		bne.s	.exit
		
	.goto_move:
		move.b	#id_TCha_Move,ost_routine(a0)		; goto TCha_Move next
		
	.exit:
		rts
