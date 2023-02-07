; ---------------------------------------------------------------------------
; Object 51 - smashable	green block (MZ)

; spawned by:
;	ObjPos_MZ2, ObjPos_MZ3
; ---------------------------------------------------------------------------

SmashBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Smab_Index(pc,d0.w),d1
		jmp	Smab_Index(pc,d1.w)
; ===========================================================================
Smab_Index:	index *,,2
		ptr Smab_Main
		ptr Smab_Solid
; ===========================================================================

Smab_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Smab_Solid next
		move.l	#Map_Smab,ost_mappings(a0)
		move.w	#tile_Kos_MzBlock+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#$10,ost_width(a0)
		move.b	#$10,ost_height(a0)
		move.b	#4,ost_priority(a0)
		move.b	ost_subtype(a0),ost_frame(a0)

Smab_Solid:	; Routine 2
		pushr.w	(v_enemy_combo).w
		bsr.w	SolidNew
		popr.w	(v_enemy_combo).w			; don't reset combo counter on collision
		andi.b	#1,d1
		beq.w	.dont_break				; branch if no collision with top
		cmpi.b	#4,ost_solid(a0)
		bne.w	.dont_break				; branch if Sonic wasn't rolling/jumping
		bset	#status_jump_bit,ost_status(a1)
		move.b	(v_player1_height_roll).w,ost_height(a1)
		move.b	(v_player1_width_roll).w,ost_width(a1)
		move.b	#id_Roll,ost_anim(a1)			; make Sonic roll
		move.w	#-$300,ost_y_vel(a1)			; rebound Sonic
		bset	#status_air_bit,ost_status(a1)
		bclr	#status_platform_bit,ost_status(a1)
		move.b	#id_Sonic_Control,ost_routine(a1)
		bclr	#status_platform_bit,ost_status(a0)
		clr.b	ost_solid(a0)
		bsr.s	Smab_Points				; load points object
		move.b	#id_frame_smash_four,ost_frame(a0)	; use sprite consisting of four pieces
		lea	Smab_Speeds(pc),a4
		move.w	#$38,d2
		bsr.w	Shatter

	.dont_break:
		bra.w	DespawnObject
		
Smab_Speeds:	dc.w -$200, -$200				; x speed, y speed
		dc.w -$100, -$100
		dc.w $200, -$200
		dc.w $100, -$100
; ===========================================================================

Smab_Points:
		bsr.w	FindFreeObj
		bne.s	.fail
		move.l	#Points,ost_id(a1)			; load points object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	(v_enemy_combo).w,d2
		addq.w	#2,(v_enemy_combo).w			; increment bonus counter
		cmpi.w	#30,d2
		bcs.s	.not_16					; branch if 0-15
		moveq	#10,d2					; 10k points
		bra.s	.bonus_ok
	.not_16:
		cmpi.w	#6,d2
		bls.s	.bonus_ok				; branch if bonus is at or below max
		moveq	#6,d2					; max bonus
	.bonus_ok:
		moveq	#0,d0
		move.w	Smab_PointList(pc,d2.w),d0		; get points amount from list
		jsr	(AddPoints).l				; give points
		lsr.w	#1,d2
		move.b	d2,ost_frame(a1)
		
	.fail:
		rts

Smab_PointList:	dc.w 100/10					; 100 (block 1)
		dc.w 200/10					; 200 (block 2)
		dc.w 500/10					; 500 (block 3)
		dc.w 1000/10					; 1000 (blocks 4-15)
		dc.w 1000/10					; 1000
		dc.w 10000/10					; 10000 (blocks 16+)
