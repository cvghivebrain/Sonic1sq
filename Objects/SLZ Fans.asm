; ---------------------------------------------------------------------------
; Object 5D - fans (SLZ)

; spawned by:
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SLZ3 - subtypes 0/1
; ---------------------------------------------------------------------------

Fan:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Fan_Index(pc,d0.w),d1
		jmp	Fan_Index(pc,d1.w)
; ===========================================================================
Fan_Index:	index *,,2
		ptr Fan_Main
		ptr Fan_On
		ptr Fan_Off
		ptr Fan_AlwaysOn

		rsobj Fan
ost_fan_wait_time:	rs.w 1					; time between switching on/off
ost_fan_on_time:	rs.w 1					; time switched on
ost_fan_off_time:	rs.w 1					; time switched off
		rsobjend
		
Fan_Settings:	dc.w 180,120,id_Fan_On				; time on, time off, routine id
		dc.w 0,0,id_Fan_AlwaysOn
; ===========================================================================

Fan_Main:	; Routine 0
		move.l	#Map_Fan,ost_mappings(a0)
		move.w	#tile_Kos_Fan+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#4,ost_priority(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0
		mulu.w	#6,d0
		lea	Fan_Settings(pc,d0.w),a2
		move.w	(a2)+,ost_fan_on_time(a0)
		move.w	(a2)+,ost_fan_off_time(a0)
		move.w	(a2)+,d0
		move.b	d0,ost_routine(a0)
		bra.w	DespawnQuick
; ===========================================================================

Fan_On:		; Routine 2
		subq.w	#1,ost_fan_wait_time(a0)		; decrement timer
		bpl.s	Fan_AlwaysOn				; if time remains, branch
		addq.b	#2,ost_routine(a0)			; goto Fan_Off next
		move.w	ost_fan_off_time(a0),ost_fan_wait_time(a0) ; set timer to 2 seconds

Fan_AlwaysOn:	; Routine 6
		tst.w	(v_debug_active).w
		bne.s	.skip_effect				; branch if debug mode is in use
		getsonic					; a1 = OST of Sonic
		range_y_quick
		bpl.s	.skip_effect				; branch if Sonic is below fan
		cmpi.w	#-96,d2
		ble.s	.skip_effect				; branch if Sonic is > 96px above fan
		range_x_quick
		move.b	ost_status(a0),d1
		andi.b	#status_xflip,d1
		bne.s	.facing_right				; branch if fan is facing right
		neg.w	d0
		
	.facing_right:
		cmpi.w	#160,d0
		bge.s	.skip_effect				; branch if > 160px in front of fan
		cmpi.w	#-80,d0
		ble.s	.skip_effect				; branch if > 80px behind fan
		tst.w	d0
		bpl.s	.in_front				; branch if Sonic is in front of fan
		not.w	d0
		add.w	d0,d0					; double fan strength if Sonic is behind
		
	.in_front:
		neg.w	d0
		addi.w	#160,d0
		asr.w	#4,d0
		tst.b	d1
		bne.s	.facing_right2				; branch if fan is facing right
		neg.w	d0
		
	.facing_right2:
		add.w	d0,ost_x_pos(a1)			; push Sonic
		
	.skip_effect:
		lea	Ani_Fan(pc),a1
		jsr	AnimateSprite
		bra.w	DespawnQuick
; ===========================================================================

Fan_Off:	; Routine 4
		subq.w	#1,ost_fan_wait_time(a0)		; decrement timer
		bpl.w	DespawnQuick				; if time remains, branch
		subq.b	#2,ost_routine(a0)			; goto Fan_On next
		move.w	ost_fan_on_time(a0),ost_fan_wait_time(a0) ; set timer to 3 seconds
		bra.w	DespawnQuick
		
; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Fan		index *
		ptr ani_fan_0
		
ani_fan_0:	dc.w 0
		dc.w id_frame_fan_0
		dc.w id_frame_fan_1
		dc.w id_frame_fan_2
		dc.w id_Anim_Flag_Restart
