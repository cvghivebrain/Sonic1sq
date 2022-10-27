; ---------------------------------------------------------------------------
; Boss exhaust flame

; spawned by:
;	BossGreenHill, BossMarble, BossSpringYard
;	BossLabyrinth, BossStarLight, BossFinal
; ---------------------------------------------------------------------------

Exhaust:
		movea.l	ost_exhaust_parent(a0),a3		; get OST of parent
		tst.w	ost_x_vel(a3)
		beq.s	.exit					; branch if ship isn't moving
		
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Exhaust_Index(pc,d0.w),d1
		jsr	Exhaust_Index(pc,d1.w)
		lea	(Ani_Exhaust).l,a1
		jsr	AnimateSprite
		set_dma_dest vram_exhaust,d1			; set VRAM address to write gfx
		jsr	DPLCSprite				; write gfx if frame has changed
		tst.l	ost_id(a3)
		beq.s	.delete					; branch if parent has been deleted
		
		move.w	ost_x_pos(a3),ost_x_pos(a0)
		move.w	ost_y_pos(a3),ost_y_pos(a0)
		move.b	ost_status(a3),ost_status(a0)
		move.b	ost_status(a0),d0
		andi.b	#status_xflip+status_yflip,d0
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a0) ; ignore x/yflip bits
		or.b	d0,ost_render(a0)			; combine x/yflip bits from status instead
		jmp	DisplaySprite
		
	.exit:
		rts
		
	.delete:
		jmp	DeleteObject
; ===========================================================================
Exhaust_Index:	index *,,2
		ptr Exhaust_Main
		ptr Exhaust_Chk
		ptr Exhaust_Big

		rsobj Exhaust
ost_exhaust_parent:	rs.l 1					; address of OST of parent
ost_exhaust_escape:	rs.w 1					; escape speed of ship
		rsobjend
; ===========================================================================

Exhaust_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Exhaust_Chk next
		move.l	#Map_Exhaust,ost_mappings(a0)
		move.w	#vram_exhaust/sizeof_cell,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.b	#3,ost_priority(a0)
		move.b	#id_ani_exhaust_flame1,ost_anim(a0)
		
Exhaust_Chk:	; Routine 2
		move.w	ost_exhaust_escape(a0),d0
		cmp.w	ost_x_vel(a3),d0
		bgt.s	.exit					; branch if ship is moving slowly
		move.b	#id_ani_exhaust_bigflame,ost_anim(a0)	; use large flame when ship escapes
		addq.b	#2,ost_routine(a0)			; goto Exhaust_Big next
		
	.exit:
		rts
		
Exhaust_Big:	; Routine 4
		move.w	ost_exhaust_escape(a0),d0
		cmp.w	ost_x_vel(a3),d0
		bls.s	.exit					; branch if ship is moving fast
		move.b	#id_ani_exhaust_flame1,ost_anim(a0)	; use small flame otherwise
		subq.b	#2,ost_routine(a0)			; goto Exhaust_Chk next
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Animation script - Exhaust flame
; ---------------------------------------------------------------------------

Ani_Exhaust:	index *
		ptr ani_exhaust_flame1
		ptr ani_exhaust_bigflame
		
ani_exhaust_flame1:
		dc.w 3
		dc.w id_frame_exhaust_flame1
		dc.w id_frame_exhaust_flame2
		dc.w id_Anim_Flag_Restart
		even

ani_exhaust_bigflame:
		dc.w 2
		dc.w id_frame_exhaust_flame2
		dc.w id_frame_exhaust_flame1
		dc.w id_frame_exhaust_bigflame1
		dc.w id_frame_exhaust_bigflame2
		dc.w id_frame_exhaust_bigflame1
		dc.w id_frame_exhaust_bigflame2
		dc.w id_frame_exhaust_flame2
		dc.w id_frame_exhaust_flame1
		dc.w id_Anim_Flag_Back, 2
		even
		