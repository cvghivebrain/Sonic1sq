; ---------------------------------------------------------------------------
; Object 2A - small vertical door (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2

; subtypes:
;	%000000RL
;	R - 1 to open from right side
;	L - 1 to open from left side
		
type_autodoor_left_bit:		equ 0
type_autodoor_right_bit:	equ 1
type_autodoor_left:		equ 1<<type_autodoor_left_bit	; opens from left
type_autodoor_right:		equ 1<<type_autodoor_right_bit	; opens from right
type_autodoor_both:		equ type_autodoor_left+type_autodoor_right
; ---------------------------------------------------------------------------

AutoDoor:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	ADoor_Index(pc,d0.w),d1
		jmp	ADoor_Index(pc,d1.w)
; ===========================================================================
ADoor_Index:	index *,,2
		ptr ADoor_Main
		ptr ADoor_WaitOpen
		ptr ADoor_Open
		ptr ADoor_WaitShut
		ptr ADoor_Shut
		ptr ADoor_Reset
; ===========================================================================

ADoor_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto ADoor_WaitOpen next
		move.l	#Map_ADoor,ost_mappings(a0)
		move.w	#tile_Kos_SbzDoorV+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#6,ost_width(a0)
		move.b	#32,ost_height(a0)
		move.w	#priority_4,ost_priority(a0)

ADoor_WaitOpen:	; Routine 2
		getsonic					; a1 = OST of Sonic
		range_x
		cmpi.w	#64,d1
		bcc.w	DespawnQuick				; branch if > 64px away
		btst.b	#type_autodoor_left_bit,ost_subtype(a0)
		beq.s	.dont_open_left				; branch if door doesn't open from left
		tst.w	d0
		bmi.s	.open_side				; branch if Sonic is on left side
		
	.dont_open_left:
		btst.b	#type_autodoor_right_bit,ost_subtype(a0)
		beq.s	.dont_open_right			; branch if door doesn't open from right
		tst.w	d0
		bpl.s	.open_side				; branch if Sonic is on right side
		
	.dont_open_right:
		bsr.w	SolidObject
		bra.w	DespawnQuick
		
	.open_side:
		addq.b	#2,ost_routine(a0)			; goto ADoor_Open next
		move.b	#id_ani_autodoor_open,ost_anim(a0)
		bsr.w	UnSolid

ADoor_Open:	; Routine 4
		lea	Ani_ADoor(pc),a1
		bsr.w	AnimateSprite				; animate & goto ADoor_WaitShut next
		bra.w	DespawnQuick
; ===========================================================================

ADoor_WaitShut:	; Routine 6
		getsonic					; a1 = OST of Sonic
		range_x_test	64
		bcs.w	DisplaySprite				; branch if < 64px away
		addq.b	#2,ost_routine(a0)			; goto ADoor_Shut next
		move.b	#id_ani_autodoor_close,ost_anim(a0)

ADoor_Shut:	; Routine 8
		lea	Ani_ADoor(pc),a1
		bsr.w	AnimateSprite				; animate & goto ADoor_WaitShut next
		bra.w	DespawnQuick
; ===========================================================================

ADoor_Reset:	; Routine $A
		move.b	#id_ADoor_WaitOpen,ost_routine(a0)	; goto ADoor_WaitOpen next
		bra.w	ADoor_WaitOpen

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_ADoor:	index *
		ptr ani_autodoor_open
		ptr ani_autodoor_close
		
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
		dc.w id_Anim_Flag_Routine

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
		dc.w id_Anim_Flag_Routine
