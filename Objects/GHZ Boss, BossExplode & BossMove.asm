; ---------------------------------------------------------------------------
; Subroutine to load explosions when a boss is beaten
; ---------------------------------------------------------------------------

BossExplode:
		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		andi.b	#7,d0					; read bits 0-2
		bne.s	.fail					; branch if any are set
		jsr	(FindFreeObj).l				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#ExplosionBomb,ost_id(a1)		; load explosion object every 8th frame
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		jsr	(RandomNumber).w
		move.w	d0,d1
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,ost_x_pos(a1)			; randomise position
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,ost_y_pos(a1)

	.fail:
		rts

; ---------------------------------------------------------------------------
; Subroutine to	translate a boss's speed to position
; ---------------------------------------------------------------------------

BossMove:
		move.l	ost_boss_parent_x_pos(a0),d2
		move.l	ost_boss_parent_y_pos(a0),d3
		move.w	ost_x_vel(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	ost_y_vel(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,ost_boss_parent_x_pos(a0)
		move.l	d3,ost_boss_parent_y_pos(a0)
		rts
