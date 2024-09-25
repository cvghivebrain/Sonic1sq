; ---------------------------------------------------------------------------
; Trapdoors (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2 - subtypes 1/2

; subtypes:
;	%0000TTTT
;	TTTT - time in seconds between opening/closing
; ---------------------------------------------------------------------------

Trapdoor:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Trap_Index(pc,d0.w),d1
		jmp	Trap_Index(pc,d1.w)
; ===========================================================================
Trap_Index:	index *,,2
		ptr Trap_Main
		ptr Trap_Wait
		ptr Trap_Open
		ptr Trap_Wait2
		ptr Trap_Close

		rsobj Trapdoor
ost_trap_wait_time:	rs.w 1					; time until change
ost_trap_wait_master:	rs.w 1					; time between changes
		rsobjend
; ===========================================================================

Trap_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Trap_Wait next
		move.l	#Map_Trap,ost_mappings(a0)
		move.w	#tile_Kos_TrapDoor+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.w	#priority_0,ost_priority(a0)
		move.b	#$80,ost_displaywidth(a0)
		move.b	#StrId_Trapdoor,ost_name(a0)
		move.b	#64,ost_width(a0)
		move.b	#12,ost_height(a0)
		move.b	ost_subtype(a0),d0			; get subtype
		andi.w	#$F,d0					; read only low nybble
		mulu.w	#60,d0					; multiply by 60 (1 second)
		subq.w	#6,d0					; subtract animation duration
		move.w	d0,ost_trap_wait_master(a0)
		move.w	ost_trap_wait_master(a0),ost_trap_wait_time(a0)

Trap_Wait:	; Routine 2
		subq.w	#1,ost_trap_wait_time(a0)		; decrement timer
		bmi.s	.open					; branch if time hits -1
		bsr.w	SolidObject
		bra.w	DespawnQuick
		
	.open:
		addq.b	#2,ost_routine(a0)			; goto Trap_Open next
		bsr.w	UnSolid
		tst.b	ost_render(a0)
		bpl.s	.no_sound				; branch if off screen
		play.w	1, jsr, sfx_Door			; play door sound
		
	.no_sound:
		move.b	#id_ani_trap_open,ost_anim(a0)

Trap_Open:	; Routine 4
		lea	Ani_Trap(pc),a1
		jsr	AnimateSprite
		cmpi.b	#id_frame_trap_open,ost_frame(a0)
		bne.w	DespawnQuick				; branch if animation isn't finished
		addq.b	#2,ost_routine(a0)			; goto Trap_Wait2 next
		move.w	ost_trap_wait_master(a0),ost_trap_wait_time(a0) ; reset timer
		bra.w	DespawnQuick
; ===========================================================================

Trap_Wait2:	; Routine 6
		subq.w	#1,ost_trap_wait_time(a0)
		bmi.s	.close					; branch if time hits -1
		bra.w	DespawnQuick
		
	.close:
		addq.b	#2,ost_routine(a0)			; goto Trap_Close next
		tst.b	ost_render(a0)
		bpl.s	.no_sound				; branch if off screen
		play.w	1, jsr, sfx_Door			; play door sound
		
	.no_sound:
		move.b	#id_ani_trap_close,ost_anim(a0)

Trap_Close:	; Routine 8
		lea	Ani_Trap(pc),a1
		jsr	AnimateSprite
		cmpi.b	#id_frame_trap_closed,ost_frame(a0)
		bne.w	DespawnQuick				; branch if animation isn't finished
		move.b	#id_Trap_Wait,ost_routine(a0)		; goto Trap_Wait next
		move.w	ost_trap_wait_master(a0),ost_trap_wait_time(a0) ; reset timer
		bra.w	DespawnQuick
		
; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Trap:	index *
		ptr ani_trap_open
		ptr ani_trap_close
		
ani_trap_open:
		dc.w 3
		dc.w id_frame_trap_closed
		dc.w id_frame_trap_half
		dc.w id_frame_trap_open
		dc.w id_Anim_Flag_Stop

ani_trap_close:
		dc.w 3
		dc.w id_frame_trap_open
		dc.w id_frame_trap_half
		dc.w id_frame_trap_closed
		dc.w id_Anim_Flag_Stop
