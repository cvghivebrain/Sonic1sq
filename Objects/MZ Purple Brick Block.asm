; ---------------------------------------------------------------------------
; Object 46 - solid blocks and blocks that fall	from the ceiling (MZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 0/1/2/$A

; subtypes:
;	%000NRTTT
;	N - 1 for not wobbling on lava
;	R - 1 for reverse wobble direction
;	TTT - type id (0 = still; 1 = wobbles; 2 = wobbles & falls)

type_brick_still:		equ id_Brick_Still/2		; 0 - doesn't move
type_brick_wobbles:		equ id_Brick_Wobbles/2		; 1 - wobbles but doesn't fall
type_brick_falls:		equ id_Brick_Falls/2		; 2 - falls when Sonic is near
type_brick_nowobble_bit:	equ 4
type_brick_rev_bit:		equ 3
type_brick_nowobble:		equ 1<<type_brick_nowobble_bit	; +$10 - don't wobble on lava
type_brick_rev:			equ 1<<type_brick_rev_bit	; +8 - reverse wobble direction
; ---------------------------------------------------------------------------

MarbleBrick:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Brick_Index(pc,d0.w),d1
		jmp	Brick_Index(pc,d1.w)
; ===========================================================================
Brick_Index:	index *,,2
		ptr Brick_Main
		ptr Brick_Action

		rsobj MarbleBrick
ost_brick_y_start:	rs.w 1					; original y position (2 bytes)
ost_brick_type:		rs.b 1					; type id
		rsobjend
; ===========================================================================

Brick_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Brick_Action next
		move.l	#Map_Brick,ost_mappings(a0)
		move.w	#0+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_3,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#$10,ost_width(a0)
		move.b	#$10,ost_height(a0)
		move.w	ost_y_pos(a0),ost_brick_y_start(a0)
		move.b	ost_subtype(a0),d0			; get object type
		andi.b	#7,d0					; read only bits 0-2
		add.b	d0,d0
		move.b	d0,ost_brick_type(a0)

Brick_Action:	; Routine 2
		shortcut
		tst.b	ost_render(a0)
		bpl.w	DespawnQuick				; branch if off screen
		moveq	#0,d0
		move.b	ost_brick_type(a0),d0			; get object type
		move.w	Brick_TypeIndex(pc,d0.w),d1
		jsr	Brick_TypeIndex(pc,d1.w)
		bsr.w	SolidObject_SkipRender
		bra.w	DespawnQuick
; ===========================================================================
Brick_TypeIndex:index *,,2
		ptr Brick_Still					; doesn't move
		ptr Brick_Wobbles				; wobbles
		ptr Brick_Falls					; wobbles and falls
		ptr Brick_FallNow				; falls immediately
		ptr Brick_FallLava				; wobbles slowly (it's on the lava now)
; ===========================================================================

; Type 0
Brick_Still:
		rts	
; ===========================================================================

; Type 2
Brick_Falls:
		getsonic					; a1 = OST of Sonic
		range_x_test	144				; is Sonic within 144px of the block?
		bcc.s	Brick_Wobbles				; if not, resume wobbling
		move.b	#id_Brick_FallNow,ost_brick_type(a0)	; if yes, make the block fall

; Type 1
Brick_Wobbles:
		moveq	#0,d0
		move.b	(v_oscillating_0_to_10).w,d0
		btst	#type_brick_rev_bit,ost_subtype(a0)	; is subtype +8?
		beq.s	.no_rev					; if not, branch
		neg.w	d0
		addi.w	#$10,d0					; wobble the opposite way

	.no_rev:
		move.w	ost_brick_y_start(a0),d1		; get initial position
		sub.w	d0,d1					; apply wobble
		move.w	d1,ost_y_pos(a0)			; update position to make it wobble
		rts	
; ===========================================================================

; Type 3
Brick_FallNow:
		update_y_fall	$18				; update position & apply gravity
		bsr.w	FindFloorObj
		tst.w	d1					; has the block	hit the	floor?
		bpl.s	.exit					; if not, branch
		add.w	d1,ost_y_pos(a0)			; align to floor
		clr.w	ost_y_vel(a0)				; stop the block falling
		move.w	ost_y_pos(a0),ost_brick_y_start(a0)
		move.b	#id_Brick_Still,ost_brick_type(a0)	; don't wobble
		move.w	(a3),d0					; get 16x16 tile id the block is sitting on
		andi.w	#$3FF,d0
		cmpi.w	#$16A,d0				; is the 16x16 tile it's landed on lava?
		bcs.s	.exit					; if not, branch
		btst	#type_brick_nowobble_bit,ost_subtype(a0)
		bne.s	.exit					; branch if set not to wobble on lava
		move.b	#id_Brick_FallLava,ost_brick_type(a0)	; final subtype - slow wobble on lava

	.exit:
		rts	
; ===========================================================================

; Type 4
Brick_FallLava:
		moveq	#0,d0
		move.b	(v_oscillating_0_to_40_fast).w,d0
		lsr.w	#3,d0
		move.w	ost_brick_y_start(a0),d1
		sub.w	d0,d1
		move.w	d1,ost_y_pos(a0)			; make the block wobble
		rts	
