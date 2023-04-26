; ---------------------------------------------------------------------------
; Object 88 - chaos emeralds on	the ending sequence

; spawned by:
;	EndSonic
; ---------------------------------------------------------------------------

EndChaos:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	ECha_Index(pc,d0.w),d1
		jsr	ECha_Index(pc,d1.w)
		jmp	(DisplaySprite).l
; ===========================================================================
ECha_Index:	index *,,2
		ptr ECha_Main
		ptr ECha_Move

		rsobj EndChaos
ost_echaos_x_start:	rs.w 1						; x-axis centre of emerald circle (2 bytes)
ost_echaos_y_start:	rs.w 1						; y-axis centre of emerald circle (2 bytes)
ost_echaos_radius:	rs.w 1						; radius (2 bytes)
ost_echaos_angle:	rs.w 1						; angle for rotation (2 bytes)
		rsobjend
; ===========================================================================

ECha_Main:	; Routine 0
		getsonic					; a1 = OST of Sonic
		cmpi.b	#id_frame_esonic_up,ost_frame(a1)	; is Sonic looking up?
		beq.s	ECha_CreateEms				; if yes, branch
		addq.l	#4,sp					; stop object and don't display
		rts	
; ===========================================================================

ECha_CreateEms:
		move.w	ost_x_pos(a1),ost_x_pos(a0)		; match x position with Sonic
		move.w	ost_y_pos(a1),ost_y_pos(a0)		; match y position with Sonic
		movea.l	a0,a1
		moveq	#0,d3
		moveq	#id_frame_echaos_blue,d2
		moveq	#emerald_count-1,d1
		bra.s	.skip_findost

	.loop:
		jsr	FindFreeInert
		bne.s	ECha_Move
		move.l	#EndChaos,ost_id(a1)			; load chaos emerald object
		
	.skip_findost:
		addq.b	#2,ost_routine(a1)			; goto ECha_Move next
		move.l	#Map_ECha,ost_mappings(a1)
		move.w	(v_tile_emeralds).w,ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#1,ost_priority(a1)
		move.w	ost_x_pos(a0),ost_echaos_x_start(a1)
		move.w	ost_y_pos(a0),ost_echaos_y_start(a1)
		move.w	ost_parent(a0),ost_parent(a1)
		move.b	d2,ost_anim(a1)
		move.b	d2,ost_frame(a1)
		addq.b	#1,d2
		move.b	d3,ost_angle(a1)
		addi.b	#$100/emerald_count,d3			; angle between each emerald
		dbf	d1,.loop				; repeat 5 more times

ECha_Move:	; Routine 2
		move.w	ost_echaos_angle(a0),d0
		add.w	d0,ost_angle(a0)
		move.b	ost_angle(a0),d0
		jsr	(CalcSine).l
		moveq	#0,d4
		move.b	ost_echaos_radius(a0),d4
		muls.w	d4,d1
		asr.l	#8,d1
		muls.w	d4,d0
		asr.l	#8,d0
		add.w	ost_echaos_x_start(a0),d1
		add.w	ost_echaos_y_start(a0),d0
		move.w	d1,ost_x_pos(a0)
		move.w	d0,ost_y_pos(a0)

	ECha_Expand:
		cmpi.w	#$2000,ost_echaos_radius(a0)
		beq.s	ECha_Stop
		addi.w	#$20,ost_echaos_radius(a0)		; expand circle of emeralds

	ECha_Rotate:
		cmpi.w	#$2000,ost_echaos_angle(a0)
		beq.s	ECha_Rise
		addi.w	#$20,ost_echaos_angle(a0)		; move emeralds around the centre

	ECha_Rise:
		cmpi.w	#$140,ost_echaos_y_start(a0)
		beq.s	ECha_End
		subq.w	#1,ost_echaos_y_start(a0)		; make circle rise

ECha_End:
		rts	

ECha_Stop:
		getparent					; get OST of Sonic object
		move.b	#1,ost_esonic_flag(a1)
		cmpi.b	#id_ani_esonic_confused,ost_anim(a1)
		bne.s	.wait					; branch until Sonic looks confused
		jmp	DeleteObject
		
	.wait:
		rts
		