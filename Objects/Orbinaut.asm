; ---------------------------------------------------------------------------
; Object 60 - Orbinaut enemy (LZ, SLZ, SBZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SLZ3
;	ObjPos_SBZ3

; subtypes:
;	%000000TP
;	T - 1 for passive type
;	P - 1 to use palette line 2
; ---------------------------------------------------------------------------

Orbinaut:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Orb_Index(pc,d0.w),d1
		jmp	Orb_Index(pc,d1.w)
; ===========================================================================
Orb_Index:	index *,,2
		ptr Orb_Main
		ptr Orb_Move
		ptr Orb_Angry
		ptr Orb_Angry2
		
Orb_SpinRates:	dc.b 1,-1
		even
; ===========================================================================

Orb_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Orb_Move next
		move.l	#Map_Orb,ost_mappings(a0)
		move.w	(v_tile_orbinaut).w,ost_tile(a0)
		btst.b	#0,ost_subtype(a0)			; check if low bit of subtype is set
		beq.s	.use_pal1				; if not, branch
		add.w	#tile_pal2,ost_tile(a0)			; use palette 2

	.use_pal1:
		ori.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	#id_col_8x8,ost_col_type(a0)
		move.b	#$C,ost_displaywidth(a0)
		
		moveq	#0,d2					; start angle
		move.w	#-$40,ost_x_vel(a0)			; move orbinaut to the left
		move.b	ost_status(a0),d3
		andi.w	#status_xflip,d3
		beq.s	.noflip					; branch if facing left
		neg.w	ost_x_vel(a0)				; move orbinaut	to the right
		
	.noflip:
		move.b	Orb_SpinRates(pc,d3.w),d3		; get spin rate based on direction orbinaut is facing (1 or -1)
		
		moveq	#4-1,d1					; 4 spiked orbs
	.orb_loop:
		bsr.w	FindNextFreeObj				; find free OST slot
		bne.s	Orb_Move				; branch if not found
		move.l	#OrbSpike,ost_id(a1)			; load spiked orb object
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		ori.b	#render_rel,ost_render(a1)
		move.b	#4,ost_priority(a1)
		move.b	#8,ost_displaywidth(a1)
		move.b	#id_frame_orb_spikeball,ost_frame(a1)
		move.b	#id_col_4x4+id_col_hurt,ost_col_type(a1)
		move.b	d2,ost_angle(a1)			; set position around orbinaut
		addi.b	#$40,d2					; next orb is a quarter circle ahead
		move.b	d3,ost_subtype(a1)			; set spin rate/direction
		saveparent
		dbf	d1,.orb_loop				; repeat sequence 3 more times

Orb_Move:	; Routine 2
		update_x_pos					; update position
		btst.b	#1,ost_subtype(a0)
		bne.w	DespawnObject				; branch if orbinaut is passive
		getsonic					; a1 = OST of Sonic
		range_x
		cmpi.w	#160,d1
		bcc.w	DespawnObject				; branch if Sonic is > 160px from orbinaut
		range_y
		cmpi.w	#80,d3
		bcc.w	DespawnObject				; branch if Sonic is > 80px above/below orbinaut
		tst.w	(v_debug_active).w
		beq.s	.angry					; branch if not in debug mode
		bra.w	DespawnObject
		
	.angry:
		move.b	#4,ost_mode(a0)				; set flag for firing spikeballs
		addq.b	#2,ost_routine(a0)			; goto Orb_Angry next
		move.b	#id_ani_orb_angry,ost_anim(a0)
		bra.w	DespawnObject
; ===========================================================================
		
Orb_Angry:	; Routine 4
		tst.b	ost_mode(a0)
		bne.s	.wait					; don't move until all spikeballs are launched
		update_x_pos
		
	.wait:
		lea	Ani_Orb(pc),a1
		bsr.w	AnimateSprite				; animate & goto Orb_Angry2 next
		bra.w	DespawnObject
; ===========================================================================
		
Orb_Angry2:	; Routine 6
		tst.b	ost_mode(a0)
		bne.w	DespawnObject				; don't move until all spikeballs are launched
		update_x_pos
		bra.w	DespawnObject
		
; ---------------------------------------------------------------------------
; Orbinaut spikeball object

; spawned by:
;	Orbinaut
; ---------------------------------------------------------------------------

OrbSpike:
		getparent					; a1 = OST of parent orbinaut
		cmpi.l	#Orbinaut,ost_id(a1)
		bne.w	DeleteObject				; delete if parent is gone
		tst.b	ost_mode(a1)
		beq.s	.circle					; branch if orbinaut isn't attacking
		cmpi.b	#$40,ost_angle(a0)
		beq.w	OrbSpikeAttack				; branch if spikeball is directly beneath orbinaut
		
	.circle:
		moveq	#0,d0
		move.b	ost_angle(a0),d0			; get angle
		move.b	Orb_X_Table(pc,d0.w),d1
		ext.w	d1
		add.w	ost_x_pos(a1),d1
		move.w	d1,ost_x_pos(a0)
		move.b	Orb_Y_Table(pc,d0.w),d0
		ext.w	d0
		add.w	ost_y_pos(a1),d0
		move.w	d0,ost_y_pos(a0)
		move.b	ost_subtype(a0),d0			; get direction (1 or -1)
		add.b	d0,ost_angle(a0)			; add to angle
		bra.w	DisplaySprite
		
Orb_Y_Table:	hex 000000010101020203030304040505050606060707070808080909090A0A0A0B0B0B0B0C0C0C0C0D0D0D0D0D0E0E0E0E0E0E0F0F0F0F0F0F0F0F0F0F0F0F0F0F
Orb_X_Table:	hex 100F0F0F0F0F0F0F0F0F0F0F0F0F0F0E0E0E0E0E0E0D0D0D0D0D0C0C0C0C0B0B0B0B0A0A0A090909080808070707060606050505040403030302020101010000
		hex 00FFFFFEFEFEFDFDFCFCFCFBFBFBFAFAF9F9F9F8F8F8F7F7F7F6F6F6F5F5F5F5F4F4F4F3F3F3F3F2F2F2F2F2F1F1F1F1F1F1F0F0F0F0F0F0F0F0F0F0F0F0F0F0
		hex F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F1F1F1F1F1F1F2F2F2F2F2F3F3F3F3F4F4F4F5F5F5F5F6F6F6F7F7F7F8F8F8F9F9F9FAFAFBFBFBFCFCFCFDFDFEFEFEFFFF
		hex 000000010101020203030304040505050606060707070808080909090A0A0A0B0B0B0B0C0C0C0C0D0D0D0D0D0E0E0E0E0E0E0F0F0F0F0F0F0F0F0F0F0F0F0F0F
		even
		
OrbSpikeAttack:
		subq.b	#1,ost_mode(a1)				; decrement spikeball counter
		move.w	#-$200,ost_x_vel(a0)			; fire spikeball left
		btst	#status_xflip_bit,ost_status(a1)
		beq.s	.noflip
		neg.w	ost_x_vel(a0)				; fire spikeball right

	.noflip:
		shortcut
		update_x_pos
		tst.b	ost_render(a0)				; is spikeball on-screen?
		bpl.w	DeleteObject				; if not, branch
		bra.w	DisplaySprite

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Orb:	index *
		ptr ani_orb_angry

ani_orb_angry:	dc.w $F
		dc.w id_frame_orb_medium
		dc.w id_frame_orb_angry
		dc.w id_Anim_Flag_Routine
		even
