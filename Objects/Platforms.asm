; ---------------------------------------------------------------------------
; Object 18 - platforms	(GHZ, SYZ, SLZ)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3 
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3
;	ObjPos_SLZ2, ObjPos_SLZ3

; subtypes:
;	%FFFFTTTT
;	FFFF - frame id
;	TTTT - type (see Plat_Move)

type_plat_still:	equ id_Plat_Type_Still			; 0 - doesn't move
type_plat_sideways:	equ id_Plat_Type_Sideways		; 1 - moves side-to-side
type_plat_updown:	equ id_Plat_Type_UpDown			; 2 - moves up and down
type_plat_falls:	equ id_Plat_Type_Falls			; 3 - falls when stood on
type_plat_sideways_rev:	equ id_Plat_Type_Sideways_Rev		; 5 - moves side-to-side, reversed
type_plat_updown_rev:	equ id_Plat_Type_UpDown_Rev		; 6 - moves up and down, reversed
type_plat_rises:	equ id_Plat_Type_Rises			; 7 - rises 512 pixels 1 second after a button is pressed
type_plat_updown_large:	equ id_Plat_Type_UpDown_Large+(id_frame_plat_large<<4) ; $A - moves up and down, large column-shaped platform
type_plat_updown_slow:	equ id_Plat_Type_UpDown_Slow		; $B - moves up and down, slow
type_plat_updown_slow_rev: equ id_Plat_Type_UpDown_Slow_Rev	; $C - moves up and down, slow reversed
type_plat_syz:		equ id_frame_plat_syz<<4		; +$20
type_plat_slz:		equ id_frame_plat_slz<<4		; +$30
; ---------------------------------------------------------------------------

BasicPlatform:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Plat_Index(pc,d0.w),d1
		jmp	Plat_Index(pc,d1.w)
; ===========================================================================
Plat_Index:	index *,,2
		ptr Plat_Main
		ptr Plat_Solid
		ptr Plat_Drop

		rsobj BasicPlatform
ost_plat_y_pos:		rs.w 1					; y position ignoring dip when Sonic is on the platform
ost_plat_x_start:	rs.w 1					; original x position
ost_plat_y_start:	rs.w 1					; original y position
ost_plat_wait_time:	rs.w 1					; time delay for platform moving when stood on
		rsobjend
; ===========================================================================

Plat_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Plat_Solid next
		move.w	#0+tile_pal3,ost_tile(a0)
		move.l	#Map_Platform,ost_mappings(a0)
		move.b	#$20,ost_displaywidth(a0)
		move.b	#StrId_Platform,ost_name(a0)
		move.b	#$20,ost_width(a0)
		move.b	#8,ost_height(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_4,ost_priority(a0)
		move.w	ost_y_pos(a0),ost_plat_y_pos(a0)
		move.w	ost_y_pos(a0),ost_plat_y_start(a0)
		move.w	ost_x_pos(a0),ost_plat_x_start(a0)
		move.b	ost_subtype(a0),d0
		move.b	d0,d1
		lsr.b	#4,d0					; read high nybble
		move.b	d0,ost_frame(a0)			; set as frame
		andi.b	#$F,d1					; read low nybble
		add.b	d1,d1					; double it
		move.b	d1,ost_subtype(a0)

Plat_Solid:	; Routine 2
		move.w	ost_x_pos(a0),ost_x_prev(a0)
		bsr.w	Plat_Move				; move platform
		move.w	ost_plat_y_pos(a0),d0
		jsr	Sink					; platform dips when stood on
		bsr.w	SolidObjectTop
		move.w	ost_plat_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

Plat_Drop:	; Routine 4
		bsr.w	UnSolid
		shortcut
		update_y_fall					; update position & apply gravity
		move.w	ost_y_vel(a0),ost_y_vel(a1)		; pull Sonic down with platform
		move.w	(v_boundary_bottom).w,d0
		addi.w	#screen_height,d0
		cmp.w	ost_y_pos(a0),d0
		bcs.w	DeleteObject				; branch if platform moves out of level
		bra.w	DisplaySprite

; ---------------------------------------------------------------------------
; Subroutine to	move platforms
; ---------------------------------------------------------------------------

Plat_Move:
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; subtypes have been doubled
		move.w	.index(pc,d0.w),d1
		jmp	.index(pc,d1.w)

; ===========================================================================
.index:		index *
		ptr Plat_Type_Still				; 0
		ptr Plat_Type_Sideways				; 1
		ptr Plat_Type_UpDown				; 2
		ptr Plat_Type_Falls				; 3
		ptr Plat_Type_Falls_Now				; 4
		ptr Plat_Type_Sideways_Rev			; 5
		ptr Plat_Type_UpDown_Rev			; 6
		ptr Plat_Type_Rises				; 7
		ptr Plat_Type_Rises_Now				; 8
		ptr Plat_Type_Still				; 9
		ptr Plat_Type_UpDown_Large			; $A
		ptr Plat_Type_UpDown_Slow			; $B
		ptr Plat_Type_UpDown_Slow_Rev			; $C
; ===========================================================================

; Type 0
; Type 9
Plat_Type_Still:
		rts						; platform 00 doesn't move
; ===========================================================================

; Type 5
Plat_Type_Sideways_Rev:
		move.w	ost_plat_x_start(a0),d0
		move.b	(v_oscillating_0_to_80_fast).w,d1	; load platform-motion variable
		neg.b	d1					; reverse platform-motion
		addi.b	#$40,d1
		bra.s	Plat_Type_Sideways_Move
; ===========================================================================

; Type 1
Plat_Type_Sideways:
		move.w	ost_plat_x_start(a0),d0
		move.b	(v_oscillating_0_to_80_fast).w,d1	; load platform-motion variable
		subi.b	#$40,d1

	Plat_Type_Sideways_Move:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,ost_x_pos(a0)			; change position on x-axis
		rts
; ===========================================================================

; Type $C
Plat_Type_UpDown_Slow_Rev:
		move.w	ost_plat_y_start(a0),d0
		move.b	(v_oscillating_0_to_60).w,d1		; load platform-motion variable
		neg.b	d1					; reverse platform-motion
		addi.b	#$30,d1
		bra.s	Plat_Type_UpDown_Move
; ===========================================================================

; Type $B
Plat_Type_UpDown_Slow:
		move.w	ost_plat_y_start(a0),d0
		move.b	(v_oscillating_0_to_60).w,d1		; load platform-motion variable
		subi.b	#$30,d1
		bra.s	Plat_Type_UpDown_Move
; ===========================================================================

; Type 6
Plat_Type_UpDown_Rev:
		move.w	ost_plat_y_start(a0),d0
		move.b	(v_oscillating_0_to_80_fast).w,d1	; load platform-motion variable
		neg.b	d1					; reverse platform-motion
		addi.b	#$40,d1
		bra.s	Plat_Type_UpDown_Move
; ===========================================================================

; Type 2
Plat_Type_UpDown:
		move.w	ost_plat_y_start(a0),d0
		move.b	(v_oscillating_0_to_80_fast).w,d1	; load platform-motion variable
		subi.b	#$40,d1

	Plat_Type_UpDown_Move:
		ext.w	d1
		add.w	d1,d0
		move.w	d0,ost_plat_y_pos(a0)			; change position on y-axis
		rts
; ===========================================================================

; Type 3
Plat_Type_Falls:
		tst.w	ost_plat_wait_time(a0)			; is time delay set?
		bne.s	.type03_wait				; if yes, branch
		btst	#status_platform_bit,ost_status(a0)	; is Sonic standing on the platform?
		beq.s	.type03_nomove				; if not, branch
		move.w	#30,ost_plat_wait_time(a0)		; set time delay to 0.5 seconds

	.type03_nomove:
		rts	

	.type03_wait:
		subq.w	#1,ost_plat_wait_time(a0)		; decrement timer
		bne.s	.type03_nomove				; branch if time remains
		move.w	#32,ost_plat_wait_time(a0)
		addq.b	#2,ost_subtype(a0)			; change to type 04 (falling)
		rts	
; ===========================================================================

; Type 4
Plat_Type_Falls_Now:
		subq.w	#1,ost_plat_wait_time(a0)		; decrement timer
		bpl.s	.wait					; branch if time remains
		move.b	#id_Plat_Drop,ost_routine(a0)		; goto Plat_Drop next

	.wait:
		rts
; ===========================================================================

; Type 7
Plat_Type_Rises:
		tst.w	ost_plat_wait_time(a0)			; is time delay set?
		bne.s	.type07_wait				; if yes, branch
		tst.b	(v_button_state).w			; has button 0 been pressed?
		beq.s	.type07_nomove				; if not, branch
		move.w	#60,ost_plat_wait_time(a0)		; set time delay to 1 second

	.type07_nomove:
		rts	

	.type07_wait:
		subq.w	#1,ost_plat_wait_time(a0)		; subtract 1 from time delay
		bne.s	.type07_nomove				; if time is > 0, branch
		addq.b	#2,ost_subtype(a0)			; change to type 08
		rts	
; ===========================================================================

; Type 8
Plat_Type_Rises_Now:
		subq.w	#2,ost_plat_y_pos(a0)			; move platform up
		move.w	ost_plat_y_start(a0),d0
		subi.w	#$200,d0
		cmp.w	ost_plat_y_pos(a0),d0			; has platform moved $200 pixels?
		bne.s	.type08_nostop				; if not, branch
		clr.b	ost_subtype(a0)				; change to type 00 (stop moving)

	.type08_nostop:
		rts	
; ===========================================================================

; Type $A
Plat_Type_UpDown_Large:
		move.w	ost_plat_y_start(a0),d0
		move.b	(v_oscillating_0_to_80_fast).w,d1	; load platform-motion variable
		subi.b	#$40,d1
		ext.w	d1
		asr.w	#1,d1
		add.w	d1,d0
		move.w	d0,ost_plat_y_pos(a0)			; change position on y-axis
		rts
