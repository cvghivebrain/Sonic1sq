; ---------------------------------------------------------------------------
; Boss weapons

; spawned by:
;	BossMarble, BossSpringYard, BossStarLight
; ---------------------------------------------------------------------------

BossWeapon:
		movea.l	ost_weapon_parent(a0),a3		; get OST of parent
		
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Weapon_Index(pc,d0.w),d1
		jsr	Weapon_Index(pc,d1.w)
		tst.l	ost_id(a3)
		beq.s	.delete					; branch if parent has been deleted
		
		move.w	ost_x_pos(a3),ost_x_pos(a0)
		move.w	ost_y_pos(a3),ost_y_pos(a0)
		move.w	ost_weapon_y_diff(a0),d0
		beq.s	.no_y_diff				; branch if y diff is 0
		asr.w	#2,d0
		add.w	d0,ost_y_pos(a0)			; extend or retract
		
	.no_y_diff:
		move.b	ost_status(a3),ost_status(a0)
		move.b	ost_status(a0),d0
		andi.b	#status_xflip+status_yflip,d0
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a0) ; ignore x/yflip bits
		or.b	d0,ost_render(a0)			; combine x/yflip bits from status instead
		jmp	DisplaySprite
		
	.delete:
		jmp	DeleteObject
; ===========================================================================
Weapon_Index:	index *,,2
		ptr Weapon_Main
		ptr Weapon_Done
		ptr Weapon_Spike

		rsobj BossWeapon
ost_weapon_parent:	rs.l 1					; address of OST of parent
ost_weapon_y_diff:	rs.w 1					; value to add to y pos
		rsobjend

Weapon_Data:	dc.b id_frame_boss_pipe,3,id_Weapon_Done,id_UPLC_MZPipe
		dc.b id_frame_boss_widepipe,3,id_Weapon_Done,id_UPLC_SLZPipe
		dc.b id_frame_boss_spike,5,id_Weapon_Spike,id_UPLC_SYZSpike
		even
; ===========================================================================

Weapon_Main:	; Routine 0
		move.l	#Map_BossItems,ost_mappings(a0)
		move.w	#(vram_weapon/sizeof_cell)+tile_pal2,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$20,ost_displaywidth(a0)
		
		lea	Weapon_Data(pc),a1
		move.b	ost_subtype(a0),d0
		lsl.w	#2,d0					; multiply d0 by 4
		adda.l	d0,a1
		move.b	(a1)+,d0
		move.b	d0,ost_frame(a0)			; set mappings frame
		move.b	(a1)+,d0
		move.b	d0,ost_priority(a0)			; set priority
		move.b	(a1)+,d0
		move.b	d0,ost_routine(a0)			; set routine number
		move.b	(a1)+,d0
		jsr	UncPLC					; load gfx
		
Weapon_Done:	; Routine 2
		rts
		
Weapon_Spike:	; Routine 4
		cmpi.b	#id_BSYZ_Attack,ost_mode(a3)
		bne.s	.exit					; branch if boss isn't attacking
		cmpi.b	#id_BSYZ_BreakBlock,ost_subtype(a3)
		beq.s	.retract				; branch if boss is breaking block
		cmp.w	#$94,ost_weapon_y_diff(a0)
		bge.s	.exit					; branch if spike is fully extended
		add.w	#7,ost_weapon_y_diff(a0)
		move.b	#id_col_4x16+id_col_hurt,ost_col_type(a0) ; make spike harmful
		
	.exit:
		rts
		
	.retract:
		tst.w	ost_boss_wait_time(a3)
		bpl.s	.exit					; branch if boss is shaking
		tst.w	ost_weapon_y_diff(a0)
		bmi.s	.gone					; branch if spike is fully retracted
		sub.w	#5,ost_weapon_y_diff(a0)
		rts
		
	.gone:
		clr.b	ost_col_type(a0)			; make spike harmless
		rts
		