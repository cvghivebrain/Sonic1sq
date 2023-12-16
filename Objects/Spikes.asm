; ---------------------------------------------------------------------------
; Object 36 - spikes

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3 - subtypes 0/$10/$20/$30/$40
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 1/$10/$12/$30/$52
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3 - subtypes 0/1/$10/$20/$30/$40
;	ObjPos_SBZ3 - subtypes 0/$30

; subtypes:
;	%KTTTRRHV
;	K - 1 for classic double-kill behaviour
;	TTT - size/direction type (see Spike_Var)
;	RR - movement rate (see Spike_Times)
;	H - 1 to move left/right every time interval
;	V - 1 to move up/down every time interval

type_spike_3up:		equ ((Spike_Var_0-Spike_Var)/4)<<4	; $0x - 3 facing up (or down if yflipped)
type_spike_3left:	equ ((Spike_Var_1-Spike_Var)/4)<<4	; $1x - 3 facing left (or right if xflipped)
type_spike_1up:		equ ((Spike_Var_2-Spike_Var)/4)<<4	; $2x - 1 facing up (or down if yflipped)
type_spike_3upwide:	equ ((Spike_Var_3-Spike_Var)/4)<<4	; $3x - 3 facing up (or down if yflipped), wide spacing
type_spike_6upwide:	equ ((Spike_Var_4-Spike_Var)/4)<<4	; $4x - 6 facing up (or down if yflipped), wide spacing
type_spike_1left:	equ ((Spike_Var_5-Spike_Var)/4)<<4	; $5x - 1 facing left (or right if xflipped)
type_spike_updown_bit:	equ 0
type_spike_leftright_bit: equ 1
type_spike_still:	equ 0					; x0 - doesn't move
type_spike_updown:	equ 1<<type_spike_updown_bit		; x2 - moves up and down 32px
type_spike_leftright:	equ 1<<type_spike_leftright_bit		; x4 - moves side-to-side 32px
type_spike_doublekill:	equ $80					; classic pre-bugfix behaviour, kills Sonic after losing rings immediately
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

Spike_Times:	dc.w 60, 30, 15, 90

		rsobj Spikes
ost_spike_x_start:	rs.w 1					; original X position
ost_spike_move_master:	rs.w 1					; time between moves
ost_spike_move_time:	rs.w 1					; time until object moves again
ost_spike_move_flag:	rs.b 1					; 0 = original position; 1 = moved position
ost_spike_side:		rs.b 1					; sidedness bitmask
ost_spike_move_dist:	rs.b 1					; distance moved (0-4 meaning 0-32px)
		rsobjend
; ===========================================================================

Spike_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Spike_Solid next
		move.l	#Map_Spike,ost_mappings(a0)
		move.w	(v_tile_spikes).w,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	ost_subtype(a0),d0
		move.b	d0,d1
		andi.w	#$70,d0					; read high nybble (excluding high bit)
		lsr.w	#2,d0
		lea	Spike_Var(pc,d0.w),a1
		move.b	(a1)+,ost_frame(a0)
		move.b	(a1),ost_displaywidth(a0)
		move.b	(a1)+,ost_width(a0)
		move.b	(a1)+,ost_height(a0)
		move.b	(a1)+,ost_spike_side(a0)
		move.w	ost_x_pos(a0),ost_spike_x_start(a0)
		andi.w	#%00001100,d1				; read bits 2-3 of subtype
		lsr.w	#1,d1
		move.w	Spike_Times(pc,d1.w),ost_spike_move_master(a0) ; set master timer

Spike_Solid:	; Routine 2
		move.b	ost_subtype(a0),d0			; get subtype
		andi.w	#type_spike_updown+type_spike_leftright,d0 ; read only bits 0-1
		beq.s	.skip_move				; branch if both 0
		bsr.s	Spike_Move				; update position
		
	.skip_move:
		bsr.w	SolidObject
		tst.b	(v_invincibility).w
		bne.s	Spike_Display				; branch if Sonic is invincible
		cmpi.b	#id_Sonic_Hurt,ost_routine(a1)
		bcc.s	Spike_Display				; branch if Sonic is hurt or dead
		tst.b	ost_subtype(a0)
		bmi.s	.skip_flashchk				; branch if spikes are set to classic double-kill
		tst.w	ost_sonic_flash_time(a1)
		bne.s	Spike_Display				; branch if Sonic is flashing
		
	.skip_flashchk:
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
		bra.w	DespawnQuick_AltX

; ---------------------------------------------------------------------------
; Subroutine to move spikes
; ---------------------------------------------------------------------------

Spike_Move:
		tst.w	ost_spike_move_time(a0)
		beq.s	.move_now				; branch if timer is on 0
		subq.w	#1,ost_spike_move_time(a0)		; decrement timer
		bne.s	.exit					; branch if time remains
		tst.b	ost_render(a0)
		bpl.s	.exit					; branch if spikes are off screen
		play.w	1, jmp, sfx_SpikeMove			; play "spikes moving" sound
		
	.move_now:
		addq.b	#1,ost_spike_move_dist(a0)
		moveq	#8,d1
		tst.b	ost_spike_move_flag(a0)
		beq.s	.initial_pos				; branch if in initial pos
		neg.w	d1					; reverse direction
		
	.initial_pos:
		btst	#type_spike_leftright_bit,d0
		beq.s	.skip_leftright				; branch if not moving left/right
		add.w	d1,ost_x_pos(a0)			; move left/right
		
	.skip_leftright:
		andi.b	#type_spike_updown,d0
		beq.s	.skip_updown				; branch if not moving up/down
		add.w	d1,ost_y_pos(a0)			; move up/down
		
	.skip_updown:
		cmpi.b	#4,ost_spike_move_dist(a0)
		bne.s	.exit					; branch if not moved fully
		move.b	#0,ost_spike_move_dist(a0)
		bchg	#0,ost_spike_move_flag(a0)		; reverse next time
		move.w	ost_spike_move_master(a0),ost_spike_move_time(a0) ; reset timer
		
	.exit:
		rts
