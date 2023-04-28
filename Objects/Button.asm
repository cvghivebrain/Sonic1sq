; ---------------------------------------------------------------------------
; Object 32 - buttons (MZ, SYZ, LZ, SBZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3
;	ObjPos_SYZ1, ObjPos_SYZ3
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3
;	ObjPos_SBZ1, ObjPos_SBZ2, ObjPos_SBZ3

; subtypes:
;	%BHFPIIII
;	B - 1 if button can be activated by a block
;	H - 1 to set high bit in button status instead of lowest bit
;	F - 1 to flash red
;	P - 1 to use palette line 3
;	IIII - button id
; ---------------------------------------------------------------------------

Button:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	But_Index(pc,d0.w),d1
		jmp	But_Index(pc,d1.w)
; ===========================================================================
But_Index:	index *,,2
		ptr But_Main
		ptr But_Action
; ===========================================================================

But_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto But_Action next
		move.l	#Map_But,ost_mappings(a0)
		move.w	(v_tile_button).w,ost_tile(a0)
		btst	#4,ost_subtype(a0)			; is subtype +$10?
		beq.s	.not_marble				; if not, branch

		add.w	#tile_pal3,ost_tile(a0)			; use different palette line

	.not_marble:
		move.b	#render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#4,ost_priority(a0)
		addq.w	#3,ost_y_pos(a0)
		move.b	#$F,ost_width(a0)
		move.b	#5,ost_height(a0)

But_Action:	; Routine 2
		shortcut
		tst.b	ost_subtype(a0)
		bpl.s	.ignore_block				; branch if button is unaffected by pushable block
		tst.b	ost_render(a0)
		bpl.w	DespawnQuick				; branch if button is off screen
		move.l	#PushBlock,d0
		bsr.w	FindNearestObj				; find nearest pushable block & save to ost_linked
		
	.ignore_block:
		shortcut
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0					; get low nybble of subtype
		lea	(v_button_state).w,a3
		lea	(a3,d0.w),a3				; (a3) = button status
		moveq	#0,d6
		btst	#6,ost_subtype(a0)			; is subtype $4x or $Cx? (unused)
		beq.s	.not_secondary				; if not, branch
		moveq	#7,d6					; d6 = bit to set/clear in button status
		
	.not_secondary:
		tst.b	ost_subtype(a0)
		bpl.s	.no_block				; branch if unaffected by pushable block
		tst.w	ost_linked(a0)
		bne.s	.block_found				; branch if block is nearby
		move.b	(v_frame_counter_low).w,d0
		andi.b	#$F,d0
		bne.s	.no_block				; branch except every 16th frame
		move.l	#PushBlock,d0
		bsr.w	FindNearestObj				; find nearest pushable block
		beq.s	.no_block				; branch if there is no pushable block nearby
		
	.block_found:
		getlinked					; a1 = OST of pushable block
		range_x_exact
		bpl.s	.no_block				; branch if block isn't touching button
		range_y_exact
		bmi.s	.block_contact				; branch if block is touching
		
	.no_block:
		bsr.w	SolidObject
		btst	#solid_top_bit,d1
		beq.s	.unpressed				; branch if Sonic isn't on top of the button
		
	.pressed:
		tst.b	(a3)
		bne.s	.skip_sound				; branch if button is already pressed
		play.w	1, jsr, sfx_Switch			; play "blip" sound
	.skip_sound:
		bset	d6,(a3)					; set button status
		bset	#0,ost_frame(a0)			; use "pressed" frame
		bra.w	DespawnQuick
		
	.unpressed:
		bclr	d6,(a3)					; clear button status
		bclr	#0,ost_frame(a0)			; use "unpressed" frame
		btst	#5,ost_subtype(a0)			; is subtype +$20?
		beq.w	DespawnQuick				; if not, branch
		move.b	(v_frame_counter_low).w,d0
		andi.b	#7,d0
		bne.w	DespawnQuick				; branch if 3 lowest bits of counter <> 0
		bchg	#1,ost_frame(a0)			; change frame every 8 frames
		bra.w	DespawnQuick
		
	.block_contact:
		bsr.w	SolidObject
		bra.s	.pressed
