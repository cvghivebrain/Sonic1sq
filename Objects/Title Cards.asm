; ---------------------------------------------------------------------------
; Object 34 - zone title cards

; spawned by:
;	GM_Level, TitleCard
; ---------------------------------------------------------------------------

TitleCard:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Card_Index(pc,d0.w),d1
		jmp	Card_Index(pc,d1.w)
; ===========================================================================
Card_Index:	index *,,2
		ptr Card_Main
		ptr Card_Move
		ptr Card_Wait
		ptr Card_Wait

		rsobj TitleCard
ost_card_x_stop:	rs.w 1 ; $30				; on screen x position (2 bytes)
ost_card_x_start:	rs.w 1 ; $32				; start & finish x position (2 bytes)
ost_card_time:		rs.w 1 ; $3E
		rsobjend

Card_ItemData:	; y position, routine number, frame number
		dc.w $D0
		dc.b id_Card_Move, id_frame_card_ghz		; zone name (frame number changes)
		dc.w $E4
		dc.b id_Card_Move, id_frame_card_zone		; "ZONE"
		dc.w $EA
		dc.b id_Card_Move, id_frame_card_act1		; act number (frame number changes)
		dc.w $E0
		dc.b id_Card_Move, id_frame_card_oval		; oval
; ===========================================================================

Card_Main:	; Routine 0
		moveq	#id_UPLC_TitleCard,d0
		jsr	UncPLC					; load title card patterns
		movea.l	a0,a1					; replace current object with 1st item in list
		moveq	#0,d0
		move.w	(v_titlecard_zone).w,d0			; get frame number for zone
		movea.l	#Map_Card,a2				; goto mappings
		bsr.w	SkipMappings				; jump to data immediately after mappings
		lea	(Card_ItemData).l,a3			; y pos/routine/frame for each item
		moveq	#4-1,d1					; there are 4 items (minus 1 for 1st loop)

.loop:
		move.l	#TitleCard,ost_id(a1)
		move.w	(a2),ost_x_pos(a1)			; set initial x position
		move.w	(a2)+,ost_card_x_start(a1)
		move.w	(a2)+,ost_card_x_stop(a1)		; set target x position
		move.w	(a3)+,ost_y_screen(a1)			; set y position
		move.b	(a3)+,ost_routine(a1)			; goto Card_Move next
		moveq	#0,d0
		move.b	(a3)+,d0				; set frame number
		cmpi.b	#id_frame_card_ghz,d0
		bne.s	.not_zone
		move.w	(v_titlecard_zone).w,d0			; get frame id for zone

	.not_zone:
		cmpi.b	#id_frame_card_act1,d0
		bne.s	.not_act
		move.w	(v_titlecard_act).w,d0			; get frame id for act

	.not_act:
		move.w	d0,ost_frame_hi(a1)			; display frame number d0
		move.l	#Map_Card,ost_mappings(a1)
		move.w	(v_tile_titlecard).w,ost_tile(a1)
		add.w	#tile_hi,ost_tile(a1)
		move.b	#$78,ost_displaywidth(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.w	#60,ost_card_time(a1)			; set time delay to 1 second
		lea	sizeof_ost(a1),a1			; next object
		dbf	d1,.loop				; repeat sequence 3 times

Card_Move:	; Routine 2
		moveq	#$10,d1					; set to move 16px right
		move.w	ost_card_x_stop(a0),d0
		cmp.w	ost_x_pos(a0),d0			; has item reached the target position?
		beq.s	.at_target				; if yes, branch
		bge.s	.is_left				; branch if item is left of target
		neg.w	d1					; move left instead

	.is_left:
		add.w	d1,ost_x_pos(a0)			; update position

	.at_target:
		move.w	ost_x_pos(a0),d0
		bmi.s	.no_display				; branch if item is outside left of screen
		cmpi.w	#$200,d0				; is item right of $200 on x-axis?
		bcc.s	.no_display				; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

.no_display:
		rts	
; ===========================================================================

Card_Wait:	; Routine 4/6
		; title cards are instructed to jump here by GM_Level
		tst.w	ost_card_time(a0)			; has timer hit 0?
		beq.s	Card_MoveBack				; if yes, branch
		subq.w	#1,ost_card_time(a0)			; decrement timer
		bra.w	DisplaySprite
; ===========================================================================

Card_MoveBack:
		tst.b	ost_render(a0)				; is item on-screen?
		bpl.s	Card_ChangeArt				; if not, branch

		moveq	#$20,d1					; set to move 32px right
		move.w	ost_card_x_start(a0),d0
		cmp.w	ost_x_pos(a0),d0			; has item reached the finish position?
		beq.s	Card_ChangeArt				; if yes, branch
		bge.s	.is_left				; branch if item is left of target
		neg.w	d1					; move left instead

	.is_left:
		add.w	d1,ost_x_pos(a0)			; update position
		move.w	ost_x_pos(a0),d0
		bmi.s	.no_display				; branch if item is outside left of screen
		cmpi.w	#$200,d0				; is item right of $200 on x-axis?
		bcc.s	.no_display				; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

.no_display:
		rts	
; ===========================================================================

Card_ChangeArt:
		cmpi.b	#id_Card_Wait,ost_routine(a0)		; is this the main object? (routine 4)
		bne.s	.delete					; if not, branch

		moveq	#id_UPLC_Explode,d0
		jsr	UncPLC					; load explosion gfx

	.delete:
		bra.w	DeleteObject
