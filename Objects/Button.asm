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
		
type_button_pal3_bit:	equ 4
type_button_flash_bit:	equ 5
type_button_hi_bit:	equ 6
type_button_block_bit:	equ 7
type_button_pal3:	equ 1<<type_button_pal3_bit		; use palette line 3
type_button_flash:	equ 1<<type_button_flash_bit		; flashing red
type_button_hi:		equ 1<<type_button_hi_bit		; use high bit in button pressed status
type_button_block:	equ 1<<type_button_block_bit		; can be activated by block
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
		btst	#type_button_pal3_bit,ost_subtype(a0)	; is subtype +$10?
		beq.s	.not_marble				; if not, branch

		addi.w	#tile_pal3,ost_tile(a0)			; use different palette line

	.not_marble:
		move.b	#render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#StrId_Button,ost_name(a0)
		move.w	#priority_4,ost_priority(a0)
		addq.w	#3,ost_y_pos(a0)
		move.b	#$F,ost_width(a0)
		move.b	#5,ost_height(a0)

But_Action:	; Routine 2
		shortcut
		bsr.w	SolidObject
		move.b	ost_subtype(a0),d0
		move.b	d0,d6
		move.b	d6,d2
		andi.w	#$F,d0					; get low nybble of subtype
		lea	(v_button_state).w,a3
		adda.w	d0,a3					; (a3) = button status
		andi.b	#type_button_hi,d6			; d6 = 0 or $40
		beq.s	.low_status				; branch if status bit is clear
		moveq	#7,d6
		
	.low_status:
		btst	#solid_top_bit,d1			; check top collision
		bne.s	But_Press				; branch if pressed
		tst.b	d2
		bpl.s	.ignore_block				; branch if button is unaffected by pushable block
		tst.w	ost_linked(a0)
		bne.s	.block_found				; branch if block is nearby
		move.b	(v_vblank_counter_byte).w,d0
		andi.b	#$1F,d0
		bne.s	.ignore_block				; branch except every 32nd frame
		move.l	#PushBlock,d0
		bsr.w	FindNearestObj				; find nearest pushable block
		beq.s	.ignore_block				; branch if there is no pushable block nearby
		
	.block_found:
		getlinked					; a1 = OST of pushable block
		range_x_exact
		bpl.s	.ignore_block				; branch if block isn't touching button
		range_y_exact
		bmi.s	But_Press				; branch if block is touching
		
	.ignore_block:
		bclr	d6,(a3)					; clear button status (bit 0 or 7)
		bclr	#0,ost_frame(a0)			; use "unpressed" frame
		bra.w	DespawnQuick
; ===========================================================================
		
But_Press:
		btst	d6,(a3)
		bne.s	.skip_blip				; branch if button is already pressed
		play.w	1, jsr, sfx_Switch			; play "blip" sound
		
	.skip_blip:
		bset	d6,(a3)					; set button status (bit 0 or 7)
		bset	#0,ost_frame(a0)			; use "pressed" frame
		btst	#type_button_flash_bit,d2		; is subtype +$20?
		beq.w	DespawnQuick				; if not, branch
		move.b	(v_frame_counter_low).w,d0
		andi.b	#7,d0
		bne.w	DespawnQuick				; branch if 3 lowest bits of counter <> 0
		bchg	#1,ost_frame(a0)			; change frame every 8 frames
		bra.w	DespawnQuick
