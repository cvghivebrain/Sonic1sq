; ---------------------------------------------------------------------------
; Object 34 - zone title cards

; spawned by:
;	GM_Level, TitleCard, HasPassedCard
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
ost_card_time:		equ ost_inertia				; time to wait before entering
ost_card_time2:		equ ost_angle				; time to wait before leaving
		rsobjend

Card_Settings:	index *
		ptr CardSet_GHZ
		ptr CardSet_MZ
		ptr CardSet_SYZ
		ptr CardSet_LZ
		ptr CardSet_SLZ
		ptr CardSet_SBZ
		ptr CardSet_FZ
		
gettextwidth:	macro str1
		textwidth: = 0
		tempstr: equs \str1				; copy string
		rept strlen(\str1)				; do for all chars
		tempchr: substr ,1,"\tempstr"			; read first char
		tempstr: substr 2,,"\tempstr"			; strip first char
		if instr("I","\tempchr")
		textwidth: = textwidth+8			; I is 8px wide
		else
		textwidth: = textwidth+16			; all other chars are 16px wide
		endc
		endr
		endm
		
autocard:	macro namestr,zonestr,nameframe,zoneframe,ypos,options
		gettextwidth \namestr
		namewidth: = textwidth
		namexpos: = (screen_width-namewidth)/2
		
		gettextwidth \zonestr
		zonewidth: = textwidth
		itemcount: = 4
		
		if instr("\options","noact")=0
		zonexpos: = namexpos+namewidth-zonewidth-17
		else
		zonexpos: = namexpos+namewidth-zonewidth
		itemcount: = itemcount-1
		endc
		if strlen(\zonestr)=0
		itemcount: = itemcount-1
		endc
		
		ovalxpos: = namexpos+namewidth-24
		nameypos: = \ypos
		zoneypos: = nameypos+20
		actypos: = nameypos+34
		ovalypos: = nameypos+24
		
		if instr("\options","center")>0
		zonexpos: = (screen_width-zonewidth)/2
		ovalxpos: = (screen_width-$1C)/2
		if strlen(\zonestr)=0
		ovalypos: = nameypos+8
		else
		ovalypos: = nameypos+12
		endc
		endc
		
		dc.w itemcount-1				; number of objects
		; green hill
		dc.l Map_Card					; mappings pointer
		dc.b \nameframe					; frame id
		dc.b id_Card_WaitEnter				; routine number
		dc.w screen_left-namewidth,screen_top+nameypos	; x/y start
		dc.w 10						; delay before entering screen
		dc.w 16,0					; x/y speed entering screen
		dc.w screen_left+namexpos,screen_top+nameypos	; x/y stop
		dc.w 60						; delay before leaving screen
		dc.w -32,0					; x/y speed leaving screen
		dc.l v_tile_letters				; RAM address where tile setting is stored
		if namewidth<256
		dc.w namewidth					; ost_displaywidth
		else
		dc.w 255
		endc
		; zone
		if strlen(\zonestr)>0
		dc.l Map_Card					; mappings pointer
		dc.b \zoneframe					; frame id
		dc.b id_Card_WaitEnter				; routine number
		dc.w screen_left-zonewidth,screen_top+zoneypos	; x/y start
		dc.w 40						; delay before entering screen
		dc.w 16,0					; x/y speed entering screen
		dc.w screen_left+zonexpos,screen_top+zoneypos	; x/y stop
		dc.w 60						; delay before leaving screen
		dc.w -32,0					; x/y speed leaving screen
		dc.l v_tile_letters				; RAM address where tile setting is stored
		if zonewidth<256
		dc.w zonewidth					; ost_displaywidth
		else
		dc.w 255
		endc
		endc
		if instr("\options","noact")=0
		; act
		dc.l Map_Card					; mappings pointer
		dc.b id_frame_card_act				; frame id
		dc.b id_Card_WaitEnter				; routine number
		dc.w screen_right+32,screen_top+actypos		; x/y start
		dc.w 38						; delay before entering screen
		dc.w -16,0					; x/y speed entering screen
		dc.w screen_left+ovalxpos,screen_top+actypos	; x/y stop
		dc.w 60						; delay before leaving screen
		dc.w 32,0					; x/y speed leaving screen
		dc.l v_tile_act					; RAM address where tile setting is stored
		dc.w 20
		endc
		; oval
		dc.l Map_Card					; mappings pointer
		dc.b id_frame_card_oval				; frame id
		dc.b id_Card_WaitEnter				; routine number
		dc.w screen_right+32,screen_top+ovalypos	; x/y start
		dc.w 6						; delay before entering screen
		dc.w -16,0					; x/y speed entering screen
		dc.w screen_left+ovalxpos,screen_top+ovalypos	; x/y stop
		dc.w 60						; delay before leaving screen
		dc.w 32,0					; x/y speed leaving screen
		dc.l v_tile_titlecard				; RAM address where tile setting is stored
		dc.w 28
		endm
		
CardSet_GHZ:	autocard "GREEN HILL","ZONE",id_frame_card_greenhill,id_frame_card_zone,72
CardSet_MZ:	autocard "MARBLE","ZONE",id_frame_card_marble,id_frame_card_zone,72
CardSet_SYZ:	autocard "SPRING YARD","ZONE",id_frame_card_springyard,id_frame_card_zone,72
CardSet_LZ:	autocard "LABYRINTH","ZONE",id_frame_card_labyrinth,id_frame_card_zone,72
CardSet_SLZ:	autocard "STAR LIGHT","ZONE",id_frame_card_starlight,id_frame_card_zone,72
CardSet_SBZ:	autocard "SCRAP BRAIN","ZONE",id_frame_card_scrapbrain,id_frame_card_zone,72
CardSet_FZ:	autocard "FINAL","ZONE",id_frame_card_final,id_frame_card_zone,72,noact
; ===========================================================================

Card_Main:	; Routine 0
		move.w	(v_titlecard_uplc).w,d0
		jsr	UncPLC					; load title card gfx
		move.w	(v_titlecard_act).w,d0
		subq.w	#2,d0
		bcs.s	.keep_act				; branch if act is 0 or 1
		addi.w	#id_UPLC_Act2Card,d0
		jsr	UncPLC					; load act 2/3 gfx
		
	.keep_act:
		lea	Card_Settings,a2
		move.w	(v_titlecard_zone).w,d0
		
Card_Load:
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
		addi.w	#tile_hi,ost_tile(a1)
		move.w	(a2)+,d0
		move.b	d0,ost_displaywidth(a1)
		move.b	#render_abs,ost_render(a1)
		move.w	#priority_0,ost_priority(a1)
		dbf	d1,.loop
		rts
; ===========================================================================
		
Card_WaitEnter:	; Routine 2
		tst.b	ost_mode(a0)
		bne.s	.flag_set				; branch if loaded flag is set
		addq.b	#1,(v_titlecard_loaded).w		; add to object count
		move.b	#1,ost_mode(a0)				; set flag
		
	.flag_set:
		subq.w	#1,ost_card_time(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Card_Enter next
		
	.wait:
		rts
; ===========================================================================
		
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
		addq.b	#2,ost_routine(a0)			; goto Card_WaitLeave next
		addq.b	#1,(v_titlecard_state).w
		
	.not_at_stop:
		jmp	DisplaySprite
; ===========================================================================
		
Card_WaitLeave:	; Routine 6
		tst.w	(v_brightness).w
		bne.s	.wait					; branch if still fading in from black
		tst.b	(v_haspassed_state).w
		bne.s	.wait					; branch if on "Sonic Has Passed" card
		subq.w	#1,ost_card_time2(a0)			; decrement timer
		bpl.s	.wait					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Card_Leave next
		
	.wait:
		jmp	DisplaySprite
; ===========================================================================
		
Card_Leave:	; Routine 8
		move.w	ost_card_x_speed2(a0),d0
		add.w	d0,ost_x_pos(a0)			; update x pos
		move.w	ost_card_y_speed2(a0),d0
		add.w	d0,ost_y_screen(a0)			; update y pos
		
		moveq	#0,d0
		move.b	ost_displaywidth(a0),d0
		move.w	ost_x_pos(a0),d1
		subi.w	#screen_left,d1
		add.w	d0,d1
		add.w	d0,d0
		addi.w	#screen_width,d0
		cmp.w	d0,d1
		bcc.s	.offscreen				; branch if off screen
		jmp	DisplaySprite
		
	.offscreen:
		subq.b	#1,(v_titlecard_state).w
		subq.b	#1,(v_titlecard_loaded).w
		bne.s	.skip_gfx				; branch if not the last title card object
		moveq	#id_UPLC_Explode,d0
		jsr	UncPLC					; load explosion gfx
		
	.skip_gfx:
		jmp	DeleteObject
		
