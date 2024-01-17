; ---------------------------------------------------------------------------
; Object 38 - Shield

; spawned by:
;	PowerUp
; ---------------------------------------------------------------------------

ShieldItem:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Shi_Index(pc,d0.w),d1
		jmp	Shi_Index(pc,d1.w)
; ===========================================================================
Shi_Index:	index *,,2
		ptr Shi_Main
		ptr Shi_Shield
; ===========================================================================

Shi_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Shi_Shield next
		move.l	#Map_Shield,ost_mappings(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_1,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.w	#vram_shield/sizeof_cell,ost_tile(a0)
		move.b	#id_ani_shield_0,ost_anim(a0)

Shi_Shield:	; Routine 2
		shortcut
		tst.w	(v_invincibility).w			; does Sonic have invincibility?
		bne.s	.hide					; if yes, branch
		tst.b	(v_shield).w				; does Sonic have shield?
		beq.w	DeleteObject				; if not, branch

		getsonic					; a1 = OST of Sonic
		move.w	ost_x_pos(a1),ost_x_pos(a0)		; match Sonic's position & orientation
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		move.b	ost_status(a1),ost_status(a0)
		lea	Ani_Shield(pc),a1
		jsr	AnimateSprite
		set_dma_dest vram_shield,d1			; set VRAM address to write gfx
		jsr	DPLCSprite				; write gfx if frame has changed
		bra.w	DisplaySprite

	.hide:
		rts
		
; ---------------------------------------------------------------------------
; Invincibility stars

; spawned by:
;	PowerUp
; ---------------------------------------------------------------------------

InvincibilityItem:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Inv_Index(pc,d0.w),d1
		jmp	Inv_Index(pc,d1.w)
; ===========================================================================
Inv_Index:	index *,,2
		ptr Inv_Main
		ptr Inv_Stars

		rsobj InvincibilityItem
ost_invincibility_last_pos:	rs.b 1				; previous position in tracking index, for invincibility trail
		rsobjend
		
Inv_Offsets:	dc.b 4, 24+4, 48+4, 72+4
; ===========================================================================

Inv_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Inv_Stars next
		move.l	#Map_Shield,ost_mappings(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_1,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.w	#vram_shield/sizeof_cell,ost_tile(a0)
		moveq	#0,d0
		move.b	ost_anim(a0),d0				; get animation id (0 to 3)
		move.b	Inv_Offsets(pc,d0.w),ost_subtype(a0)

Inv_Stars:	; Routine 2
		shortcut
		tst.w	(v_invincibility).w			; does Sonic have invincibility?
		beq.w	DeleteObject				; if not, branch
		move.w	(v_sonic_pos_tracker_num).w,d0		; get current index value for position tracking data
		move.b	ost_subtype(a0),d1			; get tracking offset
		sub.b	d1,d0					; subtract from tracker
		move.b	ost_invincibility_last_pos(a0),d1	; retrieve previous index
		sub.b	d1,d0					; subtract from tracker
		addq.b	#4,d1					; increment tracking index
		cmpi.b	#$18,d1
		bcs.s	.is_valid				; branch if valid (0-23)
		moveq	#0,d1					; reset to 0

	.is_valid:
		move.b	d1,ost_invincibility_last_pos(a0)	; set new tracking index value
		lea	(v_sonic_pos_tracker).w,a1		; position data
		lea	(a1,d0.w),a1				; jump to relevant position data
		move.w	(a1)+,ost_x_pos(a0)			; update position of stars
		move.w	(a1)+,ost_y_pos(a0)
		move.b	(v_ost_player+ost_status).w,ost_status(a0)
		lea	Ani_Shield(pc),a1
		jsr	AnimateSprite
		bra.w	DisplaySprite

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Shield:	index *
		ptr ani_stars1
		ptr ani_stars2
		ptr ani_stars3
		ptr ani_stars4
		ptr ani_shield_0
		
ani_shield_0:	dc.w 1
		dc.w id_frame_shield_1
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_2
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_3
		dc.w id_frame_shield_blank
		dc.w id_Anim_Flag_Restart

ani_stars1:	dc.w 5
		dc.w id_frame_stars1
		dc.w id_frame_stars2
		dc.w id_frame_stars3
		dc.w id_frame_stars4
		dc.w id_Anim_Flag_Restart

ani_stars2:	dc.w 0
		dc.w id_frame_stars1
		dc.w id_frame_stars1
		dc.w id_frame_shield_blank
		dc.w id_frame_stars1
		dc.w id_frame_stars1
		dc.w id_frame_shield_blank
		dc.w id_frame_stars2
		dc.w id_frame_stars2
		dc.w id_frame_shield_blank
		dc.w id_frame_stars2
		dc.w id_frame_stars2
		dc.w id_frame_shield_blank
		dc.w id_frame_stars3
		dc.w id_frame_stars3
		dc.w id_frame_shield_blank
		dc.w id_frame_stars3
		dc.w id_frame_stars3
		dc.w id_frame_shield_blank
		dc.w id_frame_stars4
		dc.w id_frame_stars4
		dc.w id_frame_shield_blank
		dc.w id_frame_stars4
		dc.w id_frame_stars4
		dc.w id_frame_shield_blank
		dc.w id_Anim_Flag_Restart

ani_stars3:	dc.w 0
		dc.w id_frame_stars1
		dc.w id_frame_stars1
		dc.w id_frame_shield_blank
		dc.w id_frame_stars1
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_frame_stars2
		dc.w id_frame_stars2
		dc.w id_frame_shield_blank
		dc.w id_frame_stars2
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_frame_stars3
		dc.w id_frame_stars3
		dc.w id_frame_shield_blank
		dc.w id_frame_stars3
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_frame_stars4
		dc.w id_frame_stars4
		dc.w id_frame_shield_blank
		dc.w id_frame_stars4
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_Anim_Flag_Restart

ani_stars4:	dc.w 0
		dc.w id_frame_stars1
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_frame_stars1
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_frame_stars2
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_frame_stars2
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_frame_stars3
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_frame_stars3
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_frame_stars4
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_frame_stars4
		dc.w id_frame_shield_blank
		dc.w id_frame_shield_blank
		dc.w id_Anim_Flag_Restart
