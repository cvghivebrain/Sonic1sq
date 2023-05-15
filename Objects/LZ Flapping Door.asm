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
		ptr Flap_OpenClose

		rsobj FlapDoor
ost_flap_time:		rs.w 1					; time until change (2 bytes)
ost_flap_time_master:	rs.w 1					; time between opening/closing (2 bytes)
		rsobjend
; ===========================================================================

Flap_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Flap_OpenClose next
		move.l	#Map_Flap,ost_mappings(a0)
		move.w	#tile_Kos_FlapDoor+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#$28,ost_displaywidth(a0)
		move.b	#8,ost_width(a0)
		move.b	#32,ost_height(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get object type
		mulu.w	#60,d0					; multiply by 60 (1 second)
		move.w	d0,ost_flap_time_master(a0)		; set flap delay time

Flap_OpenClose:	; Routine 2
		shortcut
		subq.w	#1,ost_flap_time(a0)			; decrement time delay
		bpl.s	.wait					; if time remains, branch
		move.w	ost_flap_time_master(a0),ost_flap_time(a0) ; reset time delay
		bchg	#0,ost_anim(a0)				; open/close door
		bclr	#7,ost_anim(a0)				; restart animation
		tst.b	ost_render(a0)
		bpl.s	.wait					; branch if not on screen
		play.w	1, jsr, sfx_Door			; play door sound

	.wait:
		lea	Ani_Flap(pc),a1
		jsr	AnimateSprite
		clr.b	(f_water_tunnel_disable).w		; enable wind tunnel
		cmpi.b	#id_frame_flap_open,ost_frame(a0)
		beq.w	DespawnQuick				; branch if fully open
		
	.closed:
		bsr.w	SolidObject				; make the door	solid
		move.w	ost_x_pos(a1),d0
		move.w	ost_x_pos(a0),d1
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip					; branch if door isn't xflipped
		exg	d0,d1
		
	.noflip:
		cmp.w	d1,d0
		bcc.w	DespawnQuick				; branch if Sonic is on open side of the door
		move.b	#1,(f_water_tunnel_disable).w		; disable wind tunnel
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
		dc.w id_Anim_Flag_Stop

ani_flap_closing:
		dc.w 3
		dc.w id_frame_flap_open
		dc.w id_frame_flap_halfway
		dc.w id_frame_flap_closed
		dc.w id_Anim_Flag_Stop
