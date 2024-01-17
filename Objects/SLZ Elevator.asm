; ---------------------------------------------------------------------------
; Object 59 - platforms	that move when you stand on them (SLZ)

; spawned by:
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SLZ3
;	ElevatorMaker

; subtypes:
;	%DDDDTTTT
;	DDDD - distance to move (*128px)
;	TTTT - type of movement (see Elev_Type_Index)

type_elev_up_short:	equ id_Elev_Up+$10			; rises 128px when stood on
type_elev_up_medium:	equ id_Elev_Up+$20			; rises 256px when stood on
type_elev_down_short:	equ id_Elev_Down+$10			; falls 128px when stood on
type_elev_upright:	equ id_Elev_UpRight+$20			; rises diagonally right when stood on
type_elev_up_vanish:	equ id_Elev_UpVanish+$30		; rises when stood on and vanishes
; ---------------------------------------------------------------------------

Elevator:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Elev_Index(pc,d0.w),d1
		jmp	Elev_Index(pc,d1.w)
; ===========================================================================
Elev_Index:	index *,,2
		ptr Elev_Main
		ptr Elev_Solid

		rsobj Elevator
ost_elev_y_start:	rs.w 1					; original y-axis position
ost_elev_x_start:	rs.w 1					; original x-axis position
ost_elev_moved:		rs.l 1					; distance moved
ost_elev_distance:	rs.w 1					; half distance to move
ost_elev_dec_flag:	rs.b 1					; 1 = decelerate
		rsobjend
; ===========================================================================

Elev_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Elev_Solid next
		move.b	#$28,ost_displaywidth(a0)
		move.b	#$28,ost_width(a0)
		move.b	#8,ost_height(a0)
		move.b	ost_subtype(a0),d0			; get subtype
		move.b	d0,d1
		andi.w	#$F0,d0					; read only high nybble
		lsl.w	#2,d0					; multiply by 4
		move.w	d0,ost_elev_distance(a0)		; set distance to move
		andi.b	#$F,d1
		add.b	d1,d1
		move.b	d1,ost_subtype(a0)			; clear high nybble & multiply by 2
		move.l	#Map_Elev,ost_mappings(a0)
		move.w	#0+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_4,ost_priority(a0)
		move.w	ost_x_pos(a0),ost_elev_x_start(a0)
		move.w	ost_y_pos(a0),ost_elev_y_start(a0)

Elev_Solid:	; Routine 2
		shortcut
		move.w	ost_x_pos(a0),ost_x_prev(a0)		; save x pos before moving
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		move.w	Elev_Type_Index(pc,d0.w),d1
		jsr	Elev_Type_Index(pc,d1.w)		; move object
		bsr.w	SolidObject_TopOnly
		move.w	ost_elev_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================
Elev_Type_Index:
		index *
		ptr Elev_Still					; 0 - doesn't move
		ptr Elev_Up					; 1 - rises when stood on
		ptr Elev_Up_Now	
		ptr Elev_Down					; 3 - falls when stood on
		ptr Elev_Down_Now
		ptr Elev_UpRight				; 5 - rises diagonally when stood on
		ptr Elev_UpRight_Now
		ptr Elev_DownLeft				; 7 - falls diagonally when stood on
		ptr Elev_DownLeft_Now
		ptr Elev_UpVanish				; 9 - rises and vanishes
; ===========================================================================

Elev_Still:
		rts	
; ===========================================================================

; Moves when stood on - serves types 1, 3, 5 and 7
Elev_Up:
Elev_Down:
Elev_UpRight:
Elev_DownLeft:
		tst.b	ost_mode(a0)				; check if Sonic is standing on the object
		beq.s	.notstanding
		addq.b	#2,ost_subtype(a0)			; if yes, add 1 to type (goes to 2, 4, 6 or 8)

	.notstanding:
		rts	
; ===========================================================================

; Type 2
Elev_Up_Now:
		bsr.w	Elev_Move				; update distance moved
		move.w	ost_elev_moved(a0),d0			; get distance moved
		neg.w	d0					; invert
		add.w	ost_elev_y_start(a0),d0			; combine with start position
		move.w	d0,ost_y_pos(a0)			; update y position
		rts	
; ===========================================================================

; Type 4
Elev_Down_Now:
		bsr.w	Elev_Move				; update distance moved
		move.w	ost_elev_moved(a0),d0
		add.w	ost_elev_y_start(a0),d0
		move.w	d0,ost_y_pos(a0)			; update y position
		rts	
; ===========================================================================

; Type 6
Elev_UpRight_Now:
		bsr.w	Elev_Move				; update distance moved
		move.w	ost_elev_moved(a0),d0			; get distance moved
		asr.w	#1,d0					; divide by 2
		neg.w	d0					; invert
		add.w	ost_elev_y_start(a0),d0			; combine with start position
		move.w	d0,ost_y_pos(a0)			; update y position (moves half as far as x distance)
		move.w	ost_elev_moved(a0),d0			; get distance moved
		add.w	ost_elev_x_start(a0),d0			; combine with start position
		move.w	d0,ost_x_pos(a0)			; update x position
		rts	
; ===========================================================================

; Type 8
Elev_DownLeft_Now:
		bsr.s	Elev_Move				; update distance moved
		move.w	ost_elev_moved(a0),d0
		asr.w	#1,d0
		add.w	ost_elev_y_start(a0),d0
		move.w	d0,ost_y_pos(a0)
		move.w	ost_elev_moved(a0),d0
		neg.w	d0
		add.w	ost_elev_x_start(a0),d0
		move.w	d0,ost_x_pos(a0)
		rts	
; ===========================================================================

; Type 9
Elev_UpVanish:
		bsr.s	Elev_Move				; update distance moved
		move.w	ost_elev_moved(a0),d0
		neg.w	d0
		add.w	ost_elev_y_start(a0),d0
		move.w	d0,ost_y_pos(a0)
		tst.b	ost_subtype(a0)				; has platform reached destination and stopped?
		beq.s	.typereset				; if yes, branch
		rts	
; ===========================================================================

	.typereset:
		bsr.w	UnSolid_TopOnly
		noreturn					; don't display object
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Subroutine to update the distance moved value
; ---------------------------------------------------------------------------

Elev_Move:
		move.w	ost_y_vel(a0),d0			; get current speed
		tst.b	ost_elev_dec_flag(a0)			; is platform in deceleration phase?
		bne.s	.decelerate				; if yes, branch
		cmpi.w	#$800,d0				; is acceleration at or above max?
		bcc.s	.update_acc				; if yes, branch
		addi.w	#$10,d0					; increase acceleration
		bra.s	.update_acc
; ===========================================================================

.decelerate:
		tst.w	d0					; is acceleration 0?
		beq.s	.update_acc				; if yes, branch
		subi.w	#$10,d0					; decrease acceleration

.update_acc:
		move.w	d0,ost_y_vel(a0)			; set new speed
		ext.l	d0
		asl.l	#8,d0					; multiply by $100
		add.l	ost_elev_moved(a0),d0			; add total previous movement
		move.l	d0,ost_elev_moved(a0)			; update movement
		swap	d0
		move.w	ost_elev_distance(a0),d2		; get target distance
		cmp.w	d2,d0					; has distance been covered?
		bls.s	.dont_dec				; if not, branch
		move.b	#1,ost_elev_dec_flag(a0)		; set deceleration flag

	.dont_dec:
		add.w	d2,d2
		cmp.w	d2,d0					; has complete distance been covered? (including deceleration phase)
		bne.s	.keep_type				; if not, branch
		clr.b	ost_subtype(a0)				; convert to type 0 (non-moving)

	.keep_type:
		rts

; ---------------------------------------------------------------------------
; Platform spawner (SLZ)

; spawned by:
;	ObjPos_SLZ3 - subtype $A
; ---------------------------------------------------------------------------

ElevatorMaker:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	EMake_Index(pc,d0.w),d1
		jmp	EMake_Index(pc,d1.w)
; ===========================================================================
EMake_Index:	index *,,2
		ptr EMake_Main
		ptr EMake_Spawn

		rsobj ElevatorMaker
ost_emake_time:		rs.w 1					; time until next spawn
ost_emake_time_master:	rs.w 1					; time between spawns
		rsobjend
; ===========================================================================

EMake_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto EMake_Spawn next
		moveq	#0,d0
		moveq	#0,d1
		move.b	ost_subtype(a0),d0			; get subtype
		add.w	d0,d0
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0					; multiply by 6
		move.w	d0,ost_emake_time(a0)			; set as time between platform spawns
		move.w	d0,ost_emake_time_master(a0)

EMake_Spawn:	; Routine 2
		shortcut
		subq.w	#1,ost_emake_time(a0)			; decrement timer
		bne.w	DespawnQuick_NoDisplay			; branch if time remains

		move.w	ost_emake_time_master(a0),ost_emake_time(a0) ; reset timer
		bsr.w	FindFreeObj				; find free OST slot
		bne.w	DespawnQuick_NoDisplay			; branch if not found
		move.l	#Elevator,ost_id(a1)			; create elevator object
		move.w	ost_x_pos(a0),ost_x_pos(a1)		; match position
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.b	#type_elev_up_vanish,ost_subtype(a1)	; platform rises and vanishes
		bra.w	DespawnQuick_NoDisplay
