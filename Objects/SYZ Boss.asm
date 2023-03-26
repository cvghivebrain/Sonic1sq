; ---------------------------------------------------------------------------
; Object 75 - Eggman (SYZ)

; spawned by:
;	DynamicLevelEvents - routine 0
;	BossSpringYard - routine 
; ---------------------------------------------------------------------------

BossSpringYard:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	BSYZ_Index(pc,d0.w),d1
		jmp	BSYZ_Index(pc,d1.w)
; ===========================================================================
BSYZ_Index:	index *,,2
		ptr BSYZ_Main
		ptr BSYZ_ShipMain

ost_boss_block_num:	equ ost_boss_mode			; number of block Eggman is above (0-9) - parent only
ost_boss_block:		equ ost_parent				; address of OST of block Eggman is above - parent only (2 bytes)
; ===========================================================================

BSYZ_Main:	; Routine 0
		move.w	#$2DB0,ost_x_pos(a0)
		move.w	#$4DA,ost_y_pos(a0)
		move.w	ost_x_pos(a0),ost_boss_parent_x_pos(a0)
		move.w	ost_y_pos(a0),ost_boss_parent_y_pos(a0)
		move.b	#id_col_24x24,ost_col_type(a0)
		move.b	#hitcount_syz,ost_col_property(a0)	; set number of hits to 8
		bclr	#status_xflip_bit,ost_status(a0)
		clr.b	ost_mode(a0)
		move.b	#id_BSYZ_ShipMain,ost_routine(a0)	; goto BSYZ_ShipMain next
		move.b	#id_ani_boss_ship,ost_anim(a0)
		move.b	#5,ost_priority(a0)
		move.l	#Map_Bosses,ost_mappings(a0)
		move.w	#tile_Art_Eggman,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$20,ost_displaywidth(a0)
		
		moveq	#id_UPLC_Boss,d0
		jsr	UncPLC
		
		jsr	(FindNextFreeObj).l			; find free OST slot
		bne.s	BSYZ_ShipMain				; branch if not found
		move.l	#Exhaust,ost_id(a1)
		move.w	#$400,ost_exhaust_escape(a1)		; set speed at which ship escapes
		move.l	a0,ost_exhaust_parent(a1)		; save address of OST of parent
		
		jsr	(FindNextFreeObj).l			; find free OST slot
		bne.s	BSYZ_ShipMain				; branch if not found
		move.l	#BossFace,ost_id(a1)
		move.w	#$400,ost_face_escape(a1)		; set speed at which ship escapes
		move.b	#id_BSYZ_Explode,ost_face_defeat(a1)	; boss defeat routine number
		move.l	a0,ost_face_parent(a1)			; save address of OST of parent
		
		jsr	(FindNextFreeObj).l			; find free OST slot
		bne.s	BSYZ_ShipMain				; branch if not found
		move.l	#BossWeapon,ost_id(a1)
		move.b	#2,ost_subtype(a1)
		move.l	a0,ost_weapon_parent(a1)		; save address of OST of parent

BSYZ_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		move.w	BSYZ_ShipIndex(pc,d0.w),d1
		jsr	BSYZ_ShipIndex(pc,d1.w)
		lea	(Ani_Bosses).l,a1
		jsr	(AnimateSprite).l
		moveq	#status_xflip+status_yflip,d0
		and.b	ost_status(a0),d0
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a0) ; ignore x/yflip bits
		or.b	d0,ost_render(a0)			; combine x/yflip bits from status instead
		jmp	(DisplaySprite).l
; ===========================================================================
BSYZ_ShipIndex:index *,,2
		ptr BSYZ_ShipStart
		ptr BSYZ_ShipMove
		ptr BSYZ_Attack
		ptr BSYZ_Explode
		ptr BSYZ_Recover
		ptr BSYZ_Escape
; ===========================================================================

BSYZ_ShipStart:
		move.w	#-$100,ost_x_vel(a0)			; move ship left
		cmpi.w	#$2D38,ost_boss_parent_x_pos(a0)	; has ship appeared from the right yet?
		bcc.s	BSYZ_Update				; if not, branch
		addq.b	#2,ost_mode(a0)			; goto BSYZ_ShipMove next

BSYZ_Update:
		move.b	ost_boss_wobble(a0),d0			; get wobble byte
		addq.b	#2,ost_boss_wobble(a0)			; increment wobble (wraps to 0 after $FE)
		jsr	(CalcSine).l				; convert to sine
		asr.w	#2,d0					; divide by 4
		move.w	d0,ost_y_vel(a0)			; set as y speed

BSYZ_Update_SkipWobble:
		bsr.w	BossMove				; update parent position
		move.w	ost_boss_parent_y_pos(a0),ost_y_pos(a0)	; update actual position
		move.w	ost_boss_parent_x_pos(a0),ost_x_pos(a0)

BSYZ_Update_SkipPos:
		move.w	ost_x_pos(a0),d0
		subi.w	#$2C00,d0				; subtract x pos of first block
		lsr.w	#5,d0					; divide by 32
		move.b	d0,ost_boss_block_num(a0)		; id of block the ship is above
		cmpi.b	#id_BSYZ_Explode,ost_mode(a0)
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
		move.b	#id_BSYZ_Explode,ost_mode(a0)
		move.w	#180,ost_boss_wait_time(a0)		; set timer to 3 seconds
		clr.w	ost_x_vel(a0)				; stop boss moving
		rts	
; ===========================================================================

BSYZ_ShipMove:
		move.w	ost_boss_parent_x_pos(a0),d0
		move.w	#$140,ost_x_vel(a0)			; move ship right
		btst	#status_xflip_bit,ost_status(a0)	; is ship facing left?
		bne.s	.face_right				; if not, branch
		neg.w	ost_x_vel(a0)				; move left instead
		cmpi.w	#$2C08,d0				; is ship at left edge of screen?
		bgt.s	.inside_boundary			; if not, branch
		bra.s	.chg_dir
; ===========================================================================

.face_right:
		cmpi.w	#$2D38,d0				; is ship at right edge of screen?
		blt.s	.inside_boundary			; if not, branch

.chg_dir:
		bchg	#status_xflip_bit,ost_status(a0)	; change direction
		clr.b	ost_boss_wait_time+1(a0)		; clear low byte of timer

.inside_boundary:
		subi.w	#$2C10,d0				; get x pos of ship relative to left edge
		andi.w	#$1F,d0					; read only bits 0-4
		subi.w	#$1F,d0
		bpl.s	.d0_is_0				; branch if all those bits were set
		neg.w	d0					; make d0 +ve

	.d0_is_0:
		subq.w	#1,d0
		bgt.s	.update
		tst.b	ost_boss_wait_time+1(a0)		; is low byte of timer 0?
		bne.s	.update					; if not, branch
		move.w	(v_ost_player+ost_x_pos).w,d1
		subi.w	#$2C00,d1				; get x pos of Sonic relative to left edge
		asr.w	#5,d1					; divide by 32
		cmp.b	ost_boss_block_num(a0),d1		; is ship above Sonic?
		bne.s	.update					; if not, branch

		moveq	#0,d0
		move.b	ost_boss_block_num(a0),d0
		asl.w	#5,d0
		addi.w	#$2C10,d0				; get x pos of block below ship
		move.w	d0,ost_boss_parent_x_pos(a0)		; align ship to block
		bsr.w	BSYZ_FindBlock				; save address of OST of block to ost_boss_block
		addq.b	#2,ost_mode(a0)			; goto BSYZ_Attack next
		clr.b	ost_subtype(a0)				; goto BSYZ_Descend next
		clr.b	ost_boss_mode(a0)
		clr.w	ost_x_vel(a0)				; stop moving horizontally

	.update:
		bra.w	BSYZ_Update
; ===========================================================================

BSYZ_Attack:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		move.w	BSYZ_Attack_Index(pc,d0.w),d0
		jmp	BSYZ_Attack_Index(pc,d0.w)
; ===========================================================================
BSYZ_Attack_Index:
		index *,,2
		ptr BSYZ_Descend
		ptr BSYZ_Lift
		ptr BSYZ_LiftStop
		ptr BSYZ_BreakBlock
; ===========================================================================

BSYZ_Descend:
		move.w	#$180,ost_y_vel(a0)			; move ship down
		move.w	ost_boss_parent_y_pos(a0),d0
		cmpi.w	#$556,d0				; has ship reached block?
		bcs.s	.update					; if not, branch
		move.w	#$556,ost_boss_parent_y_pos(a0)		; align to block
		clr.w	ost_boss_wait_time(a0)
		moveq	#-1,d0
		move.w	ost_boss_block(a0),d0			; get address of OST of block
		beq.s	.no_block				; branch if block not found
		movea.l	d0,a1					; a1 = address of OST of block
		move.b	#-1,ost_bblock_mode(a1)			; set block lifting flag
		move.b	#-1,ost_boss_mode(a0)
		move.l	a0,ost_bblock_boss(a1)
		move.w	#50,ost_boss_wait_time(a0)		; set timer to 50 frames

	.no_block:
		clr.w	ost_y_vel(a0)				; stop moving
		addq.b	#2,ost_subtype(a0)			; goto BSYZ_Lift next

	.update:
		bra.w	BSYZ_Update_SkipWobble
; ===========================================================================

BSYZ_Lift:
		subq.w	#1,ost_boss_wait_time(a0)		; decrement timer (already 0 if there was no block)
		bpl.s	.shake					; branch if time remains
		addq.b	#2,ost_subtype(a0)			; goto BSYZ_LiftStop next
		move.w	#-$800,ost_y_vel(a0)			; move ship up
		tst.w	ost_boss_block(a0)			; is boss in block lifting mode?
		bne.s	.lifting				; if yes, branch
		asr	ost_y_vel(a0)

	.lifting:
		moveq	#0,d0					; no shake
		bra.s	.update
; ===========================================================================

.shake:
		moveq	#0,d0
		cmpi.w	#30,ost_boss_wait_time(a0)		; have 20 frames passed since making contact with the block?
		bgt.s	.update					; if not, branch
		moveq	#2,d0					; shake 2px
		btst	#1,ost_boss_wait_time+1(a0)		; test bit 1 of timer (changes every 2nd frame)
		beq.s	.update					; branch if 0
		neg.w	d0					; shake -2px

.update:
		add.w	ost_boss_parent_y_pos(a0),d0		; add parent y pos to shake
		move.w	d0,ost_y_pos(a0)			; update actual y pos
		move.w	ost_boss_parent_x_pos(a0),ost_x_pos(a0)
		bra.w	BSYZ_Update_SkipPos
; ===========================================================================

BSYZ_LiftStop:
		move.w	#$4DA,d0
		tst.w	ost_boss_block(a0)			; was block found?
		beq.s	.no_block				; if not, branch
		subi.w	#$18,d0

	.no_block:
		cmp.w	ost_boss_parent_y_pos(a0),d0		; has ship reached top of the screen?
		blt.s	.not_at_top				; if not, branch
		move.w	#8,ost_boss_wait_time(a0)
		tst.w	ost_boss_block(a0)			; was block found?
		beq.s	.no_block2				; if not, branch
		move.w	#45,ost_boss_wait_time(a0)

	.no_block2:
		addq.b	#2,ost_subtype(a0)			; goto BSYZ_BreakBlock next
		clr.w	ost_y_vel(a0)				; stop moving up
		bra.s	.update
; ===========================================================================

.not_at_top:
		cmpi.w	#-$40,ost_y_vel(a0)
		bge.s	.update
		addi.w	#$C,ost_y_vel(a0)			; slow ship's ascent

.update:
		bra.w	BSYZ_Update_SkipWobble
; ===========================================================================

BSYZ_BreakBlock:
		subq.w	#1,ost_boss_wait_time(a0)		; decrement timer
		bgt.s	.shake
		bmi.s	.reset_to_hover				; branch if below 0
		moveq	#-1,d0
		move.w	ost_boss_block(a0),d0			; get address of OST of block
		beq.s	.no_block				; branch if there is no block
		movea.l	d0,a1
		move.b	#$A,ost_bblock_mode(a1)			; signal block to break

	.no_block:
		clr.w	ost_boss_block(a0)
		bra.s	.shake
; ===========================================================================

.reset_to_hover:
		cmpi.w	#-$1E,ost_boss_wait_time(a0)
		bne.s	.shake
		clr.b	ost_boss_mode(a0)
		subq.b	#2,ost_mode(a0)			; goto BSYZ_ShipMove next
		move.b	#-1,ost_boss_wait_time+1(a0)
		bra.s	.update
; ===========================================================================

.shake:
		moveq	#1,d0
		tst.w	ost_boss_block(a0)			; is there a block?
		beq.s	.no_block2				; if not, branch
		moveq	#2,d0					; shake value

	.no_block2:
		cmpi.w	#$4DA,ost_boss_parent_y_pos(a0)		; is ship at top of screen?
		beq.s	.skip_shake				; if yes, branch
		blt.s	.above_top				; branch if above top
		neg.w	d0					; invert shake

	.above_top:
		tst.w	ost_boss_block(a0)
		add.w	d0,ost_boss_parent_y_pos(a0)		; apply shake to parent y pos

	.skip_shake:
		moveq	#0,d0
		tst.w	ost_boss_block(a0)			; is there a block?
		beq.s	.skip_shake2				; if not, branch
		moveq	#2,d0
		btst	#0,ost_boss_wait_time+1(a0)
		beq.s	.skip_shake2
		neg.w	d0

	.skip_shake2:
		add.w	ost_boss_parent_y_pos(a0),d0
		move.w	d0,ost_y_pos(a0)			; update actual y pos
		move.w	ost_boss_parent_x_pos(a0),ost_x_pos(a0)

.update:
		bra.w	BSYZ_Update_SkipPos

; ---------------------------------------------------------------------------
; Subroutine to find the OST address of the block Eggman is above

; output:
;	a1 = address of OST of block Eggman is above
; ---------------------------------------------------------------------------

BSYZ_FindBlock:
		clr.w	ost_boss_block(a0)
		lea	(v_ost_all+sizeof_ost).w,a1		; first OST slot excluding Sonic
		moveq	#$3E,d0					; check first $40 OSTs (there are $80 total)
		move.l	#BossBlock,d1
		move.b	ost_boss_block_num(a0),d2		; id of block Eggman is above

.loop:
		cmp.l	(a1),d1					; is object a SYZ boss block?
		bne.s	.next					; if not, branch
		cmp.b	ost_subtype(a1),d2			; is Eggman above the block?
		bne.s	.next					; if not, branch
		move.w	a1,ost_boss_block(a0)			; save address of OST of block
		bra.s	.exit
; ===========================================================================

.next:
		lea	sizeof_ost(a1),a1			; next object RAM entry
		dbf	d0,.loop

.exit:
		rts	
; End of function BSYZ_FindBlock

; ===========================================================================

BSYZ_Explode:
		subq.w	#1,ost_boss_wait_time(a0)		; decrement timer
		bmi.s	.stop_exploding				; branch if below 0
		bra.w	BossExplode				; load explosion object
; ===========================================================================

.stop_exploding:
		addq.b	#2,ost_mode(a0)			; goto BSYZ_Recover next
		clr.w	ost_y_vel(a0)				; stop moving
		bset	#status_xflip_bit,ost_status(a0)	; ship face right
		bclr	#status_broken_bit,ost_status(a0)
		clr.w	ost_x_vel(a0)
		move.w	#-1,ost_boss_wait_time(a0)		; set timer (counts up)
		tst.b	(v_boss_status).w
		bne.s	.update
		move.b	#1,(v_boss_status).w			; set boss beaten flag

	.update:
		bra.w	BSYZ_Update_SkipPos
; ===========================================================================

BSYZ_Recover:
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
		cmpi.w	#$20,ost_boss_wait_time(a0)		; have 32 frames passed since ship stopped falling?
		bcs.s	.ship_rises				; if not, branch
		beq.s	.stop_rising				; if exactly 32, branch
		cmpi.w	#$2A,ost_boss_wait_time(a0)		; have 42 frames passed since ship stopped falling?
		bcs.s	.update					; if not, branch
		addq.b	#2,ost_mode(a0)			; goto BSYZ_Escape next
		bra.s	.update
; ===========================================================================

.ship_rises:
		subq.w	#8,ost_y_vel(a0)			; move ship upwards
		bra.s	.update
; ===========================================================================

.stop_rising:
		clr.w	ost_y_vel(a0)				; stop ship rising
		play.w	0, jsr, mus_SYZ				; play SYZ music

.update:
		bra.w	BSYZ_Update_SkipWobble			; update actual position, check for hits
; ===========================================================================

BSYZ_Escape:
		move.w	#$400,ost_x_vel(a0)			; move ship right
		move.w	#-$40,ost_y_vel(a0)			; move ship upwards
		cmpi.w	#$2D40,(v_boundary_right).w		; check for new boundary
		bcc.s	.chkdel
		addq.w	#2,(v_boundary_right).w			; expand right edge of level boundary
		bra.s	.update
; ===========================================================================

.chkdel:
		tst.b	ost_render(a0)				; is ship on-screen?
		bpl.s	.delete					; if not, branch

.update:
		bsr.w	BossMove				; update parent position
		bra.w	BSYZ_Update				; update actual position
; ===========================================================================

.delete:
		addq.l	#4,sp
		jmp	(DeleteObject).l
