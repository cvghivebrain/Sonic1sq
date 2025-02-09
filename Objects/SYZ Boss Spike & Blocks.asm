; ---------------------------------------------------------------------------
; Spring Yard Zone boss

; spawned by:
;	Boss
; ---------------------------------------------------------------------------

Stabber:
		getlinked a3					; a3 = OST of boss
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Stab_Index(pc,d0.w),d1
		jsr	Stab_Index(pc,d1.w)
		cmpi.b	#id_Boss_Explode,ost_routine(a3)
		bne.s	.exit					; branch if boss isn't exploding
		tst.w	ost_stab_blockobj(a0)
		beq.s	.no_block				; branch if no block was found
		movea.w	ost_stab_blockobj(a0),a2		; a2 = OST of block
		move.b	#id_Cheese_Break,ost_routine(a2)	; break block immediately
		
	.no_block:
		clr.b	ost_mode(a3)				; allow boss to move itself
		jmp	DeleteObject
		
	.exit:
		rts
; ===========================================================================
Stab_Index:	index *,,2
		ptr Stab_Main
		ptr Stab_Wait
		ptr Stab_Align
		ptr Stab_Drop
		ptr Stab_Return
		ptr Stab_Retract
		ptr Stab_Shake
		ptr Stab_Lift
		ptr Stab_Lift2
		ptr Stab_Break

		rsobj Stab
ost_stab_y_start:	rs.w 1					; original y position
ost_stab_y_stop:	rs.w 1					; y position to stop when picking up a block
ost_stab_x_grid:	rs.w 1					; x position (div 32) when boss moved over Sonic
ost_stab_wait_time:	rs.w 1					; time until next action
ost_stab_blockobj:	rs.w 1					; OST of nearest cheese block object
		rsobjend
; ===========================================================================

Stab_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Stab_Wait next
		move.b	#16,ost_width(a0)
		move.b	#$1D,ost_height(a0)
		move.b	#StrId_Boss,ost_name(a0)
		jsr	FindFreeFinal
		bne.s	Stab_Wait
		move.l	#CheesePick,ost_id(a1)			; load cheese pick object
		saveparent

Stab_Wait:	; Routine 2
		cmpi.b	#id_Boss_Move,ost_routine(a3)
		bne.s	.exit					; branch if boss isn't following standard movement
		move.w	ost_x_pos(a3),d0
		move.w	d0,ost_x_pos(a0)
		move.w	ost_y_pos(a3),ost_y_pos(a0)		; match position to boss
		lsr.w	#5,d0					; divide x pos by 32
		getsonic a2					; a2 = OST of Sonic
		move.w	ost_x_pos(a2),d1
		lsr.w	#5,d1
		cmp.w	d0,d1
		bne.s	.exit					; branch if not in same 32px vertical strip as Sonic
		addq.b	#2,ost_routine(a0)			; goto Stab_Align next
		move.w	d0,ost_stab_x_grid(a0)
		
	.exit:
		rts
; ===========================================================================

Stab_Align:	; Routine 4
		move.w	ost_x_pos(a3),d0
		move.w	d0,ost_x_pos(a0)
		move.w	ost_y_pos(a3),ost_y_pos(a0)		; match position to boss
		move.w	d0,d1
		lsr.w	#5,d0					; divide x pos by 32
		cmp.w	ost_stab_x_grid(a0),d0
		bne.s	.cancel					; branch if boss leaves 32px vertical strip
		move.w	d1,d2
		addi.w	#$10,d1
		andi.w	#$1F,d1
		cmpi.w	#1,d1
		bhi.s	.exit					; branch if not in middle of 32px vertical strip
		
		addq.b	#2,ost_routine(a0)			; goto Stab_Drop next
		andi.w	#$FFE0,d2
		addi.w	#$10,d2
		move.w	d2,ost_x_pos(a0)			; align to middle of 32px strip
		move.w	ost_y_pos(a3),ost_stab_y_start(a0)	; save boss y pos (including wobble)
		move.b	#1,ost_mode(a3)				; stop boss moving by itself
		move.w	#$180,ost_y_vel(a0)
		move.l	#CheeseBlock,d0
		jsr	FindNearestObj_KeepLinked		; find nearest cheese block
		beq.s	.cancel					; branch if none found
		move.w	d1,ost_stab_blockobj(a0)		; save OST of cheese block
		movea.w	d1,a1					; a1 = OST of cheese block
		move.w	ost_y_pos(a1),d0
		cmp.w	ost_y_pos(a0),d0
		bls.s	.cancel					; branch if boss is below the cheese block
		sub.w	ost_height_hi(a1),d0
		sub.w	ost_height_hi(a0),d0
		move.w	d0,ost_stab_y_stop(a0)
		bra.s	Stab_Drop
		
	.cancel:
		move.b	#id_Stab_Wait,ost_routine(a0)		; goto Stab_Wait next
		clr.b	ost_mode(a3)				; allow boss to move itself
		
	.exit:
		rts
; ===========================================================================

Stab_Drop:	; Routine 6
		update_y_pos					; move down
		move.w	ost_stab_y_stop(a0),d0
		cmp.w	ost_y_pos(a0),d0
		bhi.s	Stab_MoveBoss				; branch if boss hasn't reached block
		
		move.w	d0,ost_y_pos(a0)			; snap to block
		tst.w	ost_stab_blockobj(a0)
		beq.s	.no_block				; branch if no block was found
		movea.w	ost_stab_blockobj(a0),a2		; a2 = OST of block
		move.w	ost_x_pos(a2),d0
		cmp.w	ost_x_pos(a0),d0
		bne.s	.no_block				; branch if block isn't directly beneath boss
		move.b	#id_Stab_Shake,ost_routine(a0)		; goto Stab_Shake next
		move.w	#50,ost_stab_wait_time(a0)
		bra.s	Stab_MoveBoss
		
	.no_block:
		addq.b	#2,ost_routine(a0)			; goto Stab_Return next
		move.w	#-$400,ost_y_vel(a0)
		bra.s	Stab_MoveBoss
; ===========================================================================

Stab_Return:	; Routine 8
		update_y_pos					; move up
		move.w	ost_y_pos(a0),d0
		cmp.w	ost_stab_y_start(a0),d0
		bhi.s	Stab_MoveBoss				; branch if boss hasn't reached original y pos
		addq.b	#2,ost_routine(a0)			; goto Stab_Retract next
		move.w	d0,ost_y_pos(a0)
		move.w	#26,ost_stab_wait_time(a0)
		
Stab_MoveBoss:
		move.w	ost_x_pos(a0),ost_x_pos(a3)
		move.w	ost_y_pos(a0),ost_y_pos(a3)		; move boss as well
		rts
; ===========================================================================

Stab_Retract:	; Routine $A
		subq.w	#1,ost_stab_wait_time(a0)		; decrement timer
		bpl.s	.exit					; branch if time remains
		move.b	#id_Stab_Wait,ost_routine(a0)		; goto Stab_Wait next
		clr.b	ost_mode(a3)				; allow boss to move on its own
		
	.exit:
		rts
; ===========================================================================

Stab_Shake:	; Routine $C
		subq.w	#1,ost_stab_wait_time(a0)		; decrement timer
		bpl.s	.shake					; branch if time remains
		addq.b	#2,ost_routine(a0)			; goto Stab_Lift next
		move.w	#-$800,ost_y_vel(a0)			; move up quickly
		
	.exit:
		rts
		
	.shake:
		cmpi.w	#30,ost_stab_wait_time(a0)
		bgt.s	.exit					; branch if in first 20 frames of touching the block
		move.w	ost_stab_wait_time(a0),d0
		andi.w	#%10,d0					; read only bit 1 of timer (changes every 2 frames)
		add.w	d0,d0
		subq.w	#2,d0					; d0 = 2 or -2
		add.w	ost_stab_y_stop(a0),d0
		move.w	d0,ost_y_pos(a0)			; shake
		
Stab_MoveAll:
		bsr.s	Stab_MoveBoss				; move boss
		
Stab_MoveBlock:
		movea.w	ost_stab_blockobj(a0),a2		; a2 = OST of block
		move.w	ost_height_hi(a0),d1
		add.w	ost_height_hi(a2),d1
		add.w	ost_y_pos(a0),d1
		move.w	d1,ost_y_pos(a2)			; move block with boss
		rts
; ===========================================================================

Stab_Lift:	; Routine $E
		update_y_pos					; move up
		move.w	ost_stab_y_start(a0),d0
		subi.w	#32,d0					; target 32px above start y pos
		cmp.w	ost_y_pos(a0),d0
		bcs.s	Stab_MoveAll				; branch if boss hasn't reached target
		addq.b	#2,ost_routine(a0)			; goto Stab_Lift2 next
		move.w	#$400,ost_y_vel(a0)			; move down next
		bra.s	Stab_MoveAll
; ===========================================================================

Stab_Lift2:	; Routine $10
		update_y_pos					; move down
		move.w	ost_stab_y_start(a0),d0
		cmp.w	ost_y_pos(a0),d0
		bhi.s	Stab_MoveAll				; branch if boss hasn't reached start y pos
		addq.b	#2,ost_routine(a0)			; goto Stab_Break next
		move.w	d0,ost_y_pos(a0)			; snap to start y pos
		move.w	#16,ost_stab_wait_time(a0)
		bra.s	Stab_MoveAll
; ===========================================================================

Stab_Break:	; Routine $12
		subq.w	#1,ost_stab_wait_time(a0)		; decrement timer
		bpl.s	.exit					; branch if time remains
		move.b	#id_Stab_Retract,ost_routine(a0)	; goto Stab_Retract next
		move.w	#26,ost_stab_wait_time(a0)
		movea.w	ost_stab_blockobj(a0),a1		; a1 = OST of block
		move.b	#id_Cheese_Break,ost_routine(a1)	; make block break
		
	.exit:
		rts
		
; ---------------------------------------------------------------------------
; Spring Yard Zone boss spike

; spawned by:
;	Stabber
; ---------------------------------------------------------------------------

CheesePick:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Pick_Index(pc,d0.w),d1
		jmp	Pick_Index(pc,d1.w)
; ===========================================================================
Pick_Index:	index *,,2
		ptr Pick_Main
		ptr Pick_Move
; ===========================================================================
		
Pick_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Pick_Move next
		move.b	#4,ost_col_width(a0)
		move.b	#16,ost_col_height(a0)
		move.b	#StrId_Boss,ost_name(a0)
		moveq	#id_UPLC_SYZSpike,d0
		jsr	UncPLC					; load gfx
		move.l	#Map_Cheese,ost_mappings(a0)
		move.w	#(vram_weapon/sizeof_cell)+tile_pal2,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#id_frame_cheese_spike,ost_frame(a0)
		move.w	#priority_5,ost_priority(a0)
		
Pick_Move:	; Routine 2
		shortcut
		getparent					; a1 = OST of stabber main
		tst.l	ost_id(a1)
		bne.s	.still_there				; branch if stabber main still exists
		move.l	#ExplosionBomb,ost_id(a0)		; replace with explosion object
		move.b	#id_ExBom_Main,ost_routine(a0)
		clr.b	ost_col_type(a0)			; make spike harmless
		rts
		
	.still_there:
		cmpi.b	#id_Stab_Align,ost_routine(a1)
		bls.s	.exit					; branch if boss is moving freely
		move.b	#id_React_Hurt,ost_col_type(a0)		; make spike harmful
		move.w	ost_angle(a0),d0			; get current y offset
		beq.s	.retracted				; branch if 0
		cmpi.b	#id_Stab_Retract,ost_routine(a1)
		bne.s	.retracted				; branch if not retracting
		subq.w	#2,d0					; move up 2px
		bra.s	.setpos
		
	.retracted:
		cmpi.b	#id_Stab_Drop,ost_routine(a1)
		bne.s	.setpos					; branch if not dropping
		cmpi.w	#36,d0
		beq.s	.setpos					; branch if fully extended
		addq.w	#2,d0					; move down 2px
		
	.setpos:
		move.w	d0,ost_angle(a0)			; save y offset
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		add.w	ost_y_pos(a1),d0
		move.w	d0,ost_y_pos(a0)			; set pos relative to boss
		jmp	DisplaySprite
		
	.exit:
		clr.b	ost_col_type(a0)			; make spike harmless
		rts

; ---------------------------------------------------------------------------
; Spring Yard Zone cheese blocks

; spawned by:
;	ObjPos_SYZ3
; ---------------------------------------------------------------------------

CheeseBlock:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Cheese_Index(pc,d0.w),d1
		jmp	Cheese_Index(pc,d1.w)
; ===========================================================================
Cheese_Index:	index *,,2
		ptr Cheese_Main
		ptr Cheese_Solid
		ptr Cheese_Break
; ===========================================================================
		
Cheese_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Cheese_Solid next
		move.l	#Map_Cheese,ost_mappings(a0)
		move.b	#id_frame_cheese_wholeblock,ost_frame(a0)
		move.w	#0+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#StrId_Block,ost_name(a0)
		move.b	#$10,ost_width(a0)
		move.b	#$10,ost_height(a0)
		move.w	#priority_3,ost_priority(a0)
		
Cheese_Solid:	; Routine 2
		jsr	SolidObject
		jmp	DespawnQuick
; ===========================================================================
		
Cheese_Break:	; Routine 4
		move.b	#id_frame_cheese_broken,ost_frame(a0)	; use frame with 4 sprite pieces
		lea	Cheese_Speeds(pc),a4
		move.w	#$38,d2					; gravity for fragments
		jmp	Shatter
		
Cheese_Speeds:	dc.w -$180, -$200
		dc.w $180, -$200
		dc.w -$100, -$100
		dc.w $100, -$100
		