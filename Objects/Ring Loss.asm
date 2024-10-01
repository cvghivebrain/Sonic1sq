; ---------------------------------------------------------------------------
; Object 37 - rings flying out of Sonic	when he's hit

; spawned by:
;	HurtSonic - routine 0
;	RingLoss - routine 2
; ---------------------------------------------------------------------------

RingLoss:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	RLoss_Index(pc,d0.w),d1
		jmp	RLoss_Index(pc,d1.w)
; ===========================================================================
RLoss_Index:	index *,,2
		ptr RLoss_Count
		ptr RLoss_Bounce
		ptr RLoss_Collect
		ptr RLoss_Sparkle
		ptr RLoss_Delete
		
ringloss_width:	equ 8
ringloss_height:	equ 8

RLoss_VelTable:	dc.w   -$C4,  -$3EC,    $C4,  -$3EC,  -$238,  -$350,   $238,  -$350
		dc.w  -$350,  -$238,   $350,  -$238,  -$3EC,   -$C4,   $3EC,   -$C4
		dc.w  -$3EC,    $C4,   $3EC,    $C4,  -$350,   $238,   $350,   $238
		dc.w  -$238,   $350,   $238,   $350,   -$C4,   $3EC,    $C4,   $3EC
		dc.w   -$62,  -$1F6,    $62,  -$1F6,  -$11C,  -$1A8,   $11C,  -$1A8
		dc.w  -$1A8,  -$11C,   $1A8,  -$11C,  -$1F6,   -$62,   $1F6,   -$62
		dc.w  -$1F6,    $62,   $1F6,    $62,  -$1A8,   $11C,   $1A8,   $11C
		dc.w  -$11C,   $1A8,   $11C,   $1A8,   -$62,   $1F6,    $62,   $1F6
; ===========================================================================

RLoss_Count:	; Routine 0
		movea.l	a0,a1					; replace current object with first ring
		lea	RLoss_VelTable(pc),a2
		move.w	(v_rings).w,d5				; check number of rings you have
		moveq	#32,d0
		cmp.w	d0,d5					; do you have 32 or more?
		bcs.s	.belowmax				; if not, branch
		move.w	d0,d5					; if yes, set d5 to 32

	.belowmax:
		subq.w	#1,d5					; loops = rings-1
		bra.s	.makerings
; ===========================================================================

	.loop:
		bsr.w	FindFreeObj				; find free OST slot
		bne.w	.fail					; branch if not found

.makerings:
		move.l	#RingLoss,ost_id(a1)			; load bouncing ring object
		addq.b	#2,ost_routine(a1)			; goto RLoss_Bounce next
		move.b	#ringloss_height,ost_height(a1)
		move.b	#ringloss_width,ost_width(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.l	#Map_Ring,ost_mappings(a1)
		move.w	(v_tile_rings).w,ost_tile(a1)
		addi.w	#tile_pal2,ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.w	#priority_3,ost_priority(a1)
		move.b	#id_React_Ring,ost_col_type(a1)		; goto RLoss_Collect when touched
		move.b	#6,ost_col_width(a1)
		move.b	#6,ost_col_height(a1)
		move.b	#8,ost_displaywidth(a1)
		move.b	#StrId_RingLoss,ost_name(a1)
		move.b	#255,(v_syncani_3_time).w		; reset deletion/animation timer
		move.w	(a2)+,ost_x_vel(a1)
		move.w	(a2)+,ost_y_vel(a1)
		dbf	d5,.loop				; repeat for number of rings (max 31)

	.fail:
		move.w	#0,(v_rings).w				; reset number of rings to zero
		move.b	#$80,(v_hud_rings_update).w		; update ring counter
		move.b	#0,(v_ring_reward).w
		play_sound sfx_RingLoss				; play ring loss sound

RLoss_Bounce:	; Routine 2
		move.b	(v_syncani_3_frame).w,ost_frame(a0)	; set synchronised frame
		update_xy_fall	$18				; update position & apply gravity
		bmi.s	.chkdel					; branch if moving upwards

		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		add.b	d7,d0					; add OST index of current object (numbered $7F to 0)
		andi.b	#3,d0					; read only bits 0-1
		bne.s	.chkdel					; branch if either are set

		getpos_bottom ringloss_height			; d0 = x pos; d1 = y pos of bottom
		moveq	#1,d6
		jsr	FloorDist				; find floor every 4th frame
		tst.w	d5					; has ring hit the floor?
		bpl.s	.chkdel					; if not, branch
		add.w	d5,ost_y_pos(a0)			; align to floor
		move.w	ost_y_vel(a0),d0
		asr.w	#2,d0
		sub.w	d0,ost_y_vel(a0)			; reduce y speed by 25%
		neg.w	ost_y_vel(a0)				; invert y speed (bounce)

	.chkdel:
		tst.b	(v_syncani_3_time).w			; has animation finished?
		beq.w	DeleteObject				; if yes, branch
		move.w	(v_boundary_bottom).w,d0
		addi.w	#screen_height,d0
		cmp.w	ost_y_pos(a0),d0			; has object moved below level boundary?
		bcs.w	DeleteObject				; if yes, branch
		bra.w	DisplaySprite
; ===========================================================================

RLoss_Collect:	; Routine 4
		addq.b	#2,ost_routine(a0)			; goto RLoss_Sparkle next
		move.b	#0,ost_col_type(a0)
		move.w	#priority_1,ost_priority(a0)
		moveq	#1,d0
		bsr.w	CollectRing				; add ring/extra life, play sound

RLoss_Sparkle:	; Routine 6
		lea	Ani_Ring(pc),a1
		bsr.w	AnimateSprite				; animate and goto RLoss_Delete when finished
		bra.w	DisplaySprite
; ===========================================================================

RLoss_Delete:	; Routine 8
		bra.w	DeleteObject
