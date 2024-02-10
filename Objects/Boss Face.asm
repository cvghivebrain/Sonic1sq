; ---------------------------------------------------------------------------
; Boss face

; spawned by:
;	BossGreenHill, BossMarble, BossSpringYard
;	BossLabyrinth, BossStarLight, BossFinal
; ---------------------------------------------------------------------------

BossFace:
		movea.l	ost_face_parent(a0),a3			; get OST of parent

		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Face_Index(pc,d0.w),d1
		jsr	Face_Index(pc,d1.w)
		lea	Ani_Face(pc),a1
		jsr	AnimateSprite
		set_dma_dest vram_face,d1			; set VRAM address to write gfx
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

	.delete:
		jmp	DeleteObject
; ===========================================================================
Face_Index:	index *,,2
		ptr Face_Main
		ptr Face_Chk
		ptr Face_Hit
		ptr Face_Attack
		ptr Face_Laugh
		ptr Face_Defeat
		ptr Face_Panic
		ptr Face_Lift

		rsobj BossFace
ost_face_parent:	rs.l 1					; address of OST of parent
ost_face_escape:	rs.w 1					; escape speed of ship
ost_face_defeat:	rs.b 1					; routine number that boss is defeated on
		rsobjend
; ===========================================================================

Face_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Exhaust_Chk next
		move.l	#Map_Face,ost_mappings(a0)
		move.w	#vram_face/sizeof_cell,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.b	#priority_3,ost_priority(a0)
		move.b	#id_ani_face_face1,ost_anim(a0)		; use default animation

Face_Chk:	; Routine 2
		tst.b	ost_boss_flash_num(a3)
		bne.s	Face_Goto_Hit				; branch if boss is flashing
		tst.b	ost_boss_attack(a3)
		bne.s	Face_Goto_Attack			; branch if boss is attacking
		cmpi.b	#id_Sonic_Hurt,(v_ost_player+ost_routine).w
		bcc.s	Face_Goto_Laugh				; branch if Sonic is hurt or dead
		move.w	ost_face_escape(a0),d0
		cmp.w	ost_x_vel(a3),d0
		beq.s	Face_Goto_Panic				; branch if ship is escaping
		move.b	ost_face_defeat(a0),d0
		beq.s	.exit					; branch if no defeat routine is specified
		cmp.b	ost_mode(a3),d0
		bls.s	Face_Goto_Defeat			; branch if boss is on specified routine
		cmpi.b	#2,ost_subtype(a3)
		beq.s	Face_Goto_Lift				; branch if boss is lifting a block (SYZ only)

	.exit:
		rts

Face_Goto_Hit:
		move.b	#id_ani_face_hit,ost_anim(a0)		; use hit animation
		move.b	#id_Face_Hit,ost_routine(a0)		; goto Face_Hit next
		rts

Face_Goto_Default:
		move.b	#id_ani_face_face1,ost_anim(a0)		; use default animation
		move.b	#id_Face_Chk,ost_routine(a0)		; goto Face_Chk next
		rts

Face_Goto_Attack:
		move.b	#id_ani_face_laugh,ost_anim(a0)
		move.b	#id_Face_Attack,ost_routine(a0)		; goto Face_Attack next
		rts

Face_Goto_Laugh:
		move.b	#id_ani_face_laugh,ost_anim(a0)
		move.b	#id_Face_Laugh,ost_routine(a0)		; goto Face_Laugh next
		rts

Face_Goto_Panic:
		move.b	#id_ani_face_panic,ost_anim(a0)
		move.b	#id_Face_Panic,ost_routine(a0)		; goto Face_Panic next
		rts

Face_Goto_Lift:
		move.b	#id_ani_face_panic,ost_anim(a0)
		move.b	#id_Face_Lift,ost_routine(a0)		; goto Face_Lift next
		rts

Face_Goto_Defeat:
		move.b	#id_ani_face_defeat,ost_anim(a0)
		move.b	#id_Face_Defeat,ost_routine(a0)		; goto Face_Defeat next
		rts

Face_Hit:	; Routine
		tst.b	ost_boss_flash_num(a3)
		beq.s	Face_Goto_Default			; branch if boss isn't flashing
		rts

Face_Attack:	; Routine
		tst.b	ost_boss_attack(a3)
		beq.s	Face_Goto_Default			; branch if boss isn't attacking
		rts

Face_Laugh:	; Routine
		cmpi.b	#id_Sonic_Hurt,(v_ost_player+ost_routine).w
		bcs.s	Face_Goto_Default			; branch if Sonic isn't hurt or dead
		rts

Face_Defeat:	; Routine
		move.w	ost_face_escape(a0),d0
		cmp.w	ost_x_vel(a3),d0
		beq.s	Face_Goto_Panic				; branch if ship is escaping
		rts

Face_Panic:	; Routine
		rts

Face_Lift:	; Routine
		tst.b	ost_boss_flash_num(a3)
		bne.w	Face_Goto_Hit				; branch if boss is flashing
		cmpi.b	#2,ost_subtype(a3)
		bne.w	Face_Goto_Default			; branch if boss isn't lifting a block
		rts

; ---------------------------------------------------------------------------
; Animation script - Boss face
; ---------------------------------------------------------------------------

Ani_Face:	index *
		ptr ani_face_face1
		ptr ani_face_laugh
		ptr ani_face_hit
		ptr ani_face_panic
		ptr ani_face_defeat

ani_face_face1:
		dc.w 5
		dc.w id_frame_face_face1
		dc.w id_frame_face_face2
		dc.w id_Anim_Flag_Restart

ani_face_laugh:
		dc.w 4
		dc.w id_frame_face_laugh1
		dc.w id_frame_face_laugh2
		dc.w id_Anim_Flag_Restart

ani_face_hit:
		dc.w $1F
		dc.w id_frame_face_hit
		dc.w id_frame_face_face1
		dc.w id_Anim_Flag_Restart

ani_face_panic:
		dc.w 3
		dc.w id_frame_face_panic
		dc.w id_frame_face_face1
		dc.w id_Anim_Flag_Restart

ani_face_defeat:
		dc.w $7F
		dc.w id_frame_face_defeat
		dc.w id_Anim_Flag_Restart

