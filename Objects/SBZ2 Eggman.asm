; ---------------------------------------------------------------------------
; Object 82 - Eggman (SBZ2)

; spawned by:
;	ObjPos_SBZ2

; subtypes:
;	%0000BBBB
;	BBBB - button id
; ---------------------------------------------------------------------------

ScrapEggman:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	SEgg_Index(pc,d0.w),d1
		jmp	SEgg_Index(pc,d1.w)
; ===========================================================================
SEgg_Index:	index *,,2
		ptr SEgg_Main
		ptr SEgg_Wait
		ptr SEgg_Wait2
		ptr SEgg_Jump
		ptr SEgg_Stop

		rsobj ScrapEggman
ost_eggman_wait_time:	rs.w 1					; time delay between events
ost_eggman_x_stop:	rs.w 1					; x position to stop at
ost_eggman_y_stop:	rs.w 1					; y position to stop at
		rsobjend
; ===========================================================================

SEgg_Main:	; Routine 0
		moveq	#id_UPLC_EggmanSBZ,d0
		jsr	UncPLC
		
		addq.b	#2,ost_routine(a0)			; goto SEgg_Wait next
		move.w	#priority_3,ost_priority(a0)
		move.l	#Map_SEgg,ost_mappings(a0)
		move.w	#tile_Art_Sbz2Eggman,ost_tile(a0)
		move.b	#render_rel+render_onscreen,ost_render(a0)
		move.b	#id_ani_eggman_laugh,ost_anim(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.w	ost_y_pos(a0),ost_eggman_y_stop(a0)
		subi.w	#9,ost_eggman_y_stop(a0)
		move.w	#-$30,d2				; button is to Eggman's left
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip					; branch if facing left
		neg.w	d2					; button is to his right

	.noflip:
		jsr	FindNextFreeObj				; find free OST slot
		bne.s	SEgg_Wait				; branch if not found
		move.l	#ScrapButton,ost_id(a1)			; load button object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		add.w	d2,ost_x_pos(a1)
		move.w	ost_x_pos(a1),ost_eggman_x_stop(a0)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		addi.w	#$18,ost_y_pos(a1)
		saveparent

SEgg_Wait:	; Routine 2
		lea	Ani_SEgg(pc),a1
		jsr	AnimateSprite
		getsonic					; a1 = OST of Sonic
		range_x_test	128
		bcc.s	.wait					; branch if more than 128px away
		move.w	#180,ost_eggman_wait_time(a0)		; set delay to 3 seconds
		addq.b	#2,ost_routine(a0)			; goto SEgg_Wait2 next
		
	.wait:
		jmp	DisplaySprite
; ===========================================================================

SEgg_Wait2:	; Routine 4
		lea	Ani_SEgg(pc),a1
		jsr	AnimateSprite
		subq.w	#1,ost_eggman_wait_time(a0)		; decrement timer
		bne.s	.wait					; if time remains, branch
		addq.b	#2,ost_routine(a0)			; goto SEgg_Jump next
		move.b	#id_ani_eggman_jump1,ost_anim(a0)
		move.b	#id_frame_eggman_jump1,ost_frame(a0)
		addq.w	#4,ost_y_pos(a0)
		move.w	#-$3C0,ost_y_vel(a0)
		move.w	#-$FC,ost_x_vel(a0)			; make Eggman jump left
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.wait					; branch if facing left
		neg.w	ost_x_vel(a0)				; make him jump right

	.wait:
		jmp	DisplaySprite
; ===========================================================================

SEgg_Jump:	; Routine 6
		lea	Ani_SEgg(pc),a1
		jsr	AnimateSprite
		cmpi.b	#id_frame_eggman_jump1,ost_frame(a0)
		beq.s	.wait					; don't jump for first animation frame
		update_xy_fall	$24				; update position & apply gravity
		move.w	ost_x_pos(a0),d0
		cmp.w	ost_eggman_x_stop(a0),d0
		bne.s	.wait
		clr.w	ost_x_vel(a0)				; stop moving when above button
		move.w	ost_y_pos(a0),d0
		cmp.w	ost_eggman_y_stop(a0),d0
		bcs.s	.wait					; branch if not on button
		addq.b	#2,ost_routine(a0)			; goto SEgg_Stop next
		move.w	ost_eggman_y_stop(a0),ost_y_pos(a0)
		move.b	#id_ani_eggman_laugh,ost_anim(a0)

	.wait:
		jmp	DisplaySprite
; ===========================================================================

SEgg_Stop:	; Routine 8
		play_sound sfx_Switch				; play "blip" sound
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0					; get low nybble of subtype
		lea	(v_button_state).w,a3
		adda.w	d0,a3					; (a3) = button status
		move.b	#1,(a3)					; set button as pressed
		shortcut
		lea	Ani_SEgg(pc),a1
		jsr	AnimateSprite
		jmp	DisplaySprite

; ---------------------------------------------------------------------------
; Button object for Eggman (SBZ2)

; spawned by:
;	ScrapEggman
; ---------------------------------------------------------------------------

ScrapButton:
		move.l	#Map_But,ost_mappings(a0)
		move.w	(v_tile_button).w,ost_tile(a0)
		move.b	#render_rel+render_onscreen,ost_render(a0)
		move.w	#priority_3,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#id_frame_button_up,ost_frame(a0)	; use unpressed frame
		shortcut
		getparent					; a1 = OST of Eggman
		cmpi.b	#id_SEgg_Stop,ost_routine(a1)
		bne.s	.wait					; branch if not on button
		move.b	#id_frame_button_down,ost_frame(a0)	; use pressed frame
		shortcut	DisplaySprite
		
	.wait:
		jmp	DisplaySprite

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_SEgg:	index *
		ptr ani_eggman_stand
		ptr ani_eggman_laugh
		ptr ani_eggman_jump1
		ptr ani_eggman_intube
		ptr ani_eggman_running
		ptr ani_eggman_jump2
		ptr ani_eggman_jump
		
ani_eggman_stand:
		dc.w $7E
		dc.w id_frame_eggman_stand
		dc.w id_Anim_Flag_Restart

ani_eggman_laugh:
		dc.w 6
		dc.w id_frame_eggman_laugh1
		dc.w id_frame_eggman_laugh2
		dc.w id_Anim_Flag_Restart

ani_eggman_jump1:
		dc.w $E
		dc.w id_frame_eggman_jump1
		dc.w id_frame_eggman_jump2
		dc.w id_frame_eggman_jump2
		dc.w id_frame_eggman_stand
		dc.w id_Anim_Flag_Stop

ani_eggman_intube:
		dc.w 0
		dc.w id_frame_eggman_surprise
		dc.w id_frame_eggman_intube
		dc.w id_Anim_Flag_Restart

ani_eggman_running:
		dc.w 6
		dc.w id_frame_eggman_running1
		dc.w id_frame_eggman_jump2
		dc.w id_frame_eggman_running2
		dc.w id_frame_eggman_jump2
		dc.w id_Anim_Flag_Restart

ani_eggman_jump2:
		dc.w $F
		dc.w id_frame_eggman_jump2
		dc.w id_frame_eggman_jump1
		dc.w id_frame_eggman_jump1
		dc.w id_Anim_Flag_Restart

ani_eggman_jump:
		dc.w $7E
		dc.w id_frame_eggman_jump
		dc.w id_Anim_Flag_Restart
