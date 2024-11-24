; ---------------------------------------------------------------------------
; Event switcher for DynamicLevelEvents (MZ)

; spawned by:
;	ObjPos_MZ1

; subtypes:
;	%HSSSSSSS
;	H - orientation; 1 if horizontal
;	SSSSSSS - size in pixels

type_egate_hori_bit:	equ 7
type_egate_vert:	equ 0
type_egate_hori:	equ 1<<type_egate_hori_bit
; ---------------------------------------------------------------------------

EventGate:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	EGate_Index(pc,d0.w),d1
		jmp	EGate_Index(pc,d1.w)
; ===========================================================================
EGate_Index:	index *,,2
		ptr EGate_Main
		ptr EGate_Enter
		ptr EGate_LeaveLR
		ptr EGate_LeaveUD

		rsobj EventGate
ost_egate_enter_vel:	rs.w 1					; Sonic's speed entering the gate
		rsobjend
; ===========================================================================

EGate_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto EGate_Enter next
		move.b	#StrId_Gate,ost_name(a0)
		moveq	#8,d1
		move.b	ost_subtype(a0),d0
		bpl.s	.vertical				; branch if high bit is 0
		exg	d0,d1
		andi.b	#$7F,d1
		
	.vertical:
		andi.b	#$7F,d0					; read size bits only
		move.b	d0,ost_height(a0)
		move.b	d1,ost_width(a0)

EGate_Enter:	; Routine 2
		getsonic					; a1 = OST of Sonic
		range_x_quick					; d0 = x dist
		move.w	ost_width_hi(a0),d1
		add.w	d1,d0
		add.w	d1,d1
		cmp.w	d1,d0
		bcc.w	DespawnQuick_NoDisplay			; branch if Sonic is outside x range
		range_y_quick					; d2 = y dist
		move.w	ost_height_hi(a0),d1
		add.w	d1,d2
		add.w	d1,d1
		cmp.w	d1,d2
		bcc.w	DespawnQuick_NoDisplay			; branch if Sonic is outside y range
		
		addq.b	#2,ost_routine(a0)			; goto EGate_LeaveLR next
		move.w	ost_x_vel(a1),ost_egate_enter_vel(a0)	; save Sonic's speed
		tst.b	ost_subtype(a0)
		bpl.w	DespawnQuick_NoDisplay			; branch if gate is vertical/upright type
		addq.b	#2,ost_routine(a0)			; goto EGate_LeaveUD next
		move.w	ost_y_vel(a1),ost_egate_enter_vel(a0)
		bra.w	DespawnQuick_NoDisplay
; ===========================================================================

EGate_LeaveLR:	; Routine 4
		getsonic					; a1 = OST of Sonic
		range_x_quick					; d0 = x dist
		move.w	ost_width_hi(a0),d1
		add.w	d1,d0
		add.w	d1,d1
		cmp.w	d1,d0
		bcs.w	DespawnQuick_NoDisplay			; branch if Sonic remains inside gate
		move.w	ost_x_vel(a1),d0			; get Sonic's speed
		move.w	ost_egate_enter_vel(a0),d1
		eor.w	d0,d1					; xor initial speed with current speed
		andi.w	#$8000,d1				; read only sign bit
		bne.s	EGate_Reset				; branch if sign doesn't match (Sonic entered & left gate on same side)
		
		moveq	#2,d2					; value to add to v_dle_routine
		tst.w	d0
		bpl.s	.right					; branch if Sonic is moving right
		neg.b	d2
		
	.right:
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	EGate_Update				; branch if not xflipped
		neg.b	d2
		
EGate_Update:
		add.b	d2,(v_dle_routine).w			; update routine counter
		clr.w	(v_dle_section).w			; reset section counter
		
EGate_Reset:
		move.b	#id_EGate_Enter,ost_routine(a0)		; goto EGate_Enter next
		bra.w	DespawnQuick_NoDisplay
; ===========================================================================

EGate_LeaveUD:	; Routine 6
		getsonic					; a1 = OST of Sonic
		range_y_quick					; d2 = y dist
		move.w	ost_height_hi(a0),d1
		add.w	d1,d2
		add.w	d1,d1
		cmp.w	d1,d2
		bcs.w	DespawnQuick_NoDisplay			; branch if Sonic remains inside gate
		move.w	ost_y_vel(a1),d0			; get Sonic's speed
		move.w	ost_egate_enter_vel(a0),d1
		eor.w	d0,d1					; xor initial speed with current speed
		andi.w	#$8000,d1				; read only sign bit
		bne.s	EGate_Reset				; branch if sign doesn't match (Sonic entered & left gate on same side)
		
		moveq	#2,d2					; value to add to v_dle_routine
		tst.w	d0
		bpl.s	.down					; branch if Sonic is moving down
		neg.b	d2
		
	.down:
		btst	#status_yflip_bit,ost_status(a0)
		beq.s	EGate_Update				; branch if not yflipped
		neg.b	d2
		bra.s	EGate_Update
