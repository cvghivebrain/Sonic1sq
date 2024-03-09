; ---------------------------------------------------------------------------
; Forced roll tunnel gate

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3
; ---------------------------------------------------------------------------

RollTunnel:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	RollT_Index(pc,d0.w),d1
		jmp	RollT_Index(pc,d1.w)
; ===========================================================================
RollT_Index:	index *,,2
		ptr RollT_Main
		ptr RollT_Detect
		ptr RollT_Leave
		
rollt_width:	equ 8
rollt_height:	equ 16
; ===========================================================================

RollT_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto RollT_Detect next
		move.b	#rollt_width,ost_width(a0)
		move.b	#rollt_height,ost_height(a0)

RollT_Detect:	; Routine 2
		getsonic					; a1 = OST of Sonic
		range_x_test	rollt_width
		bcc.w	DespawnQuick_NoDisplay			; branch if Sonic isn't touching
		range_y_test	rollt_height
		bcc.w	DespawnQuick_NoDisplay
		tst.w	(v_debug_active).w
		bne.w	DespawnQuick_NoDisplay			; branch if using debug mode
		
		addq.b	#2,ost_routine(a0)			; goto RollT_Leave next
		
RollT_Direction:
		move.w	ost_x_vel(a1),d0
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	.noflip					; branch if not xflipped
		neg.w	d0
		
	.noflip:
		bset	#flags_forceroll_bit,ost_sonic_flags(a1) ; make Sonic roll
		tst.w	d0
		bpl.w	DespawnQuick_NoDisplay			; branch if Sonic approached from open side
		bclr	#flags_forceroll_bit,ost_sonic_flags(a1) ; stop Sonic rolling
		bra.w	DespawnQuick_NoDisplay
; ===========================================================================

RollT_Leave:	; Routine 4
		getsonic					; a1 = OST of Sonic
		range_x_test	rollt_width
		bcc.w	.leave					; branch if Sonic isn't touching
		range_y_test	rollt_height
		bcs.w	DespawnQuick_NoDisplay
		
	.leave:
		subq.b	#2,ost_routine(a0)			; goto RollT_Detect next
		bra.s	RollT_Direction
