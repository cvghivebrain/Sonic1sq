; ---------------------------------------------------------------------------
; Object 48 - ball on a	chain that Eggman swings (GHZ)

; spawned by:
;	Bosses, BossBall
; ---------------------------------------------------------------------------

BossBall:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	GBall_Index(pc,d0.w),d1
		jmp	GBall_Index(pc,d1.w)
; ===========================================================================
GBall_Index:	index *,,2
		ptr GBall_Main
		ptr GBall_Wait
		ptr GBall_Swing
		ptr GBall_BallDrop
		ptr GBall_BallSwing
		ptr GBall_BallExplode

		rsobj BossBall
ost_gball_speed:	rs.w 1					; rate of change of angle
ost_gball_time:		rs.b 1					; timer
ost_gball_radius:	rs.b 1					; distance of ball/link from base
ost_gball_radius_now:	rs.b 1					; current distance from base
		rsobjend
; ===========================================================================

GBall_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto GBall_Wait next
		move.w	#$4000,ost_angle(a0)
		move.w	#-$200,ost_gball_speed(a0)
		move.l	#Map_BossItems,ost_mappings(a0)
		move.w	#vram_weapon/sizeof_cell,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#priority_6,ost_priority(a0)
		moveq	#id_UPLC_GHZAnchor,d0
		jsr	UncPLC
		
		jsr	FindNextFreeObj				; find free OST slot
		bne.w	.fail					; branch if not found
		move.l	#BossBall,ost_id(a1)			; load ball object
		move.b	#id_GBall_BallDrop,ost_routine(a1)
		move.l	#Map_GBall,ost_mappings(a1)
		move.w	#(vram_ball/sizeof_cell)+tile_pal3,ost_tile(a1)
		move.b	#id_frame_ball_check1,ost_frame(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#32,ost_displaywidth(a1)
		move.b	#priority_5,ost_priority(a1)
		move.b	#id_React_Hurt,ost_col_type(a1)		; make object hurt Sonic
		move.b	#20,ost_col_width(a1)
		move.b	#20,ost_col_height(a1)
		move.b	#$60,ost_gball_radius(a1)
		move.b	#-32,ost_gball_radius_now(a1)
		getparent	a2
		move.w	ost_x_pos(a2),ost_x_pos(a1)
		move.w	ost_y_pos(a2),ost_y_pos(a1)		; match position to ship
		saveparent
		move.w	a1,ost_linked(a0)			; anchor remembers ball OST
		
		moveq	#4-1,d1
		moveq	#16,d2
		
	.loop:
		jsr	FindNextFreeObj				; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#BossChain,ost_id(a1)			; load chain link object
		move.l	#Map_Swing_GHZ,ost_mappings(a1)
		move.w	(v_tile_swing).w,ost_tile(a1)
		move.b	#id_frame_swing_chain,ost_frame(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#8,ost_displaywidth(a1)
		move.b	#priority_6,ost_priority(a1)
		move.b	d2,ost_gball_radius(a1)
		addi.b	#16,d2					; chain links are 16px apart
		saveparent
		move.w	ost_linked(a0),ost_linked(a1)		; remember ball OST
		dbf	d1,.loop
		
	.fail:
		rts

GBall_Wait:	; Routine 2
		getlinked					; a1 = OST of ball
		tst.b	ost_gball_radius_now(a1)
		bpl.s	.visible				; branch if ball is below object
		rts
		
	.visible:
		getparent					; a1 = OST of ship
		tst.w	ost_x_vel(a1)
		beq.s	GBall_Pos				; branch if ship isn't moving
		bmi.s	.left					; branch if moving left
		neg.w	ost_gball_speed(a0)			; ball starts swinging other way
		
	.left:
		addq.b	#2,ost_routine(a0)			; goto GBall_Swing next
		
GBall_Pos:
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),d0
		addi.w	#32,d0
		move.w	d0,ost_y_pos(a0)			; 32px below ship
		toggleframe	8				; animate
		
		tst.b	ost_status(a1)				; has boss been beaten?
		bpl.s	.not_beaten				; if not, branch
		move.l	#ExplosionBomb,ost_id(a0)		; replace with explosion object
		move.b	#id_ExBom_Main,ost_routine(a0)
		bset	#status_broken_bit,ost_status(a0)	; signal to chain links and ball to explode
		
	.not_beaten:
		jmp	DisplaySprite
; ===========================================================================

GBall_Swing:	; Routine 4
		shortcut
		getparent					; a1 = OST of ship
		move.w	ost_gball_speed(a0),d0
		btst	#status_xflip_bit,ost_status(a1)
		bne.s	.right					; branch if ship is facing right
		addq.w	#8,d0
		cmpi.w	#$200,d0
		ble.s	.update_angle
		move.w	#$200,d0				; maximum speed
		bra.s	.update_angle
		
	.right:
		subq.w	#8,d0
		cmpi.w	#-$200,d0
		bge.s	.update_angle
		move.w	#-$200,d0
		
	.update_angle:
		move.w	d0,ost_gball_speed(a0)
		add.w	d0,ost_angle(a0)			; update angle
		bra.s	GBall_Pos
; ===========================================================================

GBall_BallDrop:	; Routine 6
		addq.w	#1,ost_y_pos(a0)			; move down 1px
		addq.b	#1,ost_gball_radius_now(a0)
		move.b	ost_gball_radius_now(a0),d0
		cmp.b	ost_gball_radius(a0),d0
		bne.s	GBall_BallAni				; branch if not at correct radius
		addq.b	#2,ost_routine(a0)			; goto GBall_BallSwing next

GBall_BallSwing:
		; Routine 8
		bsr.w	GBall_SetPos
		getparent					; a1 = OST of anchor
		tst.b	ost_status(a1)				; has boss been beaten?
		bpl.s	GBall_BallAni				; if not, branch
		addq.b	#2,ost_routine(a0)			; goto GBall_BallExplode next
		move.b	#$61,ost_gball_time(a0)			; set timer to 1.5-ish seconds
		
GBall_BallAni:
		lea	Ani_Ball(pc),a1
		bsr.w	AnimateSprite
		set_dma_dest vram_ball,d1			; set VRAM address to write gfx
		bsr.w	DPLCSprite				; write gfx if frame has changed
		jmp	DisplaySprite
; ===========================================================================

GBall_BallExplode:	; Routine $A
		shortcut
		subq.b	#1,ost_gball_time(a0)			; decrement timer
		beq.s	.done					; branch if time hits 0
		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		addq.b	#3,d0					; 3 frame offset
		andi.b	#7,d0					; read bits 0-2
		bne.s	GBall_BallAni				; branch if any are set
		jsr	FindFreeObj				; find free OST slot
		bne.s	GBall_BallAni				; branch if not found
		move.l	#ExplosionBomb,ost_id(a1)		; load explosion object every 8th frame
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		jsr	RandomNumber
		moveq	#0,d1
		move.b	d0,d1
		lsr.b	#2,d1
		subi.w	#$20,d1
		add.w	d1,ost_x_pos(a1)			; randomise position
		lsr.w	#8,d0
		lsr.b	#3,d0
		add.w	d0,ost_y_pos(a1)
		bra.s	GBall_BallAni
		
	.done:
		move.b	#id_frame_ball_check1,ost_frame(a0)	; use frame with check pattern
		move.w	#$38,d2					; gravity for fragments
		lea	GBall_FragSpeed(pc),a4
		bra.w	Shatter					; break into pieces
		
GBall_FragSpeed:
		dc.w -$200, -$200				; x speed, y speed
		dc.w $200, -$200
		dc.w -$100, -$100
		dc.w $100, -$100
		
; ---------------------------------------------------------------------------
; Subroutine to update position of swinging object
; ---------------------------------------------------------------------------

GBall_SetPos:
		getparent					; a1 = OST of anchor
		move.b	ost_angle(a1),d0
		bsr.w	CalcSine				; convert d0 to sine
		move.w	ost_y_pos(a1),d2
		move.w	ost_x_pos(a1),d3
		moveq	#0,d4
		move.b	ost_gball_radius(a0),d4			; get distance of object from anchor
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,ost_y_pos(a0)			; update position
		move.w	d5,ost_x_pos(a0)
		rts
		
; ---------------------------------------------------------------------------
; Chain link for ball on chain (GHZ)

; spawned by:
;	BossBall
; ---------------------------------------------------------------------------

BossChain:
		getlinked					; a1 = OST of ball
		move.b	ost_gball_radius_now(a1),d0
		cmp.b	ost_gball_radius(a0),d0
		beq.s	BossChain_Visible			; branch if ball reaches chain link
		rts
		
BossChain_Visible:
		shortcut
		bsr.s	GBall_SetPos
		tst.b	ost_status(a1)				; has boss been beaten?
		bpl.s	.not_beaten				; if not, branch
		move.l	#ExplosionBomb,ost_id(a0)		; replace with explosion object
		move.b	#id_ExBom_Main,ost_routine(a0)
		
	.not_beaten:
		jmp	DisplaySprite

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Ball:	index *
		ptr ani_ball_boss
		
ani_ball_boss:
		dc.w 0
		dc.w id_frame_ball_shiny
		dc.w id_frame_ball_check1
		dc.w id_Anim_Flag_Restart
