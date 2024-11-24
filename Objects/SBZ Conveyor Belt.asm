; ---------------------------------------------------------------------------
; Object 68 - conveyor belts (SBZ)

; spawned by:
;	ObjPos_SBZ2 - subtypes $20/$21/$40/$E0/$E1

; subtypes:
;	%SSSSWWWW
;	SSSS - speed/direction (0-7 = positive/right; 8-$F = negative/left)
;	WWWW - width (see Conv_Widths)
; ---------------------------------------------------------------------------

Conveyor:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Conv_Index(pc,d0.w),d1
		jmp	Conv_Index(pc,d1.w)
; ===========================================================================
Conv_Index:	index *,,2
		ptr Conv_Main
		ptr Conv_Action

		rsobj Conveyor
ost_convey_speed:	rs.w 1					; speed - can also be negative
		rsobjend
		
Conv_Widths:	dc.w 128, 56
; ===========================================================================

Conv_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Conv_Action next
		move.b	#StrId_Conveyor,ost_name(a0)
		move.b	ost_subtype(a0),d1			; get object type
		andi.w	#$F,d1					; read only low nybble
		add.w	d1,d1
		move.w	Conv_Widths(pc,d1.w),ost_width_hi(a0)	; set width from list
		move.b	ost_subtype(a0),d1			; get object type
		andi.b	#$F0,d1					; read only high nybble
		ext.w	d1
		asr.w	#4,d1					; divide by $10
		move.w	d1,ost_convey_speed(a0)			; set belt speed

Conv_Action:	; Routine 2
		tst.w	(v_debug_active).w
		bne.w	DespawnQuick_NoDisplay			; branch if debug mode is in use
		getsonic					; a1 = OST of Sonic
		range_x_quick					; d0 = x dist
		move.w	ost_width_hi(a0),d1
		add.w	d1,d0
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.w	DespawnQuick_NoDisplay			; branch if Sonic is outside x range
		move.w	ost_y_pos(a1),d1
		sub.w	ost_y_pos(a0),d1
		addi.w	#$30,d1
		cmpi.w	#$30,d1
		bcc.w	DespawnQuick_NoDisplay			; branch if not in range on y axis
		btst	#status_air_bit,ost_status(a1)		; is Sonic in the air?
		bne.w	DespawnQuick_NoDisplay			; if yes, branch
		move.w	ost_convey_speed(a0),d0
		add.w	d0,ost_x_pos(a1)			; apply conveyor speed/direction to Sonic
		bra.w	DespawnQuick_NoDisplay
