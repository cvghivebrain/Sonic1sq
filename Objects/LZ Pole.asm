; ---------------------------------------------------------------------------
; Object 0B - pole that	breaks (LZ)

; spawned by:
;	ObjPos_LZ3 - subtype 4
; ---------------------------------------------------------------------------

Pole:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Pole_Index(pc,d0.w),d1
		jmp	Pole_Index(pc,d1.w)
; ===========================================================================
Pole_Index:	index *,,2
		ptr Pole_Main
		ptr Pole_Action
		ptr Pole_Grab
		ptr Pole_Hang
		ptr Pole_Display

		rsobj Pole
ost_pole_time:		rs.w 1					; time between grabbing the pole & breaking (2 bytes)
		rsobjend
; ===========================================================================

Pole_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Pole_Action next
		move.l	#Map_Pole,ost_mappings(a0)
		move.w	#tile_Kos_LzPole+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#priority_4,ost_priority(a0)
		move.b	#id_React_Routine,ost_col_type(a0)
		move.b	#4,ost_col_width(a0)
		move.b	#32,ost_col_height(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get object type
		mulu.w	#60,d0					; multiply by 60 (1 second)
		move.w	d0,ost_pole_time(a0)			; set breakage time

Pole_Action:	; Routine 2
		bra.w	DespawnQuick
; ===========================================================================

Pole_Grab:	; Routine 4
		clr.b	ost_col_type(a0)
		getsonic					; a1 = OST of Sonic
		cmpi.b	#id_Sonic_Hurt,ost_routine(a1)
		bcc.w	DespawnQuick				; branch if Sonic is hurt or dead
		clr.w	ost_x_vel(a1)				; stop Sonic moving
		clr.w	ost_y_vel(a1)
		move.w	ost_x_pos(a0),d0
		addi.w	#$14,d0
		move.w	d0,ost_x_pos(a1)			; align Sonic to pole
		bclr	#status_xflip_bit,ost_status(a1)
		move.b	#id_Hang,ost_anim(a1)			; set Sonic's animation to "hanging"
		move.b	#1,(v_lock_multi).w			; lock controls
		move.b	#1,(f_water_tunnel_disable).w		; disable water tunnel
		addq.b	#2,ost_routine(a0)			; goto Pole_Hang next

Pole_Hang:	; Routine 6
		subq.w	#1,ost_pole_time(a0)			; decrement timer
		bmi.s	Pole_Break				; branch if no time remains
		getsonic					; a1 = OST of Sonic
		move.w	ost_y_pos(a0),d0
		subi.w	#$18,d0					; d0 = y position for top of pole
		move.b	(v_joypad_hold).w,d2
		btst	#bitUp,d2
		beq.s	.not_up					; branch if not pressing up
		
		subq.w	#1,ost_y_pos(a1)			; move Sonic up
		cmp.w	ost_y_pos(a1),d0
		bcs.s	.not_up
		move.w	d0,ost_y_pos(a1)			; keep Sonic from moving beyond top of pole

	.not_up:
		btst	#bitDn,d2
		beq.s	.not_down				; branch if not pressing down
		
		addi.w	#$24,d0					; d0 = y position for bottom of pole
		addq.w	#1,ost_y_pos(a1)			; move Sonic down
		cmp.w	ost_y_pos(a1),d0
		bcc.s	.not_down
		move.w	d0,ost_y_pos(a1)			; keep Sonic from moving beyond bottom of pole

	.not_down:
		move.b	(v_joypad_press).w,d0
		andi.w	#btnABC,d0
		bne.s	Pole_Release				; branch if pressing A/B/C
		bra.w	DisplaySprite
; ===========================================================================
		
Pole_Break:
		move.b	#id_frame_pole_broken,ost_frame(a0)	; break the pole
		
Pole_Release:
		addq.b	#2,ost_routine(a0)			; goto Pole_Display next
		clr.b	(v_lock_multi).w			; enable controls
		clr.b	(f_water_tunnel_disable).w		; enable water tunnel

Pole_Display:	; Routine 8
		shortcut	DespawnQuick
		bra.w	DespawnQuick
