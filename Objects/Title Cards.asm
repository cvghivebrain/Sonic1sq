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
		ptr Card_WaitEnter
		ptr Card_Enter
		ptr Card_WaitLeave
		ptr Card_Leave

		rsobj TitleCard
ost_card_x_stop:	rs.l 1					; on screen x position
ost_card_y_stop:	equ __rs-2				; on screen y position
ost_card_x_speed:	rs.l 1					; x speed to enter screen
ost_card_y_speed:	equ __rs-2				; y speed to enter screen
ost_card_x_speed2:	rs.l 1					; x speed to leave screen
ost_card_y_speed2:	equ __rs-2				; y speed to leave screen
ost_card_time:		rs.w 1					; time to wait before entering
ost_card_time2:		rs.w 1					; time to wait before leaving
		rsobjend

Card_Settings:	index *
		ptr CardSet_GHZ
		ptr CardSet_MZ
		ptr CardSet_SYZ
		ptr CardSet_LZ
		ptr CardSet_SLZ
		ptr CardSet_SBZ
		ptr CardSet_FZ
		
autocard:	macro namestr,zonestr
		namewidth: = 0
		tempstr: equs \namestr				; copy string
		rept strlen(\namestr)				; do for all chars
		tempchr: substr ,1,"\tempstr"			; read first char
		tempstr: substr 2,,"\tempstr"			; strip first char
		if instr("I","\tempchr")
		namewidth: = namewidth+8			; I is 8px wide
		else
		namewidth: = namewidth+16			; all other chars are 16px wide
		endc
		endr
		zonewidth: = 0
		tempstr: equs \zonestr				; copy string
		rept strlen(\zonestr)				; do for all chars
		tempchr: substr ,1,"\tempstr"			; read first char
		tempstr: substr 2,,"\tempstr"			; strip first char
		if instr("I","\tempchr")
		zonewidth: = zonewidth+8			; I is 8px wide
		else
		zonewidth: = zonewidth+16			; all other chars are 16px wide
		endc
		endr
		namexpos: = (screen_width-namewidth)/2
		if ~strcmp("\3","noact")
		zonexpos: = namexpos+namewidth-zonewidth-17
		else
		zonexpos: = namexpos+namewidth-zonewidth
		endc
		ovalxpos: = namexpos+namewidth-28
		dc.w 4-1					; number of objects
		; green hill
		dc.l Map_Card					; mappings pointer
		dc.b -1						; frame id (-1 for string)
		dc.b id_Card_WaitEnter				; routine number
		dc.w screen_left-16,screen_top+80		; x/y start
		dc.w 10						; delay before entering screen
		dc.w 16,0					; x/y speed entering screen
		dc.w screen_left+namexpos,screen_top+80		; x/y stop
		dc.w 60						; delay before leaving screen
		dc.w -32,0					; x/y speed leaving screen
		dc.l v_tile_a					; RAM address where tile setting is stored
		dc.b \namestr,0
		even
		; zone
		dc.l Map_Card					; mappings pointer
		dc.b -1						; frame id (-1 for string)
		dc.b id_Card_WaitEnter				; routine number
		dc.w screen_left-16,screen_top+100		; x/y start
		dc.w 40						; delay before entering screen
		dc.w 16,0					; x/y speed entering screen
		dc.w screen_left+zonexpos,screen_top+100	; x/y stop
		dc.w 60						; delay before leaving screen
		dc.w -32,0					; x/y speed leaving screen
		dc.l v_tile_a					; RAM address where tile setting is stored
		dc.b \zonestr,0
		even
		; act
		dc.l Map_Card					; mappings pointer
		dc.b id_frame_card_act				; frame id
		if ~strcmp("\3","noact")
		dc.b id_Card_WaitEnter				; routine number
		else
		dc.b id_Card_Leave				; delete if there is no act number
		endc
		dc.w screen_right+32,screen_top+106		; x/y start
		dc.w 38						; delay before entering screen
		dc.w -16,0					; x/y speed entering screen
		dc.w screen_left+ovalxpos,screen_top+106	; x/y stop
		dc.w 60						; delay before leaving screen
		dc.w 32,0					; x/y speed leaving screen
		dc.l v_tile_act					; RAM address where tile setting is stored
		; oval
		dc.l Map_Card					; mappings pointer
		dc.b id_frame_card_oval				; frame id
		dc.b id_Card_WaitEnter				; routine number
		dc.w screen_right+32,screen_top+96		; x/y start
		dc.w 6						; delay before entering screen
		dc.w -16,0					; x/y speed entering screen
		dc.w screen_left+ovalxpos,screen_top+96		; x/y stop
		dc.w 60						; delay before leaving screen
		dc.w 32,0					; x/y speed leaving screen
		dc.l v_tile_titlecard				; RAM address where tile setting is stored
		endm
		
CardSet_GHZ:	autocard "GREEN HILL","ZONE"
CardSet_MZ:	autocard "MARBLE","ZONE"
CardSet_SYZ:	autocard "SPRING YARD","ZONE"
CardSet_LZ:	autocard "LABYRINTH","ZONE"
CardSet_SLZ:	autocard "STAR LIGHT","ZONE"
CardSet_SBZ:	autocard "SCRAP BRAIN","ZONE"
CardSet_FZ:	autocard "FINAL","ZONE",noact
; ===========================================================================

Card_Main:	; Routine 0
		move.w	(v_titlecard_uplc).w,d0
		jsr	UncPLC					; load title card gfx
		move.w	(v_titlecard_act).w,d0
		sub.w	#2,d0
		bcs.s	.keep_act				; branch if act is 0 or 1
		add.w	#id_UPLC_Act2Card,d0
		jsr	UncPLC					; load act 2/3 gfx
		
	.keep_act:
		lea	Card_Settings,a2
		move.w	(v_titlecard_zone).w,d0
		add.w	d0,d0
		move.w	(a2,d0.w),d0
		lea	(a2,d0.w),a2				; jump to relevant card settings
		move.w	(a2)+,d1				; get number of objects (-1 for loops)
		movea.l	a0,a1					; first object replaces this one
		bra.s	.skip_find_ost
		
	.loop:
		jsr	FindFreeInert
		move.l	#TitleCard,ost_id(a1)
	.skip_find_ost:
		move.l	(a2)+,ost_mappings(a1)
		move.b	(a2)+,ost_frame(a1)
		move.b	(a2)+,ost_routine(a1)			; goto Card_WaitEnter next
		move.l	(a2)+,ost_x_pos(a1)			; set initial x/y position (screen-fixed)
		move.w	(a2)+,ost_card_time(a1)			; set time delay for entering screen
		move.l	(a2)+,ost_card_x_speed(a1)		; set x/y speed for entering screen
		move.l	(a2)+,ost_card_x_stop(a1)		; set x/y position for stopping on screen
		move.w	(a2)+,ost_card_time2(a1)		; set time delay for leaving screen
		move.l	(a2)+,ost_card_x_speed2(a1)		; set x/y speed for leaving screen
		movea.l	(a2)+,a3
		move.w	(a3),ost_tile(a1)
		add.w	#tile_hi,ost_tile(a1)
		move.b	#$20,ost_displaywidth(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		tst.b	ost_frame(a1)
		bpl.s	.not_a_string				; branch if object isn't a string ("ZONE" or zone name)
		bsr.s	Card_String
	.not_a_string:
		dbf	d1,.loop
		rts
		
Card_String:
		movea.l	a1,a4					; save OST address of first letter
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		move.b	(a2)+,d2				; get first letter
		bra.s	.skip_find_ost
		
	.loop:
		cmp.b	#$20,d2
		beq.w	.space					; branch if character is a space
		jsr	FindFreeInert
		move.l	#TitleCard,ost_id(a1)
		move.l	ost_mappings(a4),ost_mappings(a1)
		move.l	ost_x_pos(a4),ost_x_pos(a1)		; set initial x/y position (screen-fixed)
		move.w	ost_card_time(a4),ost_card_time(a1)	; set time delay for entering screen
		move.l	ost_card_x_speed(a4),ost_card_x_speed(a1) ; set x/y speed for entering screen
		move.l	ost_card_x_stop(a4),ost_card_x_stop(a1)	; set x/y position for stopping on screen
		move.w	ost_card_time2(a4),ost_card_time2(a1)	; set time delay for leaving screen
		move.l	ost_card_x_speed2(a4),ost_card_x_speed2(a1) ; set x/y speed for leaving screen
		move.b	#8,ost_displaywidth(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	ost_routine(a4),ost_routine(a1)		; goto Card_WaitEnter next
	.skip_find_ost:
		sub.w	#$41,d2					; convert letter from ASCII
		add.w	d2,d2					; multiply by 2
		move.w	#id_frame_card_letter,ost_frame_hi(a1)
		add.w	d3,ost_card_x_stop(a1)
		sub.w	d4,ost_card_time(a1)
		cmp.w	#('I'-$41)*2,d2
		bne.s	.not_i					; branch if letter isn't I
		move.w	#id_frame_card_i,ost_frame_hi(a1)	; use different frame
		sub.w	#8,d3					; next letter is shifted 8px left
	.not_i:
		move.w	(a3,d2.w),ost_tile(a1)			; get tile setting for specific letter
		add.w	#tile_hi,ost_tile(a1)
	.space:
		add.w	#16,d3					; relative position of next letter
		add.w	#1,d4					; extra delay for next letter
		move.b	(a2)+,d2				; get next letter
		bne.w	.loop					; branch if not 0
		evenr	a2					; align a2 to even byte
		rts
		
Card_WaitEnter:	; Routine 2
		tst.b	ost_routine2(a0)
		bne.s	.flag_set				; branch if loaded flag is set
		addq.b	#1,(v_titlecard_loaded).w		; add to object count
		move.b	#1,ost_routine2(a0)			; set flag
		
	.flag_set:
		subq.w	#1,ost_card_time(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		add.b	#2,ost_routine(a0)			; goto Card_Enter next
		
	.wait:
		rts
		
Card_Enter:	; Routine 4
		moveq	#0,d1
		move.w	ost_card_x_speed(a0),d2
		beq.s	.x_stop
		abs.w	d2
		move.w	ost_card_x_stop(a0),d0
		sub.w	ost_x_pos(a0),d0			; d0 = x distance to stop
		abs.w	d0					; force +ve
		cmp.w	d0,d2
		bhi.s	.x_stop					; branch if at stop x pos
		move.w	ost_card_x_speed(a0),d0
		add.w	d0,ost_x_pos(a0)			; update x pos
		moveq	#1,d1
		
	.x_stop:
		move.w	ost_card_y_speed(a0),d2
		beq.s	.y_stop
		abs.w	d2
		move.w	ost_card_y_stop(a0),d0
		sub.w	ost_y_screen(a0),d0			; d0 = y distance to stop
		abs.w	d0					; force +ve
		cmp.w	d0,d2
		bhi.s	.y_stop					; branch if at stop y pos
		move.w	ost_card_y_speed(a0),d0
		add.w	d0,ost_y_screen(a0)			; update y pos
		moveq	#1,d1
		
	.y_stop:
		tst.b	d1
		bne.s	.not_at_stop				; branch if not at stop x/y pos
		move.w	ost_card_x_stop(a0),ost_x_pos(a0)
		move.w	ost_card_y_stop(a0),ost_y_screen(a0)	; force precise x/y pos
		add.b	#2,ost_routine(a0)			; goto Card_WaitLeave next
		addq.b	#1,(v_titlecard_state).w
		
	.not_at_stop:
		jmp	DisplaySprite
		
Card_WaitLeave:	; Routine 6
		tst.w	(v_brightness).w
		bne.s	.wait					; branch if still fading in from black
		subq.w	#1,ost_card_time2(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		add.b	#2,ost_routine(a0)			; goto Card_Leave next
		
	.wait:
		jmp	DisplaySprite
		
Card_Leave:	; Routine 8
		move.w	ost_card_x_speed2(a0),d0
		add.w	d0,ost_x_pos(a0)			; update x pos
		move.w	ost_card_y_speed2(a0),d0
		add.w	d0,ost_y_screen(a0)			; update y pos
		jsr	CheckOffScreen_Card
		bne.s	.offscreen				; branch if off screen
		jmp	DisplaySprite
		
	.offscreen:
		subq.b	#1,(v_titlecard_state).w
		subq.b	#1,(v_titlecard_loaded).w
		tst.b	(v_titlecard_loaded).w
		bne.s	.skip_gfx				; branch if not the last title card object
		moveq	#id_UPLC_Explode,d0
		jsr	UncPLC					; load explosion gfx
		
	.skip_gfx:
		jmp	DeleteObject
		