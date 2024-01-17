; ---------------------------------------------------------------------------
; Object 6D - flame thrower (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2 - subtype $43

; subtypes:
;	%FFFFWWWW
;	FFFF - time flame is on (*32 frames)
;	WWWW - wait time between flames (*32 frames)
; ---------------------------------------------------------------------------

Flamethrower:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Flame_Index(pc,d0.w),d1
		jmp	Flame_Index(pc,d1.w)
; ===========================================================================
Flame_Index:	index *,,2
		ptr Flame_Main
		ptr Flame_On
		ptr Flame_Off
		ptr Flame_Off2

		rsobj Flamethrower
ost_flame_time:		rs.w 1					; time until current action is complete
ost_flame_on_master:	rs.w 1					; time flame is on
ost_flame_off_master:	rs.w 1					; time flame is off
		rsobjend
; ===========================================================================

Flame_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Flame_On next
		move.l	#Map_Flame,ost_mappings(a0)
		move.w	#tile_Kos_FlamePipe+tile_hi,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#priority_1,ost_priority(a0)
		move.b	#$C,ost_displaywidth(a0)
		move.b	#12,ost_col_width(a0)
		move.b	#24,ost_col_height(a0)
		move.b	ost_subtype(a0),d0
		andi.w	#$F0,d0					; read high nybble of type
		add.w	d0,d0					; multiply by 2
		move.w	d0,ost_flame_time(a0)
		move.w	d0,ost_flame_on_master(a0)		; set flaming time
		move.b	ost_subtype(a0),d0
		andi.w	#$F,d0					; read low nybble of type
		lsl.w	#5,d0					; multiply by $20
		move.w	d0,ost_flame_off_master(a0)		; set pause time
		move.b	ost_status(a0),d0
		andi.b	#status_yflip,d0			; get yflip flag (0 or 2)
		move.b	d0,ost_anim(a0)				; use as animation
		play.w	1, jsr, sfx_Flame			; play flame sound

Flame_On:	; Routine 2
		lea	Ani_Flame(pc),a1
		bsr.w	AnimateSprite
		cmpi.b	#20,ost_anim_frame(a0)
		bne.s	.wait_anim				; branch if not at final animation frame
		move.b	#id_React_Hurt,ost_col_type(a0)		; make flame harmful
		
	.wait_anim:
		subq.w	#1,ost_flame_time(a0)			; decrement timer
		bpl.w	DespawnQuick				; if time remains, branch
		move.w	ost_flame_off_master(a0),ost_flame_time(a0) ; begin off time
		bchg	#0,ost_anim(a0)				; switch animation
		bclr	#7,ost_anim(a0)
		addq.b	#2,ost_routine(a0)			; goto Flame_Off next
		move.b	#0,ost_col_type(a0)			; harmless
		bra.w	DespawnQuick
; ===========================================================================

Flame_Off:	; Routine 4
		lea	Ani_Flame(pc),a1
		bsr.w	AnimateSprite

Flame_Off2:	; Routine 6
		subq.w	#1,ost_flame_time(a0)			; decrement timer
		bpl.w	DespawnQuick				; if time remains, branch
		move.w	ost_flame_off_master(a0),ost_flame_time(a0) ; begin off time
		bchg	#0,ost_anim(a0)				; switch animation
		bclr	#7,ost_anim(a0)
		move.b	#id_Flame_On,ost_routine(a0)		; goto Flame_On next
		tst.b	ost_render(a0)
		bpl.w	DespawnQuick				; branch if off screen
		play.w	1, jsr, sfx_Flame			; play flame sound
		bra.w	DespawnQuick

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Flame:	index *
		ptr ani_flame_pipe_on
		ptr ani_flame_pipe_off
		ptr ani_flame_valve_on
		ptr ani_flame_valve_off
		
ani_flame_pipe_on:
		dc.w 3
		dc.w id_frame_flame_pipe1
		dc.w id_frame_flame_pipe2
		dc.w id_frame_flame_pipe3
		dc.w id_frame_flame_pipe4
		dc.w id_frame_flame_pipe5
		dc.w id_frame_flame_pipe6
		dc.w id_frame_flame_pipe7
		dc.w id_frame_flame_pipe8
		dc.w id_frame_flame_pipe9
		dc.w id_frame_flame_pipe10
		dc.w id_frame_flame_pipe11
		dc.w id_Anim_Flag_Back, 2

ani_flame_pipe_off:
		dc.w 0
		dc.w id_frame_flame_pipe10
		dc.w id_frame_flame_pipe8
		dc.w id_frame_flame_pipe6
		dc.w id_frame_flame_pipe4
		dc.w id_frame_flame_pipe2
		dc.w id_frame_flame_pipe1
		dc.w id_Anim_Flag_Routine

ani_flame_valve_on:
		dc.w 3
		dc.w id_frame_flame_valve1
		dc.w id_frame_flame_valve2
		dc.w id_frame_flame_valve3
		dc.w id_frame_flame_valve4
		dc.w id_frame_flame_valve5
		dc.w id_frame_flame_valve6
		dc.w id_frame_flame_valve7
		dc.w id_frame_flame_valve8
		dc.w id_frame_flame_valve9
		dc.w id_frame_flame_valve10
		dc.w id_frame_flame_valve11
		dc.w id_Anim_Flag_Back, 2

ani_flame_valve_off:
		dc.w 0
		dc.w id_frame_flame_valve10
		dc.w id_frame_flame_valve8
		dc.w id_frame_flame_valve7
		dc.w id_frame_flame_valve5
		dc.w id_frame_flame_valve3
		dc.w id_frame_flame_valve1
		dc.w id_Anim_Flag_Routine
