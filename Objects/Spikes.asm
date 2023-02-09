; ---------------------------------------------------------------------------
; Object 36 - spikes

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3 - subtypes 0/$10/$20/$30/$40
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 1/$10/$12/$30/$52
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3 - subtypes 0/1/$10/$20/$30/$40
;	ObjPos_SBZ3 - subtypes 0/$30
; ---------------------------------------------------------------------------

Spikes:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Spike_Index(pc,d0.w),d1
		jmp	Spike_Index(pc,d1.w)
; ===========================================================================
Spike_Index:	index *,,2
		ptr Spike_Main
		ptr Spike_Solid

Spike_Var:	; frame	number, width, height, sidedness
Spike_Var_0:	dc.b id_frame_spike_3up, 20, 16, solid_top+solid_bottom ; $0x
Spike_Var_1:	dc.b id_frame_spike_3left, 16, 20, solid_left+solid_right ; $1x
Spike_Var_2:	dc.b id_frame_spike_1up, 4, 16, solid_top+solid_bottom ; $2x
Spike_Var_3:	dc.b id_frame_spike_3upwide, 28, 16, solid_top+solid_bottom ; $3x
Spike_Var_4:	dc.b id_frame_spike_6upwide, 64, 16, solid_top+solid_bottom ; $4x
Spike_Var_5:	dc.b id_frame_spike_1left, 16, 4, solid_left+solid_right ; $5x

		rsobj Spikes
ost_spike_x_start:	rs.w 1					; original X position (2 bytes)
ost_spike_y_start:	rs.w 1					; original Y position (2 bytes)
ost_spike_move_dist:	rs.w 1					; pixel distance to move object * $100, either direction (2 bytes)
ost_spike_move_time:	rs.w 1					; time until object moves again (2 bytes)
ost_spike_move_flag:	rs.b 1					; 0 = original position; 1 = moved position
ost_spike_side:		rs.b 1					; sidedness bitmask
ost_spike_doublekill:	rs.b 1					; 0 = bugfix version; 1 = classic version (kills Sonic after losing rings)
		rsobjend
; ===========================================================================

Spike_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Spike_Solid next
		move.l	#Map_Spike,ost_mappings(a0)
		move.w	(v_tile_spikes).w,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	ost_subtype(a0),d0
		bpl.s	.bugfix_version				; branch if high bit isn't set
		move.b	#1,ost_spike_doublekill(a0)		; set flag for double-killing Sonic
		
	.bugfix_version:
		andi.b	#$F,ost_subtype(a0)			; leave only low nybble of subtype
		andi.w	#$70,d0					; read high nybble (excluding high bit)
		lsr.w	#2,d0
		lea	Spike_Var(pc,d0.w),a1
		move.b	(a1)+,ost_frame(a0)
		move.b	(a1),ost_displaywidth(a0)
		move.b	(a1)+,ost_width(a0)
		move.b	(a1)+,ost_height(a0)
		move.b	(a1)+,ost_spike_side(a0)
		move.w	ost_x_pos(a0),ost_spike_x_start(a0)
		move.w	ost_y_pos(a0),ost_spike_y_start(a0)

Spike_Solid:	; Routine 2
		bsr.w	Spike_Move				; update position
		bsr.w	SolidNew
		tst.b	(v_invincibility).w
		bne.s	Spike_Display				; branch if Sonic is invincible
		cmpi.b	#id_Sonic_Hurt,ost_routine(a1)
		bcc.s	Spike_Display				; branch if Sonic is hurt or dead
		tst.b	ost_spike_doublekill(a0)
		bne.s	.skip_flashchk				; branch if spikes are set to classic double-kill
		tst.w	ost_sonic_flash_time(a1)
		bne.s	Spike_Display				; branch if Sonic is flashing
		
	.skip_flashchk:
		moveq	#0,d0
		move.b	ost_spike_side(a0),d0			; get sidedness
		and.b	d0,d1					; mask with collision
		beq.s	Spike_Display				; branch if no collision
		move.l	ost_y_pos(a1),d1
		move.w	ost_y_vel(a1),d0
		ext.l	d0
		asl.l	#8,d0
		sub.l	d0,d1
		move.l	d1,ost_y_pos(a1)			; move Sonic away from spikes, based on his y speed
		movea.l	a0,a2					; a2 = OST of object that hurt Sonic
		exg	a0,a1					; temporarily make Sonic the current object
		jsr	(HurtSonic).l				; lose rings/die
		exg	a0,a2					; restore spikes as current object

Spike_Display:
		move.w	ost_spike_x_start(a0),d0
		bsr.w	CheckActive
		bne.w	DeleteObject
		bra.w	DisplaySprite
; ===========================================================================

Spike_Move:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get subtype (only low nybble remains)
		add.w	d0,d0
		move.w	Spike_TypeIndex(pc,d0.w),d1
		jmp	Spike_TypeIndex(pc,d1.w)
; ===========================================================================
Spike_TypeIndex:
		index *
		ptr Spike_Still					; $x0
		ptr Spike_UpDown				; $x1
		ptr Spike_LeftRight				; $x2
; ===========================================================================

; Type 0 - doesn't move
Spike_Still:
		rts
; ===========================================================================

; Type 1 - moves up and down
Spike_UpDown:
		bsr.w	Spike_Wait				; run timer and update ost_spike_move_dist
		moveq	#0,d0
		move.b	ost_spike_move_dist(a0),d0		; get distance to move
		add.w	ost_spike_y_start(a0),d0		; add to initial y position
		move.w	d0,ost_y_pos(a0)			; update position
		rts	
; ===========================================================================

; Type 2 - moves side-to-side
Spike_LeftRight:
		bsr.w	Spike_Wait				; run timer and update ost_spike_move_dist
		moveq	#0,d0
		move.b	ost_spike_move_dist(a0),d0		; get distance to move
		add.w	ost_spike_x_start(a0),d0		; add to initial x position
		move.w	d0,ost_x_pos(a0)			; update position
		rts	
; ===========================================================================

Spike_Wait:
		tst.w	ost_spike_move_time(a0)			; has timer hit 0?
		beq.s	.update					; if yes, branch
		subq.w	#1,ost_spike_move_time(a0)		; decrement timer
		bne.s	.exit					; branch if not 0
		tst.b	ost_render(a0)				; is spikes object on-screen?
		bpl.s	.exit					; if not, branch
		play.w	1, jsr, sfx_SpikeMove			; play "spikes moving" sound
		bra.s	.exit
; ===========================================================================

.update:
		tst.b	ost_spike_move_flag(a0)			; are spikes in original position?
		beq.s	.original_pos				; if yes, branch
		subi.w	#$800,ost_spike_move_dist(a0)		; subtract 8px from distance
		bcc.s	.exit					; branch if 0 or more
		move.w	#0,ost_spike_move_dist(a0)		; set minimum distance
		move.b	#0,ost_spike_move_flag(a0)		; set flag that spikes are in original position
		move.w	#60,ost_spike_move_time(a0)		; set time delay to 1 second
		bra.s	.exit
; ===========================================================================

.original_pos:
		addi.w	#$800,ost_spike_move_dist(a0)		; add 8px to move distance
		cmpi.w	#$2000,ost_spike_move_dist(a0)		; has it moved 32px?
		bcs.s	.exit					; if not, branch
		move.w	#$2000,ost_spike_move_dist(a0)		; set max distance
		move.b	#1,ost_spike_move_flag(a0)		; set flag that spikes are in new position
		move.w	#60,ost_spike_move_time(a0)		; set time delay to 1 second

.exit:
		rts	
