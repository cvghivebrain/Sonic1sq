; ---------------------------------------------------------------------------
; Object 6A - ground saws and pizza cutters (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2 - subtypes 1/2/3
; ---------------------------------------------------------------------------

Saws:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Saw_Index(pc,d0.w),d1
		jmp	Saw_Index(pc,d1.w)
; ===========================================================================
Saw_Index:	index *,,2
		ptr Saw_Main
		ptr Saw_Action

		rsobj Saws
ost_saw_x_start:	rs.w 1					; original x-axis position
ost_saw_y_start:	rs.w 1					; original y-axis position
		rsobjend
		
Saw_Settings:	dc.b id_frame_saw_pizzacutter1, id_Saw_Pizza_Still
		dc.b id_frame_saw_pizzacutter1, id_Saw_Pizza_Sideways
		dc.b id_frame_saw_pizzacutter1, id_Saw_Pizza_UpDown
		dc.b id_frame_saw_groundsaw1, id_Saw_Ground_Right
		dc.b id_frame_saw_groundsaw1, id_Saw_Ground_Left
; ===========================================================================

Saw_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Saw_Action next
		move.l	#Map_Saw,ost_mappings(a0)
		move.w	#tile_Kos_Cutter+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.w	ost_x_pos(a0),ost_saw_x_start(a0)
		move.w	ost_y_pos(a0),ost_saw_y_start(a0)
		move.b	#id_col_24x24_2+id_col_hurt,ost_col_type(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		add.w	d0,d0
		lea	Saw_Settings(pc,d0.w),a2
		move.b	(a2)+,ost_frame(a0)
		move.b	(a2)+,ost_subtype(a0)

Saw_Action:	; Routine 2
		shortcut
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		move.w	Saw_Type_Index(pc,d0.w),d1
		jsr	Saw_Type_Index(pc,d1.w)
		move.w	ost_saw_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================
Saw_Type_Index:
		index *,,2
		ptr Saw_Pizza_Still				; pizza cutter, doesn't move - unused
		ptr Saw_Pizza_Sideways				; pizza cutter, moves side-to-side
		ptr Saw_Pizza_UpDown				; pizza cutter, moves up and down
		ptr Saw_Ground_Right				; ground saw, moves right
		ptr Saw_Ground_Left				; ground saw, moves left - unused
		ptr Saw_Ground_Move
; ===========================================================================

; Type 0
Saw_Pizza_Still:
		rts						; doesn't move
; ===========================================================================

; Type 1
Saw_Pizza_Sideways:
		moveq	#0,d0
		move.b	(v_oscillating_0_to_60).w,d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip01
		neg.w	d0
		addi.w	#$60,d0

	.noflip01:
		move.w	ost_saw_x_start(a0),d1
		sub.w	d0,d1
		move.w	d1,ost_x_pos(a0)			; move saw sideways

		subq.b	#1,ost_anim_time(a0)
		bpl.s	.sameframe01
		move.b	#2,ost_anim_time(a0)			; time between frame changes
		bchg	#0,ost_frame(a0)			; change frame

	.sameframe01:
		tst.b	ost_render(a0)
		bpl.s	.nosound01				; branch if not on screen
		move.w	(v_frame_counter).w,d0
		andi.w	#$F,d0
		bne.s	.nosound01
		play.w	1, jsr, sfx_Saw				; play saw sound every 16th frame

	.nosound01:
		rts	
; ===========================================================================

; Type 2
Saw_Pizza_UpDown:
		moveq	#0,d0
		move.b	(v_oscillating_0_to_30).w,d0
		move.b	d0,d2
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip02
		neg.w	d0
		addi.w	#$80,d0

	.noflip02:
		move.w	ost_saw_y_start(a0),d1
		sub.w	d0,d1
		move.w	d1,ost_y_pos(a0)			; move saw vertically
		subq.b	#1,ost_anim_time(a0)
		bpl.s	.sameframe02
		move.b	#2,ost_anim_time(a0)
		bchg	#0,ost_frame(a0)

	.sameframe02:
		tst.b	ost_render(a0)
		bpl.s	.nosound02				; branch if not on screen
		cmpi.b	#$18,d2
		bne.s	.nosound02
		play.w	1, jsr, sfx_Saw				; play saw sound at certain point

	.nosound02:
		rts	
; ===========================================================================

; Type 3
Saw_Ground_Right:
		getsonic					; a1 = OST of Sonic
		move.w	ost_x_pos(a1),d0
		subi.w	#192,d0
		bcs.s	.nosaw03x				; branch if Sonic is within 192px of left edge boundary
		sub.w	ost_x_pos(a0),d0
		bcs.s	.nosaw03x				; branch if saw is < 192px to Sonic's left
		range_y
		cmpi.w	#128,d3
		bcc.s	.nosaw03y				; branch if saw is > 128px above/below Sonic

		move.b	#id_Saw_Ground_Move,ost_subtype(a0)	; goto Saw_Ground_Move next
		move.w	#$600,ost_x_vel(a0)			; move object to the right
		play.w	1, jsr, sfx_Saw				; play saw sound

	.nosaw03x:
		addq.l	#4,sp					; don't display sprite

	.nosaw03y:
		rts
; ===========================================================================

; Type 4
Saw_Ground_Left:
		getsonic					; a1 = OST of Sonic
		move.w	ost_x_pos(a1),d0
		addi.w	#224,d0
		sub.w	ost_x_pos(a0),d0
		bcc.s	.nosaw04x				; branch if saw is > 224px right of Sonic 
		range_y
		cmpi.w	#128,d3
		bcc.s	.nosaw04y				; branch if saw is > 128px above/below Sonic

		move.b	#id_Saw_Ground_Move,ost_subtype(a0)	; goto Saw_Ground_Move next
		move.w	#-$600,ost_x_vel(a0)			; move object to the left
		play.w	1, jsr, sfx_Saw				; play saw sound

	.nosaw04x:
		addq.l	#4,sp					; don't display sprite

	.nosaw04y:
		rts	
; ===========================================================================

Saw_Ground_Move:
		update_x_pos					; update position
		move.w	ost_x_pos(a0),ost_saw_x_start(a0)
		subq.b	#1,ost_anim_time(a0)			; decrement frame timer
		bpl.s	.sameframe04				; branch if time remains
		move.b	#2,ost_anim_time(a0)			; reset timer
		bchg	#0,ost_frame(a0)			; change frame

	.sameframe04:
		rts	
