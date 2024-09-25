; ---------------------------------------------------------------------------
; Object 0C - flapping door (LZ)

; spawned by:
;	ObjPos_LZ2, ObjPos_LZ3, ObjPos_SBZ3 - subtype 2

; subtypes:
;	%0000RRRR
;	RRRR - open/close rate (*60 for ost_flap_time_master)
; ---------------------------------------------------------------------------

FlapDoor:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Flap_Index(pc,d0.w),d1
		jmp	Flap_Index(pc,d1.w)
; ===========================================================================
Flap_Index:	index *,,2
		ptr Flap_Main
		ptr Flap_Opening
		ptr Flap_Open
		ptr Flap_Open2
		ptr Flap_Closing
		ptr Flap_Closed
		ptr Flap_Closed2

		rsobj FlapDoor
ost_flap_time:		rs.w 1					; time until change
ost_flap_time_master:	rs.w 1					; time between opening/closing
		rsobjend
; ===========================================================================

Flap_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Flap_Opening next
		move.l	#Map_Flap,ost_mappings(a0)
		move.w	#tile_Kos_FlapDoor+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.w	#priority_0,ost_priority(a0)
		move.b	#$28,ost_displaywidth(a0)
		move.b	#StrId_Door,ost_name(a0)
		move.b	#8,ost_width(a0)
		move.b	#32,ost_height(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get object type
		mulu.w	#60,d0					; multiply by 60 (1 second)
		move.w	d0,ost_flap_time_master(a0)		; set flap delay time

Flap_Opening:	; Routine 2
Flap_Closing:	; Routine 8
		lea	Ani_Flap(pc),a1				; animate & goto Flap_Open/Flap_Closed next
		jsr	AnimateSprite
		clr.b	(f_water_tunnel_disable).w		; enable water current tunnel
		cmpi.b	#id_frame_flap_open,ost_frame(a0)
		beq.s	.open					; branch if fully open
		bsr.w	SolidObject
		move.w	ost_x_pos(a0),d0
		sub.w	ost_x_pos(a1),d0
		bmi.w	DespawnQuick				; branch if Sonic is to the right
		move.b	#1,(f_water_tunnel_disable).w		; disable water tunnel
		bra.w	DespawnQuick
		
	.open:
		bsr.w	UnSolid
		bra.w	DespawnQuick
; ===========================================================================

Flap_Open:	; Routine 4
		move.w	ost_flap_time_master(a0),ost_flap_time(a0) ; reset time delay
		addq.b	#2,ost_routine(a0)			; goto Flap_Open2 next

Flap_Open2:	; Routine 6
		subq.w	#1,ost_flap_time(a0)			; decrement time delay
		bpl.w	DespawnQuick				; branch if time remains
		move.b	#id_ani_flap_closing,ost_anim(a0)
		addq.b	#2,ost_routine(a0)			; goto Flap_Closing next
		tst.b	ost_render(a0)
		bpl.w	DespawnQuick				; branch if not on screen
		play.w	1, jsr, sfx_Door			; play door sound
		bra.w	DespawnQuick
; ===========================================================================

Flap_Closed:	; Routine $A
		move.w	ost_flap_time_master(a0),ost_flap_time(a0) ; reset time delay
		addq.b	#2,ost_routine(a0)			; goto Flap_Closed2 next

Flap_Closed2:	; Routine $C
		bsr.w	SolidObject
		subq.w	#1,ost_flap_time(a0)			; decrement time delay
		bpl.w	DespawnQuick				; branch if time remains
		move.b	#id_ani_flap_opening,ost_anim(a0)
		move.b	#id_Flap_Opening,ost_routine(a0)	; goto Flap_Opening next
		tst.b	ost_render(a0)
		bpl.w	DespawnQuick				; branch if not on screen
		play.w	1, jsr, sfx_Door			; play door sound
		bra.w	DespawnQuick

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Flap:	index *
		ptr ani_flap_opening
		ptr ani_flap_closing
		
ani_flap_opening:
		dc.w 3
		dc.w id_frame_flap_closed
		dc.w id_frame_flap_halfway
		dc.w id_frame_flap_open
		dc.w id_Anim_Flag_Routine

ani_flap_closing:
		dc.w 3
		dc.w id_frame_flap_open
		dc.w id_frame_flap_halfway
		dc.w id_frame_flap_closed
		dc.w id_Anim_Flag_Routine
