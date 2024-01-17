; ---------------------------------------------------------------------------
; Object 77 - Eggman (LZ)

; spawned by:
;	DynamicLevelEvents - routine 0
;	BossLabyrinth - routines 2/4/6
; ---------------------------------------------------------------------------

BossLabyrinth:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	BLZ_Index(pc,d0.w),d1
		jmp	BLZ_Index(pc,d1.w)
; ===========================================================================
BLZ_Index:	index *,,2
		ptr BLZ_Main
		ptr BLZ_ShipMain
; ===========================================================================

BLZ_Main:	; Routine 0
		move.w	#$1E10,ost_x_pos(a0)
		move.w	#$5C0,ost_y_pos(a0)
		move.w	ost_x_pos(a0),ost_boss_parent_x_pos(a0)
		move.w	ost_y_pos(a0),ost_boss_parent_y_pos(a0)
		move.b	#id_React_Boss,ost_col_type(a0)
		move.b	#24,ost_col_width(a0)
		move.b	#24,ost_col_height(a0)
		move.b	#hitcount_lz,ost_col_property(a0)	; set number of hits to 8
		move.b	#priority_4,ost_priority(a0)
		bclr	#status_xflip_bit,ost_status(a0)
		clr.b	ost_mode(a0)
		move.b	#id_BLZ_ShipMain,ost_routine(a0)	; goto BLZ_ShipMain
		move.b	#id_ani_boss_ship,ost_anim(a0)
		move.l	#Map_Bosses,ost_mappings(a0)
		move.w	#tile_Art_Eggman,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$20,ost_displaywidth(a0)
		
		moveq	#id_UPLC_Boss,d0
		jsr	UncPLC
		
		jsr	(FindNextFreeObj).l			; find free OST slot
		bne.s	BLZ_ShipMain				; branch if not found
		move.l	#Exhaust,ost_id(a1)
		move.w	#$400,ost_exhaust_escape(a1)		; set speed at which ship escapes
		move.l	a0,ost_exhaust_parent(a1)		; save address of OST of parent
		
		jsr	(FindNextFreeObj).l			; find free OST slot
		bne.s	BLZ_ShipMain				; branch if not found
		move.l	#BossFace,ost_id(a1)
		move.w	#$400,ost_face_escape(a1)		; set speed at which ship escapes
		move.l	a0,ost_face_parent(a1)			; save address of OST of parent

BLZ_ShipMain:	; Routine 2
		lea	(v_ost_player).w,a1
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		move.w	BLZ_ShipIndex(pc,d0.w),d1
		jsr	BLZ_ShipIndex(pc,d1.w)
		lea	Ani_Bosses(pc),a1
		jsr	(AnimateSprite).l
		moveq	#status_xflip+status_yflip,d0
		and.b	ost_status(a0),d0
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a0) ; ignore x/yflip bits
		or.b	d0,ost_render(a0)			; combine x/yflip bits from status instead
		jmp	(DisplaySprite).l
; ===========================================================================
BLZ_ShipIndex:	index *,,2
		ptr BLZ_ShipStart
		ptr BLZ_ShipMove1
		ptr BLZ_ShipMove2
		ptr BLZ_ShipMove3
		ptr BLZ_ShipAtTop
		ptr BLZ_ShipWait
		ptr BLZ_Escape1
		ptr BLZ_Escape2
; ===========================================================================

BLZ_ShipStart:
		move.w	ost_x_pos(a1),d0
		cmpi.w	#$1DA0,d0				; has Sonic passed $1DA0 on x axis?
		bcs.s	BLZ_Update				; if not, branch
		move.w	#-$180,ost_y_vel(a0)			; move ship up
		move.w	#$60,ost_x_vel(a0)			; move ship right
		addq.b	#2,ost_mode(a0)				; goto BLZ_ShipMove1 next

BLZ_Update:
		bsr.w	BossMove				; update parent position
		move.w	ost_boss_parent_y_pos(a0),ost_y_pos(a0)	; update actual position
		move.w	ost_boss_parent_x_pos(a0),ost_x_pos(a0)

BLZ_Update_SkipPos:
		tst.b	ost_boss_mode(a0)			; has boss been beaten? (and points received)
		bne.s	.explode				; if yes, branch
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
		move.b	#id_React_Boss,ost_col_type(a0)		; enable boss collision again

	.exit:
		rts	
; ===========================================================================

.explode:
		bra.w	BossExplode
; ===========================================================================

.beaten:
		moveq	#100,d0
		bsr.w	AddPoints				; give Sonic 1000 points
		move.b	#1,ost_boss_mode(a0)			; set beaten flag
		rts	
; ===========================================================================

BLZ_ShipMove1:
		moveq	#-2,d0
		cmpi.w	#$1E48,ost_boss_parent_x_pos(a0)	; has ship reached x pos?
		bcs.s	.continue_right				; if not, branch
		move.w	#$1E48,ost_boss_parent_x_pos(a0)	; align to x pos
		clr.w	ost_x_vel(a0)				; stop moving right
		addq.w	#1,d0

	.continue_right:
		cmpi.w	#$500,ost_boss_parent_y_pos(a0)		; has ship reached y pos?
		bgt.s	.continue_up				; if not, branch
		move.w	#$500,ost_boss_parent_y_pos(a0)		; align to y pos
		clr.w	ost_y_vel(a0)				; stop moving up
		addq.w	#1,d0

	.continue_up:
		bne.s	.continue				; branch if ship is still moving

		move.w	#$140,ost_x_vel(a0)			; move ship right
		move.w	#-$200,ost_y_vel(a0)			; move ship up
		addq.b	#2,ost_mode(a0)				; goto BLZ_ShipMove2 next

	.continue:
		bra.w	BLZ_Update				; update position, check for hit
; ===========================================================================

BLZ_ShipMove2:
		moveq	#-2,d0
		cmpi.w	#$1E70,ost_boss_parent_x_pos(a0)
		bcs.s	.continue_right
		move.w	#$1E70,ost_boss_parent_x_pos(a0)
		clr.w	ost_x_vel(a0)
		addq.w	#1,d0

	.continue_right:
		cmpi.w	#$4C0,ost_boss_parent_y_pos(a0)
		bgt.s	.continue_up
		move.w	#$4C0,ost_boss_parent_y_pos(a0)
		clr.w	ost_y_vel(a0)
		addq.w	#1,d0

	.continue_up:
		bne.s	.continue				; branch if ship is still moving

		move.w	#-$180,ost_y_vel(a0)			; move ship up
		addq.b	#2,ost_mode(a0)				; goto BLZ_ShipMove3 next
		clr.b	ost_boss_wobble(a0)

	.continue:
		bra.w	BLZ_Update				; update position, check for hit
; ===========================================================================

BLZ_ShipMove3:
		cmpi.w	#$100,ost_boss_parent_y_pos(a0)		; has ship reached y pos?
		bgt.s	BLZ_ShipWobble				; if not, branch
		move.w	#$100,ost_boss_parent_y_pos(a0)		; align to y pos
		move.w	#$140,ost_x_vel(a0)			; move ship right
		move.w	#-$80,ost_y_vel(a0)			; move ship up
		tst.b	ost_boss_mode(a0)			; has boss been beaten?
		beq.s	.not_beaten				; if not, branch
		asl	ost_x_vel(a0)
		asl	ost_y_vel(a0)

	.not_beaten:
		addq.b	#2,ost_mode(a0)				; goto BLZ_ShipAtTop next
		bra.w	BLZ_Update				; update position, check for hit
; ===========================================================================

BLZ_ShipWobble:
		bset	#status_xflip_bit,ost_status(a0)	; ship face right
		addq.b	#2,ost_boss_wobble(a0)			; increment wobble
		move.b	ost_boss_wobble(a0),d0
		jsr	(CalcSine).w				; convert to sine/cosine
		tst.w	d1
		bpl.s	.face_right				; branch if cosine is +ve
		bclr	#status_xflip_bit,ost_status(a0)	; ship face left

	.face_right:
		asr.w	#4,d0
		swap	d0
		clr.w	d0
		add.l	ost_boss_parent_x_pos(a0),d0
		swap	d0
		move.w	d0,ost_x_pos(a0)			; apply wobble to x pos
		move.w	ost_y_vel(a0),d0
		move.w	(v_ost_player+ost_y_pos).w,d1
		sub.w	ost_y_pos(a0),d1
		bcs.s	.in_range				; branch if Sonic is above the ship
		subi.w	#$48,d1
		bcs.s	.in_range				; branch if Sonic is within 72px below the ship
		asr.w	#1,d0
		subi.w	#$28,d1
		bcs.s	.in_range				; branch if Sonic is within 112px below the ship
		asr.w	#1,d0
		subi.w	#$28,d1
		bcs.s	.in_range				; branch if Sonic is within 152px below the ship
		moveq	#0,d0

	.in_range:
		ext.l	d0
		asl.l	#8,d0
		tst.b	ost_boss_mode(a0)			; has boss been beaten?
		beq.s	.not_beaten				; if not, branch
		add.l	d0,d0					; double speed if beaten

	.not_beaten:
		add.l	d0,ost_boss_parent_y_pos(a0)
		move.w	ost_boss_parent_y_pos(a0),ost_y_pos(a0)	; update y position (moves slower if further from Sonic)
		bra.w	BLZ_Update_SkipPos			; check for hit
; ===========================================================================

BLZ_ShipAtTop:
		moveq	#-2,d0
		cmpi.w	#$1F4C,ost_boss_parent_x_pos(a0)	; has ship reached x pos?
		bcs.s	.continue_right				; if not, branch
		move.w	#$1F4C,ost_boss_parent_x_pos(a0)	; align to x pos
		clr.w	ost_x_vel(a0)				; stop moving right
		addq.w	#1,d0

	.continue_right:
		cmpi.w	#$C0,ost_boss_parent_y_pos(a0)		; has ship reached y pos?
		bgt.s	.continue_up				; if not, branch
		move.w	#$C0,ost_boss_parent_y_pos(a0)		; align to y pos
		clr.w	ost_y_vel(a0)				; stop moving up
		addq.w	#1,d0

	.continue_up:
		bne.s	.continue				; branch if ship is still moving

		addq.b	#2,ost_mode(a0)				; goto BLZ_ShipWait next
		bclr	#status_xflip_bit,ost_status(a0)	; ship face left

	.continue:
		bra.w	BLZ_Update				; update position, check for hit
; ===========================================================================

BLZ_ShipWait:
		tst.b	ost_boss_mode(a0)			; has boss been beaten?
		bne.s	.beaten					; if yes, branch
		cmpi.w	#$1EC8,ost_x_pos(a1)			; has Sonic passed x pos?
		blt.s	.wait_for_sonic				; if not, branch
		cmpi.w	#$F0,ost_y_pos(a1)
		bgt.s	.wait_for_sonic
		move.b	#50,ost_boss_wait_time(a0)		; set timer for 50 frames

	.beaten:
		play.w	0, jsr, mus_LZ				; play LZ music
		clr.b	(f_boss_loaded).w
		bset	#status_xflip_bit,ost_status(a0)	; ship face right
		addq.b	#2,ost_mode(a0)				; goto BLZ_Escape1 next

	.wait_for_sonic:
		bra.w	BLZ_Update				; update position, check for hit
; ===========================================================================

BLZ_Escape1:
		tst.b	ost_boss_mode(a0)			; has boss been beaten?
		bne.s	.beaten					; if yes, branch
		subq.b	#1,ost_boss_wait_time(a0)		; decrement timer
		bne.s	.wait					; branch if time remains

	.beaten:
		clr.b	ost_boss_wait_time(a0)
		move.w	#$400,ost_x_vel(a0)			; move ship right
		move.w	#-$40,ost_y_vel(a0)			; move ship up
		clr.b	ost_boss_mode(a0)
		addq.b	#2,ost_mode(a0)				; goto BLZ_Escape2 next

	.wait:
		bra.w	BLZ_Update				; update position
; ===========================================================================

BLZ_Escape2:
		cmpi.w	#$2030,(v_boundary_right).w		; check for new boundary
		bcc.s	.chkdel
		addq.w	#2,(v_boundary_right).w			; expand right edge of level boundary
		bra.s	.update
; ===========================================================================

.chkdel:
		tst.b	ost_render(a0)				; is ship on-screen?
		bpl.s	.delete					; if not, branch

.update:
		bra.w	BLZ_Update				; update position
; ===========================================================================

.delete:
		addq.l	#4,sp
		jmp	(DeleteObject).l
