; ---------------------------------------------------------------------------
; Object 2A - small vertical door (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2
; ---------------------------------------------------------------------------

AutoDoor:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	ADoor_Index(pc,d0.w),d1
		jmp	ADoor_Index(pc,d1.w)
; ===========================================================================
ADoor_Index:	index *,,2
		ptr ADoor_Main
		ptr ADoor_OpenShut
; ===========================================================================

ADoor_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto ADoor_OpenShut next
		move.l	#Map_ADoor,ost_mappings(a0)
		move.w	#tile_Kos_SbzDoorV+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#6,ost_width(a0)
		move.b	#32,ost_height(a0)
		move.b	#4,ost_priority(a0)

ADoor_OpenShut:	; Routine 2
		bsr.w	RangeX
		cmp.w	#64,d1
		bcc.s	ADoor_Close				; branch if Sonic is > 64px away

		tst.w	d0
		bpl.s	ADoor_SonicRight			; branch if Sonic is to the right
		btst	#status_xflip_bit,ost_status(a0)
		bne.s	ADoor_Animate
		bra.s	ADoor_Open

ADoor_Close:
		move.b	#id_ani_autodoor_close,d0		; use "closing"	animation
		bsr.w	NewAnim
		bra.s	ADoor_Animate
		
; ===========================================================================

ADoor_SonicRight:
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	ADoor_Animate

ADoor_Open:
		move.b	#id_ani_autodoor_open,d0		; use "opening" animation if Sonic is on active side of door
		bsr.w	NewAnim		

ADoor_Animate:
		lea	(Ani_ADoor).l,a1
		bsr.w	AnimateSprite
		tst.b	ost_frame(a0)				; is the door open?
		bne.s	.remember				; if yes, branch
		bsr.w	SolidObject

	.remember:
		bra.w	DespawnObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_ADoor:	index *
		ptr ani_autodoor_close
		ptr ani_autodoor_open
		
ani_autodoor_close:
		dc.w 0
		dc.w id_frame_autodoor_open
		dc.w id_frame_autodoor_07
		dc.w id_frame_autodoor_06
		dc.w id_frame_autodoor_05
		dc.w id_frame_autodoor_04
		dc.w id_frame_autodoor_03
		dc.w id_frame_autodoor_02
		dc.w id_frame_autodoor_01
		dc.w id_frame_autodoor_closed
		dc.w id_Anim_Flag_Stop

ani_autodoor_open:
		dc.w 0
		dc.w id_frame_autodoor_closed
		dc.w id_frame_autodoor_01
		dc.w id_frame_autodoor_02
		dc.w id_frame_autodoor_03
		dc.w id_frame_autodoor_04
		dc.w id_frame_autodoor_05
		dc.w id_frame_autodoor_06
		dc.w id_frame_autodoor_07
		dc.w id_frame_autodoor_open
		dc.w id_Anim_Flag_Stop
		even
