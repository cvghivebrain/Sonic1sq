; ---------------------------------------------------------------------------
; Object 55 - Batbrain enemy (MZ)

; spawned by:
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3
; ---------------------------------------------------------------------------

Batbrain:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Bat_Index(pc,d0.w),d1
		jmp	Bat_Index(pc,d1.w)
; ===========================================================================
Bat_Index:	index *,,2
		ptr Bat_Main
		ptr Bat_Action

		rsobj Batbrain
ost_bat_sonic_y_pos:	rs.w 1 ; $36				; Sonic's y position (2 bytes)
		rsobjend
; ===========================================================================

Bat_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Bat_Action next
		move.l	#Map_Bat,ost_mappings(a0)
		move.w	(v_tile_batbrain).w,ost_tile(a0)
		add.w	#tile_hi,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#$C,ost_height(a0)
		move.b	#2,ost_priority(a0)
		move.b	#id_col_8x8,ost_col_type(a0)
		move.b	#$10,ost_displaywidth(a0)

Bat_Action:	; Routine 2
		moveq	#0,d0
		move.b	ost_mode(a0),d0
		move.w	Bat_Action_Index(pc,d0.w),d1
		jsr	Bat_Action_Index(pc,d1.w)
		lea	(Ani_Bat).l,a1
		bsr.w	AnimateSprite
		bra.w	DespawnObject
; ===========================================================================
Bat_Action_Index:
		index *
		ptr Bat_DropChk
		ptr Bat_DropFly
		ptr Bat_FlapSound
		ptr Bat_FlyUp
; ===========================================================================

Bat_DropChk:
		bsr.w	Range
		tst.w	d2
		bmi.s	.nodrop					; branch if Sonic is above
		cmp.w	#128,d1
		bge.s	.nodrop					; branch if > 128px away
		cmp.w	#128,d3
		bge.s	.nodrop					; branch if > 128px below
		tst.w	(v_debug_active).w
		bne.s	.nodrop					; branch if debug mode is in use

		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		add.b	d7,d0					; add OST index number (so each batbrain updates on a different frame)
		andi.b	#7,d0					; read only bits 0-2
		bne.s	.nodrop					; branch if any are set
		move.b	#id_ani_bat_drop,ost_anim(a0)
		addq.b	#2,ost_mode(a0)			; goto Bat_DropFly next
		bset	#status_xflip_bit,ost_status(a0)	; face right
		tst.w	d0
		bpl.s	.nodrop					; branch if Sonic is right
		bclr	#status_xflip_bit,ost_status(a0)	; face left

	.nodrop:
		rts	
; ===========================================================================

Bat_DropFly:
		bsr.w	SpeedToPos				; update position
		addi.w	#$18,ost_y_vel(a0)			; make batbrain fall
		bsr.w	Range
		tst.w	d2
		bmi.s	.chkdel					; branch if Sonic is above
		cmp.w	#16,d2
		bcc.s	.dropmore				; branch if > 16px below
		move.w	#$100,d1				; batbrain will fly right
		btst	#status_xflip_bit,ost_status(a0)
		bne.s	.noflip					; branch if facing right
		neg.w	d1					; batbrain will fly left

	.noflip:
		move.w	d1,ost_x_vel(a0)			; make batbrain fly horizontally
		move.w	#0,ost_y_vel(a0)			; stop batbrain falling
		move.b	#id_ani_bat_fly,ost_anim(a0)
		addq.b	#2,ost_mode(a0)			; goto Bat_FlapSound next

	.dropmore:
		rts	

	.chkdel:
		tst.b	ost_render(a0)
		bpl.w	DeleteObject				; branch if batbrain is off screen
		rts	
; ===========================================================================

Bat_FlapSound:
		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		andi.b	#$F,d0					; read only low nybble
		bne.s	.nosound				; branch if not 0
		play.w	1, jsr, sfx_basaran			; play flapping sound every 16th frame

	.nosound:
		bsr.w	SpeedToPos				; update position
		bsr.w	Range
		cmp.w	#128,d1
		blt.s	.dontflyup				; branch if < 128px away
		move.b	(v_vblank_counter_byte).w,d0		; get byte that increments every frame
		add.b	d7,d0					; add OST index number (so each batbrain updates on a different frame)
		andi.b	#7,d0					; read only bits 0-2
		bne.s	.dontflyup				; branch if any are set
		addq.b	#2,ost_mode(a0)			; goto Bat_FlyUp next

	.dontflyup:
		rts	
; ===========================================================================

Bat_FlyUp:
		bsr.w	SpeedToPos				; update position
		subi.w	#$18,ost_y_vel(a0)			; make batbrain fly upwards
		bsr.w	FindCeilingObj
		tst.w	d1					; has batbrain hit the ceiling?
		bpl.s	.noceiling				; if not, branch
		sub.w	d1,ost_y_pos(a0)			; align to ceiling
		andi.w	#$FFF8,ost_x_pos(a0)			; snap to tile
		clr.w	ost_x_vel(a0)				; stop batbrain moving
		clr.w	ost_y_vel(a0)
		clr.b	ost_anim(a0)
		clr.b	ost_mode(a0)			; goto Bat_DropChk next

	.noceiling:
		rts

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Bat:	index *
		ptr ani_bat_hang
		ptr ani_bat_drop
		ptr ani_bat_fly
		
ani_bat_hang:	dc.w $F
		dc.w id_frame_bat_hanging
		dc.w id_Anim_Flag_Restart
		even

ani_bat_drop:	dc.w $F
		dc.w id_frame_bat_fly1
		dc.w id_Anim_Flag_Restart
		even

ani_bat_fly:	dc.w 3
		dc.w id_frame_bat_fly1
		dc.w id_frame_bat_fly2
		dc.w id_frame_bat_fly3
		dc.w id_frame_bat_fly2
		dc.w id_Anim_Flag_Restart
		even
