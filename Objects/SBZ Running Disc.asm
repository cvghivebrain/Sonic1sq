; ---------------------------------------------------------------------------
; Object 67 - disc that	you run	around (SBZ)

; spawned by:
;	ObjPos_SBZ2 - subtype $40

; subtypes:
;	%SSSSRRRR
;	SSSS - rotation speed (1-7 = clockwise; 8-$F = anticlockwise)
;	RRRR - radius (see Disc_Radii)
; ---------------------------------------------------------------------------

RunningDisc:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Disc_Index(pc,d0.w),d1
		jmp	Disc_Index(pc,d1.w)
; ===========================================================================
Disc_Index:	index *,,2
		ptr Disc_Main
		ptr Disc_Action

		rsobj RunningDisc
ost_disc_y_start:	rs.w 1					; original y-axis position
ost_disc_x_start:	rs.w 1					; original x-axis position
ost_disc_rotation:	rs.w 1					; rate/direction of small circle rotation
ost_disc_inner_radius:	rs.b 1					; distance of small circle from centre
ost_disc_outer_radius:	rs.b 1					; distance of Sonic from centre
ost_disc_init_flag:	rs.b 1					; set when Sonic lands on the disc
		rsobjend
		
Disc_Radii:	dc.b $18, $48
		dc.b $10, $38
; ===========================================================================

Disc_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Disc_Action next
		move.l	#Map_Disc,ost_mappings(a0)
		move.w	#tile_Kos_SbzDisc+tile_pal3+tile_hi,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_4,ost_priority(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#StrId_Disc,ost_name(a0)
		move.w	ost_x_pos(a0),ost_disc_x_start(a0)
		move.w	ost_y_pos(a0),ost_disc_y_start(a0)
		move.b	ost_subtype(a0),d0			; get object type
		move.b	d0,d1
		andi.w	#$F,d0					; read only the	low nybble
		add.b	d0,d0
		lea	Disc_Radii(pc,d0.w),a2
		move.b	(a2)+,ost_disc_inner_radius(a0)
		move.b	(a2)+,ost_disc_outer_radius(a0)
		andi.b	#$F0,d1					; read only the	high nybble
		ext.w	d1
		asl.w	#3,d1					; multiply by 8
		move.w	d1,ost_disc_rotation(a0)		; set rotation speed (only $200 is used)
		move.b	ost_status(a0),d0			; get object status
		ror.b	#2,d0					; move x/yflip bits to top
		andi.b	#(status_xflip+status_yflip)<<6,d0	; read only those
		move.b	d0,ost_angle(a0)			; use as starting angle

Disc_Action:	; Routine 2
		shortcut
		bsr.s	Disc_Detect
		add.w	d1,ost_angle(a0)			; update angle (d1 is ost_disc_rotation)
		move.b	ost_angle(a0),d0
		jsr	(CalcSine).w				; convert to sine/cosine
		move.w	ost_disc_y_start(a0),d2
		move.w	ost_disc_x_start(a0),d3
		moveq	#0,d4
		move.b	ost_disc_inner_radius(a0),d4
		lsl.w	#8,d4
		move.l	d4,d5
		muls.w	d0,d4
		swap	d4
		muls.w	d1,d5
		swap	d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,ost_y_pos(a0)			; update position
		move.w	d5,ost_x_pos(a0)
		
		move.w	ost_disc_x_start(a0),d0
		bra.w	DespawnQuick_AltX

; ---------------------------------------------------------------------------
; Subroutine to detect collision with disc and set Sonic's inertia
; ---------------------------------------------------------------------------

Disc_Detect:
		moveq	#0,d2
		move.b	ost_disc_outer_radius(a0),d2
		move.w	d2,d3
		add.w	d3,d3
		getsonic					; a1 = OST of Sonic
		move.w	ost_x_pos(a1),d0
		sub.w	ost_disc_x_start(a0),d0
		add.w	d2,d0
		cmp.w	d3,d0
		bcc.s	.not_on_disc
		move.w	ost_y_pos(a1),d1
		sub.w	ost_disc_y_start(a0),d1
		add.w	d2,d1
		cmp.w	d3,d1
		bcc.s	.not_on_disc				; branch if Sonic is outside the range of the disc
		btst	#status_air_bit,ost_status(a1)		; is Sonic in the air?
		beq.s	Disc_Inertia				; if not, branch
		clr.b	ost_disc_init_flag(a0)
		rts	
; ===========================================================================

.not_on_disc:
		tst.b	ost_disc_init_flag(a0)			; was Sonic on the disc last frame?
		beq.s	.skip_clear				; if not, branch
		bclr	#flags_stuck_bit,ost_sonic_flags(a1)
		clr.b	ost_disc_init_flag(a0)

	.skip_clear:
		rts	
; ===========================================================================

Disc_Inertia:
		tst.b	ost_disc_init_flag(a0)			; was Sonic on the disc last frame?
		bne.s	.skip_init				; if yes, branch
		move.b	#1,ost_disc_init_flag(a0)		; set flag for Sonic being on the disc
		btst	#status_jump_bit,ost_status(a1)		; is Sonic jumping?
		bne.s	.jumping				; if yes, branch
		clr.b	ost_anim(a1)				; use walking animation

	.jumping:
		bclr	#status_pushing_bit,ost_status(a1)
		move.b	#id_Run,ost_sonic_anim_next(a1)		; use running animation
		bset	#flags_stuck_bit,ost_sonic_flags(a1)	; keep Sonic stuck to disc until he jumps

	.skip_init:
		move.w	ost_inertia(a1),d0
		move.w	ost_disc_rotation(a0),d1		; check rotation direction (only $200 is used)
		bpl.s	Disc_Inertia_Clockwise			; branch if positive

		cmpi.w	#-$400,d0
		ble.s	.chk_max_neg
		move.w	#-$400,ost_inertia(a1)			; set minimum inertia on disc
		rts	
; ===========================================================================

.chk_max_neg:
		cmpi.w	#-$F00,d0
		bge.s	.exit
		move.w	#-$F00,ost_inertia(a1)			; set maximum inertia on disc

	.exit:
		rts	
; ===========================================================================

Disc_Inertia_Clockwise:
		cmpi.w	#$400,d0
		bge.s	.chk_max
		move.w	#$400,ost_inertia(a1)			; set minimum inertia on disc
		rts	
; ===========================================================================

.chk_max:
		cmpi.w	#$F00,d0
		ble.s	.exit
		move.w	#$F00,ost_inertia(a1)			; set maximum inertia on disc

	.exit:
		rts
