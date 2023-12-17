; ---------------------------------------------------------------------------
; Object 58 - giant spiked balls (SYZ)

; spawned by:
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3

; subtypes:
;	%SSSSTTT0
;	SSSS - rotation speed (1-7 = clockwise; 8-$F = anticlockwise; BBall_Circle only)
;	TTT - type (+2 set as ost_routine)

type_bball_still:	equ id_BBall_Still-2			; 0 - doesn't move
type_bball_sideways:	equ id_BBall_Sideways-2			; 2 - moves side-to-side
type_bball_updown:	equ id_BBall_UpDown-2			; 4 - moves up and down
type_bball_circle:	equ id_BBall_Circle-2			; 6 - moves in a circle
; ---------------------------------------------------------------------------

BigSpikeBall:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	BBall_Index(pc,d0.w),d1
		jmp	BBall_Index(pc,d1.w)
; ===========================================================================
BBall_Index:	index *,,2
		ptr BBall_Main
		ptr BBall_Still
		ptr BBall_Sideways
		ptr BBall_UpDown
		ptr BBall_Circle

		rsobj BigSpikeBall
ost_bball_y_start:	rs.w 1					; original y-axis position
ost_bball_x_start:	rs.w 1					; original x-axis position
ost_bball_speed:	rs.w 1					; speed
ost_bball_radius:	rs.b 1					; radius of circle
		rsobjend
; ===========================================================================

BBall_Main:	; Routine 0
		move.l	#Map_BBall,ost_mappings(a0)
		move.w	(v_tile_spikeball).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#$18,ost_displaywidth(a0)
		move.w	ost_x_pos(a0),ost_bball_x_start(a0)
		move.w	ost_y_pos(a0),ost_bball_y_start(a0)
		move.b	#id_col_16x16+id_col_hurt,ost_col_type(a0)
		move.b	ost_subtype(a0),d1			; get object type
		move.b	d1,d2
		andi.b	#$F0,d1					; read only the	high nybble
		ext.w	d1
		asl.w	#3,d1					; multiply by 8
		move.w	d1,ost_bball_speed(a0)			; set object speed
		move.b	ost_status(a0),d0
		andi.b	#status_xflip+status_yflip,d0
		ror.b	#2,d0					; move x/yflip bits into bits 6-7
		move.b	d0,ost_angle(a0)			; use as angle
		move.b	#$50,ost_bball_radius(a0)		; set radius of circle motion
		andi.b	#$E,d2					; read low nybble of subtype
		addq.b	#2,d2
		move.b	d2,ost_routine(a0)			; goto specified routine next
		bra.w	DespawnQuick
; ===========================================================================

BBall_Still:	; Routine 2
		shortcut	DespawnQuick
		bra.w	DespawnQuick
; ===========================================================================

BBall_Sideways:	; Routine 4
		shortcut
		moveq	#0,d0
		move.b	(v_oscillating_0_to_60).w,d0		; get oscillating value
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip
		neg.w	d0					; invert if xflipped
		addi.w	#$60,d0

	.noflip:
		move.w	ost_bball_x_start(a0),d1		; get initial x pos
		move.w	d1,d2
		sub.w	d0,d1					; subtract difference
		move.w	d1,ost_x_pos(a0)			; update position
		move.w	d2,d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

BBall_UpDown:	; Routine 6
		shortcut
		moveq	#0,d0
		move.b	(v_oscillating_0_to_60).w,d0		; get oscillating value
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip
		neg.w	d0					; invert if xflipped
		addi.w	#$80,d0

	.noflip:
		move.w	ost_bball_y_start(a0),d1		; get initial y pos
		sub.w	d0,d1					; subtract difference
		move.w	d1,ost_y_pos(a0)			; update position
		bra.w	DespawnQuick
; ===========================================================================

BBall_Circle:	; Routine 8
		shortcut
		move.w	ost_bball_speed(a0),d0			; get rotation speed
		add.w	d0,ost_angle(a0)			; add to angle
		move.b	ost_angle(a0),d0
		jsr	(CalcSine).l				; convert angle to sine
		move.w	ost_bball_y_start(a0),d2
		move.w	ost_bball_x_start(a0),d3
		moveq	#0,d4
		move.b	ost_bball_radius(a0),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,ost_y_pos(a0)			; update position
		move.w	d5,ost_x_pos(a0)
		move.w	d3,d0
		bra.w	DespawnQuick_AltX
