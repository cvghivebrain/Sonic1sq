; ---------------------------------------------------------------------------
; Object 45 - unused sideways-facing spiked stomper (MZ)

; spawned by:
;	SideStomp

; subtypes:
;	%00TTLLLL
;	TT - time in seconds the stomper waits before retracting (0-3)
;	LLLL - distance the stomper moves (+1, *$38 pixels)
; ---------------------------------------------------------------------------

SideStomp:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	SStom_Index(pc,d0.w),d1
		jmp	SStom_Index(pc,d1.w)
; ===========================================================================
SStom_Index:	index *,,2
		ptr SStom_Main
		ptr SStom_Base
		ptr SStom_Block
		ptr SStom_Spikes
		ptr SStom_Pole

		rsobj SideStomp
ost_mash_x_start:	rs.w 1					; original x pos for block
ost_mash_x_current:	equ ost_mash_x_start			; current block x pos (parent only)
ost_mash_x_stop:	rs.w 1					; maximum block x pos
ost_mash_length:	equ ost_mash_x_stop			; current pole length (parent only)
ost_mash_wait_time:	rs.w 1					; time to wait while fully extended
ost_mash_mode:		rs.b 1					; 0 = extend; 2 = wait; 4 = retract
		rsobjend

		; routine, frame, display width
SStom_Var:	dc.b id_SStom_Block, id_frame_mash_block, 16 ; block
		dc.b id_SStom_Spikes, id_frame_mash_spikes, 16 ; spikes
		dc.b id_SStom_Pole, id_frame_mash_pole1, $B0 ; pole
		even
; ===========================================================================

SStom_Main:	; Routine 0
		move.l	#Map_SStom,ost_mappings(a0)
		move.w	#tile_Kos_MzMetal,ost_tile(a0)
		move.b	#id_frame_mash_wallbracket,ost_frame(a0)
		move.b	ost_status(a0),d0
		andi.b	#status_xflip,d0
		move.b	d0,ost_render(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.b	#3,ost_priority(a0)
		addq.b	#2,ost_routine(a0)			; goto SStom_Base next
		move.b	ost_subtype(a0),d0
		andi.w	#%00110000,d0
		lsr.b	#4,d0					; read high nybble of subtype
		mulu.w	#60,d0
		move.w	d0,ost_mash_wait_time(a0)		; set time the stomper waits before retracting
		
		lea	SStom_Var(pc),a2
		moveq	#3-1,d1					; 3 additional objects
	.loop:
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	SStom_Base
		move.l	#SideStomp,ost_id(a1)			; load block/spikes/pole
		move.b	(a2)+,ost_routine(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_status(a0),ost_status(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	#4,ost_priority(a1)
		move.b	(a2)+,ost_frame(a1)
		move.b	(a2)+,ost_displaywidth(a1)
		saveparent
		dbf	d1,.loop

SStom_Base:	; Routine 2
		shortcut	DespawnFamily
		bra.w	DespawnFamily

SStom_Block:	; Routine 4
		move.b	#12,ost_width(a0)
		move.b	#32,ost_height(a0)
		getparent					; a1 = OST of parent
		move.w	ost_x_pos(a1),ost_mash_x_start(a0)
		move.w	ost_x_pos(a1),ost_mash_x_stop(a0)
		move.w	#$28,d0					; distance between block & base
		moveq	#0,d1
		move.b	ost_subtype(a1),d1
		andi.b	#$F,d1					; read low nybble of subtype
		addq.b	#1,d1
		mulu.w	#$38,d1					; +1 and *$38 for length
		add.w	d0,d1					; add initial dist from base
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d0					; block starts to right of base
		neg.w	d1
		
	.no_xflip:
		sub.w	d0,ost_mash_x_start(a0)
		sub.w	d1,ost_mash_x_stop(a0)
		move.w	ost_mash_x_start(a0),ost_x_pos(a0)	; set start position
		
		shortcut					; the above code only runs once
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		bsr.w	SStom_Move				; update position of main block
		bsr.w	SolidObject
		bra.w	DisplaySprite
; ===========================================================================

SStom_Pole:	; Routine 8
		shortcut
		getparent					; a1 = address of parent OST
		move.w	ost_mash_x_current(a1),d0		; current x pos of main block
		move.w	#$34,d1					; relative x pos to block
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d1					; spikes are to right of block
		
	.no_xflip:
		add.w	d1,d0
		move.w	d0,ost_x_pos(a0)			; match x pos to block
		move.w	ost_mash_length(a1),d0
		addi.w	#$10,d0
		lsr.w	#5,d0					; divide by $20
		addq.b	#id_frame_mash_pole1,d0			; first pole frame (3)
		move.b	d0,ost_frame(a0)			; update frame
		bra.w	DisplaySprite
; ===========================================================================

SStom_Spikes:	; Routine 6
		move.b	#16,ost_width(a0)
		move.b	#24,ost_height(a0)
		move.w	(v_tile_spikes).w,ost_tile(a0)
		bset	#status_pointy_bit,ost_status(a0)
		shortcut
		getparent					; a1 = address of parent OST
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		move.w	ost_mash_x_current(a1),d0		; current x pos of main block
		move.w	#$1C,d1					; relative x pos to block
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.no_xflip
		neg.w	d1					; spikes are to right of block
		
	.no_xflip:
		sub.w	d1,d0
		move.w	d0,ost_x_pos(a0)			; match x pos to block
		bsr.w	SolidObject
		andi.b	#solid_left+solid_right,d1
		beq.w	DisplaySprite				; branch if not touching left/right side
		jsr	ObjectHurtSonic				; lose rings/die
		bra.w	DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to move the main metal block
; ---------------------------------------------------------------------------

SStom_Move:
		getparent					; a1 = OST of parent
		moveq	#0,d0
		move.b	ost_mash_mode(a0),d0
		move.w	SStom_Move_Index(pc,d0.w),d1
		jsr	SStom_Move_Index(pc,d1.w)
		move.w	ost_x_pos(a0),d0
		move.w	d0,ost_mash_x_current(a1)		; copy block x pos to parent
		sbabs.w	ost_mash_x_start(a0),d0
		move.w	d0,ost_mash_length(a1)			; copy pole length to parent
		rts

; ===========================================================================
SStom_Move_Index:
		index *,,2
		ptr SStom_Move_Extend
		ptr SStom_Move_Wait
		ptr SStom_Move_Retract
; ===========================================================================

SStom_Move_Extend:
		update_x_pos					; update x pos based on speed
		move.w	ost_x_pos(a0),d0
		btst	#status_xflip_bit,ost_status(a0)
		bne.s	.xflip
		subi.w	#$70,ost_x_vel(a0)			; increase speed
		cmp.w	ost_mash_x_stop(a0),d0
		bls.s	.at_stop				; branch if block is at stop position
		rts
		
	.xflip:
		addi.w	#$70,ost_x_vel(a0)			; increase speed
		cmp.w	ost_mash_x_stop(a0),d0
		bcc.s	.at_stop				; branch if block is at stop position
		rts
		
	.at_stop:
		clr.w	ost_x_vel(a0)				; stop moving
		move.w	ost_mash_x_stop(a0),ost_x_pos(a0)
		clr.w	ost_x_sub(a0)
		move.w	ost_mash_wait_time(a1),ost_mash_wait_time(a0)
		addq.b	#2,ost_mash_mode(a0)			; goto SStom_Move_Wait next
		rts
; ===========================================================================

SStom_Move_Wait:
		subq.w	#1,ost_mash_wait_time(a0)		; decrement timer
		bpl.s	.wait					; branch if time remains
		addq.b	#2,ost_mash_mode(a0)			; goto SStom_Move_Retract next
		
	.wait:
		rts
; ===========================================================================

SStom_Move_Retract:
		move.w	ost_x_pos(a0),d0
		subq.w	#1,d0
		btst	#status_xflip_bit,ost_status(a0)
		bne.s	.no_xflip
		addq.w	#2,d0
		
	.no_xflip:
		cmp.w	ost_mash_x_start(a0),d0
		bne.s	.not_at_start				; branch if block isn't at start position
		clr.b	ost_mash_mode(a0)			; goto SStom_Move_Extend next
		
	.not_at_start:
		move.w	d0,ost_x_pos(a0)			; update position
		rts
