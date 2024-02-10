; ---------------------------------------------------------------------------
; Object 42 - Newtron enemy (GHZ)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3

; subtypes:
;	%SSSS00PT
;	SSSS - speed of missile/attack
;	P - 1 to use palette line 2
;	T - type (0 for drop attack; 1 for missile)

type_newt_missile_bit:	equ 0
type_newt_pal2_bit:	equ 1
type_newt_missile:	equ 1<<type_newt_missile_bit		; fires missile
type_newt_drop:		equ 0					; drop attack
type_newt_pal2:		equ 1<<type_newt_pal2_bit		; uses palette 2
type_newt_blue:		equ type_newt_drop
type_newt_green:	equ type_newt_missile+type_newt_pal2
; ---------------------------------------------------------------------------

Newtron:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Newt_Index(pc,d0.w),d1
		jmp	Newt_Index(pc,d1.w)
; ===========================================================================
Newt_Index:	index *,,2
		ptr Newt_Main
		ptr Newt_Range
		ptr Newt_Appear
		ptr Newt_Fire
		ptr Newt_Fire2
		ptr Newt_Delete
		ptr Newt_Range2
		ptr Newt_Appear
		ptr Newt_Drop
		ptr Newt_Drop2
		ptr Newt_Floor
; ===========================================================================

Newt_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Newt_Range next
		move.l	#Map_Newt,ost_mappings(a0)
		move.w	(v_tile_newtron).w,ost_tile(a0)
		move.b	ost_subtype(a0),d0
		btst	#type_newt_pal2_bit,d0
		beq.s	.keep_pal
		addi.w	#tile_pal2,ost_tile(a0)
		
	.keep_pal:
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_4,ost_priority(a0)
		move.b	#$14,ost_displaywidth(a0)
		btst	#type_newt_missile_bit,d0
		bne.s	Newt_Range				; branch if newtron is green missile-firing type
		
		move.b	#$10,ost_height(a0)
		move.b	#8,ost_width(a0)
		move.b	#id_Newt_Range2,ost_routine(a0)		; goto Newt_Range2 next

Newt_Range:	; Routine 2
Newt_Range2:	; Routine $C
		getsonic					; a1 = OST of Sonic
		range_x						; get x dist
		cmpi.w	#128,d1
		bcc.w	DespawnObject				; branch if Sonic is > 128px away
		addq.b	#2,ost_routine(a0)			; goto Newt_Appear next
		move.b	#id_ani_newt_appear,ost_anim(a0)
		bset	#status_xflip_bit,ost_status(a0)
		tst.w	d0
		bpl.w	DespawnObject				; branch if Sonic is to the right
		bclr	#status_xflip_bit,ost_status(a0)	; face towards Sonic
		bra.w	DespawnObject
; ===========================================================================

Newt_Appear:	; Routine 4/$E
		lea	Ani_Newt(pc),a1
		bsr.w	AnimateSprite				; animate & goto Newt_Fire next
		bra.w	DespawnObject
; ===========================================================================

Newt_Fire:	; Routine 6
		move.b	#id_React_Enemy,ost_col_type(a0)
		move.b	#20,ost_col_width(a0)
		move.b	#16,ost_col_height(a0)
		move.b	#id_ani_newt_firing,ost_anim(a0)
		addq.b	#2,ost_routine(a0)			; goto Newt_Fire2 next

Newt_Fire2:	; Routine 8
		lea	Ani_Newt(pc),a1
		bsr.w	AnimateSprite				; animate & goto Newt_Delete next
		tst.b	ost_mode(a0)				; has newtron already fired?
		bne.w	DespawnObject				; if yes, branch
		cmpi.b	#id_frame_newt_firing,ost_frame(a0)	; is animation on firing frame?
		bne.w	DespawnObject				; if not, branch

		move.b	#1,ost_mode(a0)				; set fired flag
		bsr.w	FindFreeObj				; find free OST slot
		bne.w	DespawnObject				; branch if not found
		move.l	#Missile,ost_id(a1)			; load missile object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		subq.w	#8,ost_y_pos(a1)
		move.b	ost_subtype(a0),d0
		andi.w	#$F0,d0					; read high nybble of subtype
		lsl.w	#4,d0
		move.w	d0,ost_x_vel(a1)			; set missile speed (going right)
		move.w	#$14,d0
		btst	#status_xflip_bit,ost_status(a0)	; is newtron facing right?
		bne.s	.noflip					; if yes, branch
		neg.w	d0
		neg.w	ost_x_vel(a1)				; missile goes left

	.noflip:
		add.w	d0,ost_x_pos(a1)
		move.b	ost_status(a0),ost_status(a1)
		move.b	#1,ost_subtype(a1)
		bra.w	DespawnObject
; ===========================================================================

Newt_Drop:	; Routine $10
		move.b	#id_React_Enemy,ost_col_type(a0)
		move.b	#20,ost_col_width(a0)
		move.b	#16,ost_col_height(a0)
		move.b	#id_ani_newt_drop,ost_anim(a0)
		addq.b	#2,ost_routine(a0)			; goto Newt_Drop2 next

Newt_Drop2:	; Routine $12
		lea	Ani_Newt(pc),a1
		bsr.w	AnimateSprite				; animate & goto Newt_Delete next
		cmpi.b	#id_frame_newt_drop1,ost_frame(a0)
		bne.s	.falling				; branch if not on first falling frame
		bset	#status_xflip_bit,ost_status(a0)	; face right
		getsonic					; a1 = OST of Sonic
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0
		bcc.w	DespawnObject				; branch if Sonic is to the right
		bclr	#status_xflip_bit,ost_status(a0)	; face left
		bra.w	DespawnObject
		
	.falling:
		update_y_fall					; update position & apply gravity
		bsr.w	FindFloorObj
		tst.w	d1					; has newtron hit the floor?
		bpl.w	DespawnObject				; if not, branch

		add.w	d1,ost_y_pos(a0)			; align to floor
		move.w	#0,ost_y_vel(a0)			; stop newtron falling
		addq.b	#2,ost_routine(a0)			; goto Newt_Floor next
		move.b	#id_ani_newt_fly1,ost_anim(a0)
		move.b	#8,ost_col_height(a0)
		move.b	ost_subtype(a0),d0
		andi.w	#$F0,d0					; read high nybble of subtype
		lsl.w	#4,d0
		move.w	d0,ost_x_vel(a0)			; move newtron horizontally
		btst	#status_xflip_bit,ost_status(a0)
		bne.w	DespawnObject
		neg.w	ost_x_vel(a0)
		bra.w	DespawnObject
; ===========================================================================

Newt_Floor:	; Routine $14
		update_x_pos					; update position
		bsr.w	FindFloorObj
		cmpi.w	#-8,d1
		blt.s	Newt_FlyAway				; branch if more than 8px below floor
		cmpi.w	#$C,d1
		bge.s	Newt_FlyAway				; branch if more than 11px above floor (also detects a ledge)
		add.w	d1,ost_y_pos(a0)			; align to floor
		lea	Ani_Newt(pc),a1
		bsr.w	AnimateSprite
		bra.w	DespawnObject
; ===========================================================================

Newt_FlyAway:
		shortcut
		update_x_pos					; update position (flies straight)
		lea	Ani_Newt(pc),a1
		bsr.w	AnimateSprite
		bra.w	DespawnObject
; ===========================================================================

Newt_Delete:	; Routine $A
		bra.w	DeleteObject

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Newt:	index *
		ptr ani_newt_appear
		ptr ani_newt_drop
		ptr ani_newt_fly1
		ptr ani_newt_firing
		
ani_newt_appear		dc.w $13
			dc.w id_frame_newt_trans
			dc.w id_frame_newt_norm
			dc.w id_Anim_Flag_Routine
			
ani_newt_drop:		dc.w $13
			dc.w id_frame_newt_drop1
			dc.w id_frame_newt_drop2
			dc.w id_frame_newt_drop3
			dc.w id_Anim_Flag_Stop
			
ani_newt_fly1:		dc.w 2
			dc.w id_frame_newt_fly1a
			dc.w id_frame_newt_fly1b
			dc.w id_Anim_Flag_Restart
			
ani_newt_firing:	dc.w $13
			dc.w id_frame_newt_norm
			dc.w id_frame_newt_firing
			dc.w id_frame_newt_norm
			dc.w id_frame_newt_norm
			dc.w id_frame_newt_trans
			dc.w id_Anim_Flag_Routine
