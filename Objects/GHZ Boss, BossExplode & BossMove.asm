; ---------------------------------------------------------------------------
; Object 3D - Eggman (GHZ)

; spawned by:
;	DynamicLevelEvents - routine 0
;	BossGreenHill - routines 2/4/6
; ---------------------------------------------------------------------------

BossGreenHill:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	BGHZ_Index(pc,d0.w),d1
		jmp	BGHZ_Index(pc,d1.w)
; ===========================================================================
BGHZ_Index:	index *,,2
		ptr BGHZ_Main
		ptr BGHZ_ShipMain
; ===========================================================================

BGHZ_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto BGHZ_ShipMain next
		move.l	#BossGreenHill,ost_id(a0)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.l	#Map_Bosses,ost_mappings(a0)
		move.w	#tile_Art_Eggman,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.b	#3,ost_priority(a0)
		move.b	#id_ani_boss_ship,ost_anim(a0)
		
		moveq	#id_UPLC_Boss,d0
		jsr	UncPLC
		
		jsr	(FindNextFreeObj).l			; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#Exhaust,ost_id(a1)
		move.w	#$400,ost_exhaust_escape(a1)		; set speed at which ship escapes
		move.l	a0,ost_exhaust_parent(a1)		; save address of OST of parent
		
		jsr	(FindNextFreeObj).l			; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#BossFace,ost_id(a1)
		move.w	#$400,ost_face_escape(a1)		; set speed at which ship escapes
		move.b	#id_BGHZ_Explode,ost_face_defeat(a1)	; boss defeat routine number
		move.l	a0,ost_face_parent(a1)			; save address of OST of parent

	.fail:
		move.w	ost_x_pos(a0),ost_boss_parent_x_pos(a0)
		move.w	ost_y_pos(a0),ost_boss_parent_y_pos(a0)
		move.b	#id_col_24x24,ost_col_type(a0)
		move.b	#hitcount_ghz,ost_col_property(a0)	; set number of hits to 8

BGHZ_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		move.w	BGHZ_ShipIndex(pc,d0.w),d1
		jsr	BGHZ_ShipIndex(pc,d1.w)
		lea	(Ani_Bosses).l,a1
		jsr	(AnimateSprite).l
		move.b	ost_status(a0),d0
		andi.b	#status_xflip+status_yflip,d0
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a0) ; ignore x/yflip bits
		or.b	d0,ost_render(a0)			; combine x/yflip bits from status instead
		jmp	(DisplaySprite).l
; ===========================================================================
BGHZ_ShipIndex:	index *,,2
		ptr BGHZ_ShipStart
		ptr BGHZ_MakeBall
		ptr BGHZ_ShipMove
		ptr BGHZ_ChgDir
		ptr BGHZ_Explode
		ptr BGHZ_Recover
		ptr BGHZ_Escape
; ===========================================================================

BGHZ_ShipStart:
		move.w	#$100,ost_y_vel(a0)			; move ship down
		bsr.w	BossMove				; update parent position
		cmpi.w	#$338,ost_boss_parent_y_pos(a0)		; has ship reached target position?
		bne.s	BGHZ_Update				; if not, branch
		move.w	#0,ost_y_vel(a0)			; stop ship
		addq.b	#2,ost_mode(a0)			; goto BGHZ_MakeBall next

BGHZ_Update:
		move.b	ost_boss_wobble(a0),d0			; get wobble byte
		jsr	(CalcSine).l				; convert to sine
		asr.w	#6,d0					; divide by 64
		add.w	ost_boss_parent_y_pos(a0),d0		; add y pos
		move.w	d0,ost_y_pos(a0)			; update actual y pos
		move.w	ost_boss_parent_x_pos(a0),ost_x_pos(a0)	; update actual x pos
		addq.b	#2,ost_boss_wobble(a0)			; increment wobble (wraps to 0 after $FE)
		cmpi.b	#id_BGHZ_Explode,ost_mode(a0)
		bcc.s	.exit
		tst.b	ost_status(a0)				; has boss been beaten?
		bmi.s	.beaten					; if yes, branch
		tst.b	ost_col_type(a0)			; is ship collision clear?
		bne.s	.exit					; if not, branch
		tst.b	ost_boss_flash_num(a0)			; is ship flashing?
		bne.s	.flash					; if yes, branch
		move.b	#$20,ost_boss_flash_num(a0)		; set ship to flash 32 times
		play.w	1, jsr, sfx_BossHit			; play boss damage sound

	.flash:
		lea	(v_pal_dry_line2+2).w,a1		; load 2nd palette, 2nd entry
		moveq	#0,d0					; move 0 (black) to d0
		tst.w	(a1)					; is colour white?
		bne.s	.is_white				; if yes, branch
		move.w	#cWhite,d0				; move $EEE (white) to d0

	.is_white:
		move.w	d0,(a1)					; load colour stored in	d0
		subq.b	#1,ost_boss_flash_num(a0)		; decrement flash counter
		bne.s	.exit					; branch if not 0
		move.b	#id_col_24x24,ost_col_type(a0)		; enable boss collision again

	.exit:
		rts	
; ===========================================================================

.beaten:
		moveq	#100,d0
		bsr.w	AddPoints				; give Sonic 1000 points
		move.b	#id_BGHZ_Explode,ost_mode(a0)
		move.w	#179,ost_boss_wait_time(a0)		; set timer to 3 seconds
		rts	

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
		jsr	(RandomNumber).l
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

; ===========================================================================


BGHZ_MakeBall:
		move.w	#-$100,ost_x_vel(a0)			; move ship left
		move.w	#-$40,ost_y_vel(a0)			; move ship upwards
		bsr.w	BossMove				; update parent position
		cmpi.w	#$2A00,ost_boss_parent_x_pos(a0)	; has ship reached target position?
		bne.s	.wait					; if not, branch
		move.w	#0,ost_x_vel(a0)			; stop ship
		move.w	#0,ost_y_vel(a0)
		addq.b	#2,ost_mode(a0)			; goto BGHZ_ShipMove next
		jsr	(FindNextFreeObj).l			; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#BossBall,ost_id(a1)			; load swinging ball object
		move.w	ost_boss_parent_x_pos(a0),ost_x_pos(a1)
		move.w	ost_boss_parent_y_pos(a0),ost_y_pos(a1)
		jsr	SaveParent

	.fail:
		move.w	#119,ost_boss_wait_time(a0)		; set wait time to 2 seconds
		move.b	#1,ost_boss_attack(a0)

	.wait:
		bra.w	BGHZ_Update				; update actual position, check for hits
; ===========================================================================

BGHZ_ShipMove:
		subq.w	#1,ost_boss_wait_time(a0)		; decrement timer
		bpl.s	.wait					; branch if time remains
		move.b	#0,ost_boss_attack(a0)
		addq.b	#2,ost_mode(a0)			; goto BGHZ_ChgDir next
		move.w	#63,ost_boss_wait_time(a0)		; set wait time to 1 second
		move.w	#$100,ost_x_vel(a0)			; set speed
		cmpi.w	#$2A00,ost_boss_parent_x_pos(a0)	; has ship moved after ball was spawned?
		bne.s	.wait					; if yes, branch
		move.w	#127,ost_boss_wait_time(a0)		; set timer to 2 seconds
		move.w	#$40,ost_x_vel(a0)			; set initial speed as slower

	.wait:
		btst	#status_xflip_bit,ost_status(a0)	; is ship facing left?
		bne.s	.face_right				; if not, branch
		neg.w	ost_x_vel(a0)				; go left instead

	.face_right:
		bra.w	BGHZ_Update				; update actual position, check for hits
; ===========================================================================

BGHZ_ChgDir:
		subq.w	#1,ost_boss_wait_time(a0)		; decrement timer
		bmi.s	.chg_dir				; branch if below 0
		bsr.w	BossMove				; update parent position
		bra.s	.update_pos
; ===========================================================================

.chg_dir:
		bchg	#status_xflip_bit,ost_status(a0)	; change direction
		move.w	#63,ost_boss_wait_time(a0)		; set wait time
		subq.b	#2,ost_mode(a0)			; goto BGHZ_ShipMove next
		move.w	#0,ost_x_vel(a0)			; stop moving

.update_pos:
		bra.w	BGHZ_Update				; update actual position, check for hits
; ===========================================================================

BGHZ_Explode:
		subq.w	#1,ost_boss_wait_time(a0)		; decrement timer
		bmi.s	.stop_exploding				; branch if below 0
		bra.w	BossExplode				; load explosion object
; ===========================================================================

.stop_exploding:
		bset	#status_xflip_bit,ost_status(a0)	; ship face right
		bclr	#status_broken_bit,ost_status(a0)
		clr.w	ost_x_vel(a0)				; stop moving
		addq.b	#2,ost_mode(a0)			; goto BGHZ_Recover next
		move.w	#-38,ost_boss_wait_time(a0)		; set timer (counts up)
		tst.b	(v_boss_status).w
		bne.s	.exit
		move.b	#1,(v_boss_status).w			; set boss beaten flag

	.exit:
		rts	
; ===========================================================================

BGHZ_Recover:
		addq.w	#1,ost_boss_wait_time(a0)		; increment timer
		beq.s	.stop_falling				; branch if 0
		bpl.s	.ship_recovers				; branch if 1 or more
		addi.w	#$18,ost_y_vel(a0)			; apply gravity (falls)
		bra.s	.update
; ===========================================================================

.stop_falling:
		clr.w	ost_y_vel(a0)				; stop falling
		bra.s	.update
; ===========================================================================

.ship_recovers:
		cmpi.w	#$30,ost_boss_wait_time(a0)		; have 48 frames passed since ship stopped falling?
		bcs.s	.ship_rises				; if not, branch
		beq.s	.stop_rising				; if exactly 48, branch
		cmpi.w	#$38,ost_boss_wait_time(a0)		; have 56 frames passed since ship stopped rising?
		bcs.s	.update					; if not, branch
		addq.b	#2,ost_mode(a0)			; if yes, goto BGHZ_Escape next
		bra.s	.update
; ===========================================================================

.ship_rises:
		subq.w	#8,ost_y_vel(a0)			; move ship upwards
		bra.s	.update
; ===========================================================================

.stop_rising:
		clr.w	ost_y_vel(a0)				; stop ship rising
		play.w	0, jsr, mus_GHZ				; play GHZ music

.update:
		bsr.w	BossMove				; update parent position
		bra.w	BGHZ_Update				; update actual position, check for hits
; ===========================================================================

BGHZ_Escape:
		move.w	#$400,ost_x_vel(a0)			; move ship right
		move.w	#-$40,ost_y_vel(a0)			; move ship upwards
		cmpi.w	#$2AC0,(v_boundary_right).w		; check for new boundary
		beq.s	.chkdel
		addq.w	#2,(v_boundary_right).w			; expand right edge of level boundary
		bra.s	.update
; ===========================================================================

.chkdel:
		tst.b	ost_render(a0)				; is ship on-screen?
		bpl.s	.delete					; if not, branch

.update:
		bsr.w	BossMove				; update parent position
		bra.w	BGHZ_Update				; update actual position, check for hits
; ===========================================================================

.delete:
		addq.l	#4,sp
		jmp	(DeleteObject).l
