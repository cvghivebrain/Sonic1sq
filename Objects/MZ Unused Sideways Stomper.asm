; ---------------------------------------------------------------------------
; Object 45 - unused sideways-facing spiked stomper (MZ)

; spawned by:
;	SideStomp
; ---------------------------------------------------------------------------

SideStomp:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	SStom_Index(pc,d0.w),d1
		jmp	SStom_Index(pc,d1.w)
; ===========================================================================
SStom_Index:	index *,,2
		ptr SStom_Main
		ptr SStom_Block
		ptr SStom_Spikes
		ptr SStom_Display
		ptr SStom_Pole

		rsobj SideStomp
ost_mash_x_start:	rs.w 1					; original x position
ost_mash_length:	rs.w 1					; current pole length
ost_mash_max_length:	rs.w 1					; maximum pole length
ost_mash_wait_time:	rs.w 1					; time to wait while fully extended
ost_mash_x_diff:	rs.w 1					; relative x pos to main object
ost_mash_retract_flag:	rs.b 1					; 1 = retract
		rsobjend

SStom_Len:	dc.w $3800					; 0 - short
		dc.w $A000					; 1 - long
		dc.w $5000					; 2 - medium

		; routine, x pos, frame, priority
SStom_Var:	dc.b id_SStom_Display, $28, id_frame_mash_wallbracket, 3 ; wall bracket
		dc.b id_SStom_Pole, $34, id_frame_mash_pole1, 4 ; pole
		dc.b id_SStom_Spikes, -$1C, id_frame_mash_spikes, 4 ; spikes
		even
; ===========================================================================

SStom_Main:	; Routine 0
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype
		add.w	d0,d0
		move.w	SStom_Len(pc,d0.w),ost_mash_max_length(a0) ; get pole length based on subtype
		move.l	#Map_SStom,ost_mappings(a0)
		move.w	#tile_Kos_MzMetal,ost_tile(a0)
		move.b	#id_frame_mash_block,ost_frame(a1)
		move.b	#render_rel,ost_render(a0)
		move.w	ost_x_pos(a0),ost_mash_x_start(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.b	#4,ost_priority(a0)
		move.b	#12,ost_width(a0)
		move.b	#32,ost_height(a0)
		addi.b	#2,ost_routine(a0)			; goto SStom_Block next
		
		lea	SStom_Var(pc),a2
		moveq	#3-1,d1					; 3 additional objects
		moveq	#0,d2
	.loop:
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.w	SStom_Block
		move.l	#SideStomp,ost_id(a1)			; load wall bracket
		move.b	(a2)+,ost_routine(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_mash_x_start(a0),ost_mash_x_start(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	(a2)+,d2
		ext.w	d2
		add.w	d2,ost_x_pos(a1)
		move.w	d2,ost_mash_x_diff(a1)
		move.l	#Map_SStom,ost_mappings(a1)
		move.w	#tile_Kos_MzMetal,ost_tile(a1)
		move.b	(a2)+,ost_frame(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	(a2)+,ost_priority(a1)
		move.b	#16,ost_displaywidth(a1)
		bsr.w	SaveParent
		dbf	d1,.loop
		
		move.b	#id_col_16x24+id_col_hurt,ost_col_type(a1) ; last object is spikes
		move.w	(v_tile_spikes).w,ost_tile(a1)

SStom_Block:	; Routine 2
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		bsr.w	SStom_Move				; update position of main block
		bsr.w	SolidObject

SStom_Display:	; Routine 6
		move.w	ost_mash_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

SStom_Pole:	; Routine 8
		bsr.w	GetParent				; a1 = address of parent OST
		move.b	ost_mash_length(a1),d0			; get current pole length
		addi.b	#$10,d0
		lsr.b	#5,d0					; divide by $20
		addq.b	#id_frame_mash_pole1,d0			; first pole frame (3)
		move.b	d0,ost_frame(a0)			; udpate frame
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_mash_x_diff(a0),d0
		add.w	d0,ost_x_pos(a0)
		bra.s	SStom_Display

SStom_Spikes:	; Routine 4
		bsr.w	GetParent				; a1 = address of parent OST
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_mash_x_diff(a0),d0
		add.w	d0,ost_x_pos(a0)
		bra.s	SStom_Display

; ---------------------------------------------------------------------------
; Subroutine to move the main metal block
; ---------------------------------------------------------------------------

SStom_Move:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		add.w	d0,d0
		move.w	SStom_Move_Index(pc,d0.w),d1
		jmp	SStom_Move_Index(pc,d1.w)

; ===========================================================================
SStom_Move_Index:
		index *
		ptr SStom_Move_0
		ptr SStom_Move_0
		ptr SStom_Move_0
; ===========================================================================

SStom_Move_0:
		tst.b	ost_mash_retract_flag(a0)		; is flag set to retract?
		beq.s	.extend					; if not, branch
		tst.w	ost_mash_wait_time(a0)			; has time delay run out?
		beq.s	.retract				; if yes, branch
		subq.w	#1,ost_mash_wait_time(a0)		; decrement timer
		bra.s	.update_pos
; ===========================================================================

.retract:
		subi.w	#$80,ost_mash_length(a0)		; retract
		bcc.s	.update_pos				; branch if at least $80 is left on length
		move.w	#0,ost_mash_length(a0)			; set to 0
		move.w	#0,ost_x_vel(a0)
		move.b	#0,ost_mash_retract_flag(a0)		; reset flag to extend
		bra.s	.update_pos
; ===========================================================================

.extend:
		move.w	ost_mash_max_length(a0),d1
		cmp.w	ost_mash_length(a0),d1			; is pole fully extended?
		beq.s	.update_pos				; if yes, branch
		move.w	ost_x_vel(a0),d0
		addi.w	#$70,ost_x_vel(a0)			; increase speed
		add.w	d0,ost_mash_length(a0)
		cmp.w	ost_mash_length(a0),d1			; is pole fully extended?
		bhi.s	.update_pos				; if not, branch
		move.w	d1,ost_mash_length(a0)
		move.w	#0,ost_x_vel(a0)			; stop
		move.b	#1,ost_mash_retract_flag(a0)		; set flag to retract
		move.w	#60,ost_mash_wait_time(a0)		; set delay to 1 second

.update_pos:
		moveq	#0,d0
		move.b	ost_mash_length(a0),d0
		neg.w	d0
		add.w	ost_mash_x_start(a0),d0
		move.w	d0,ost_x_pos(a0)
		rts
