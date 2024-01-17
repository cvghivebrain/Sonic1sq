; ---------------------------------------------------------------------------
; Object 87 - Sonic on ending sequence

; spawned by:
;	GM_Ending
; ---------------------------------------------------------------------------

EndSonic:
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		move.w	ESon_Index(pc,d0.w),d1
		jsr	ESon_Index(pc,d1.w)
		jmp	(DisplaySprite).l
; ===========================================================================
ESon_Index:	index *,,2
		ptr ESon_Main
		ptr ESon_MakeEmeralds
		ptr ESon_Animate
		ptr ESon_LookUp
		ptr ESon_ClrEmeralds
		ptr ESon_Animate
		ptr ESon_MakeLogo
		ptr ESon_Animate
		ptr ESon_Leap
		ptr ESon_Animate

		rsobj EndSonic
ost_esonic_wait_time:	rs.w 1					; time to wait between events (2 bytes)
ost_esonic_flag:	rs.b 1					; flag set when chaos emeralds stop spinning
		rsobjend
; ===========================================================================

ESon_Main:	; Routine 0
		cmpi.l	#emerald_all,(v_emeralds).w		; do you have all 6 emeralds?
		beq.s	ESon_Main2				; if yes, branch
		addi.b	#id_ESon_Leap,ost_mode(a0)		; else, skip emerald sequence
		move.w	#216,ost_esonic_wait_time(a0)		; set delay to 3.6 seconds
		rts	
; ===========================================================================

ESon_Main2:
		addq.b	#2,ost_mode(a0)				; goto ESon_MakeEmeralds next
		move.l	#Map_ESon,ost_mappings(a0)
		move.w	#tile_Kos_EndSonic,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		clr.b	ost_status(a0)
		move.b	#priority_2,ost_priority(a0)
		move.w	#id_frame_esonic_hold1,ost_frame_hi(a0)
		move.w	#80,ost_esonic_wait_time(a0)		; set delay to 1.3 seconds

ESon_MakeEmeralds:
		; Routine 2
		subq.w	#1,ost_esonic_wait_time(a0)		; decrement timer
		bne.s	.wait					; branch if time remains
		addq.b	#2,ost_mode(a0)				; goto ESon_Animate next
		move.b	#id_ani_esonic_hold,ost_anim(a0)
		move.b	#0,ost_anim_frame(a0)			; reset animation
		move.b	#0,ost_anim_time(a0)
		jsr	FindFreeInert
		bne.s	.wait
		move.l	#EndChaos,ost_id(a1)			; load chaos emeralds objects
		saveparent

	.wait:
		rts	
; ===========================================================================

ESon_LookUp:	; Routine 6
		tst.b	ost_esonic_flag(a0)			; has emerald circle expanded fully?
		beq.s	.wait					; if not, branch
		move.w	#1,(f_restart).w			; set level to restart (causes flash)
		move.w	#90,ost_esonic_wait_time(a0)		; set delay to 1.5 seconds
		addq.b	#2,ost_mode(a0)				; goto ESon_ClrEmeralds next

	.wait:
		rts	
; ===========================================================================

ESon_ClrEmeralds:
		; Routine 8
		subq.w	#1,ost_esonic_wait_time(a0)		; decrement timer
		bne.s	.wait

		move.w	#1,(f_restart).w
		addq.b	#2,ost_mode(a0)				; goto ESon_Animate next
		move.b	#id_ani_esonic_confused,ost_anim(a0)
		move.w	#60,ost_esonic_wait_time(a0)		; set delay to 1 second

	.wait:
		rts	
; ===========================================================================

ESon_MakeLogo:	; Routine $C
		subq.w	#1,ost_esonic_wait_time(a0)		; decrement timer
		bne.s	.wait
		addq.b	#2,ost_mode(a0)				; goto ESon_Animate next
		move.w	#180,ost_esonic_wait_time(a0)		; set delay to 3 seconds
		move.b	#id_ani_esonic_leap,ost_anim(a0)
		jsr	FindFreeInert
		bne.s	.wait
		move.l	#EndSTH,ost_id(a1)			; load "SONIC THE HEDGEHOG" object

	.wait:
		rts	
; ===========================================================================

ESon_Animate:	; Rountine 4, $A, $E, $12
		lea	Ani_ESon(pc),a1
		jmp	(AnimateSprite).l			; increments ost_mode after each animation
; ===========================================================================

ESon_Leap:	; Routine $10
		subq.w	#1,ost_esonic_wait_time(a0)		; decrement timer
		bne.s	.wait
		addq.b	#2,ost_mode(a0)				; goto ESon_Animate next
		move.l	#Map_ESon,ost_mappings(a0)
		move.w	#tile_Kos_EndSonic,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		clr.b	ost_status(a0)
		move.b	#priority_2,ost_priority(a0)
		move.w	#id_frame_esonic_leap1,ost_frame_hi(a0)
		move.b	#id_ani_esonic_leap,ost_anim(a0)	; use "leaping" animation
		jsr	FindFreeInert
		bne.s	.wait
		move.l	#EndSTH,ost_id(a1)			; load "SONIC THE HEDGEHOG" object
		bra.s	ESon_Animate

	.wait:
		rts	

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_ESon:	index *
		ptr ani_esonic_hold
		ptr ani_esonic_confused
		ptr ani_esonic_leap

ani_esonic_hold:
		dc.w 3
		dc.w id_frame_esonic_hold2
		dc.w id_frame_esonic_hold1
		dc.w id_frame_esonic_hold2
		dc.w id_frame_esonic_hold1
		dc.w id_frame_esonic_hold2
		dc.w id_frame_esonic_hold1
		dc.w id_frame_esonic_hold2
		dc.w id_frame_esonic_hold1
		dc.w id_frame_esonic_hold2
		dc.w id_frame_esonic_hold1
		dc.w id_frame_esonic_hold2
		dc.w id_frame_esonic_up
		dc.w id_Anim_Flag_Routine2

ani_esonic_confused:
		dc.w 5
		dc.w id_frame_esonic_confused1
		dc.w id_frame_esonic_confused2
		dc.w id_frame_esonic_confused1
		dc.w id_frame_esonic_confused2
		dc.w id_frame_esonic_confused1
		dc.w id_frame_esonic_confused2
		dc.w id_frame_esonic_confused1
		dc.w id_Anim_Flag_Routine2
		even

ani_esonic_leap:
		dc.w 3
		dc.w id_frame_esonic_leap1
		dc.w id_frame_esonic_leap1
		dc.w id_frame_esonic_leap1
		dc.w id_frame_esonic_leap2
		dc.w id_frame_esonic_leap3
		dc.w id_Anim_Flag_Stop
		even
