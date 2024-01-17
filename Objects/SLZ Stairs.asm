; ---------------------------------------------------------------------------
; Object 5B - blocks that form a staircase (SLZ)

; spawned by:
;	ObjPos_SLZ1, ObjPos_SLZ2, ObjPos_SLZ3
;	Staircase

; subtypes:
;	%WWWWTTTT
;	WWWW - wait time after triggering staircase (*0.5 seconds)
;	TTTT - type (see Stair_Types)

type_stair_above:	equ $10					; 0 - forms a staircase when stood on
type_stair_below:	equ $21					; 1 - forms a staircase when hit from below
; ---------------------------------------------------------------------------

Staircase:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Stair_Index(pc,d0.w),d1
		jmp	Stair_Index(pc,d1.w)
; ===========================================================================
Stair_Index:	index *,,2
		ptr Stair_Main
		ptr Stair_ChkTop
		ptr Stair_Wait
		ptr Stair_Drop
		ptr Stair_ChkBtm
		ptr Stair_Jiggle

		rsobj Staircase
ost_stair_x_start:	rs.w 1					; original x-axis position
ost_stair_wait_time:	rs.w 1					; time delay for stairs to move
		rsobjend
		
Stair_Types:	dc.b id_Stair_ChkTop, id_Stair_ChkBtm
		even
; ===========================================================================

Stair_Main:	; Routine 0
		move.w	ost_x_pos(a0),ost_stair_x_start(a0)
		addi.w	#48,ost_x_pos(a0)
		move.l	#Map_Stair,ost_mappings(a0)
		move.w	#0+tile_pal3,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_3,ost_priority(a0)
		move.b	#$40,ost_displaywidth(a0)
		move.b	#$40,ost_width(a0)
		move.b	#$10,ost_height(a0)
		move.b	ost_subtype(a0),d0
		move.b	d0,d1
		andi.w	#$F,d0					; read low nybble of subtype
		move.b	Stair_Types(pc,d0.w),ost_routine(a0)	; get routine id from list
		andi.w	#$F0,d1					; read high nybble of subtype
		lsr.w	#4,d1
		mulu.w	#30,d1					; multiply by 30 (0.5 seconds)
		move.w	d1,ost_stair_wait_time(a0)		; set time delay
		move.w	ost_stair_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

Stair_ChkTop:	; Routine 2
		bsr.w	SolidObject				; detect collision
		andi.b	#solid_top,d1				; is Sonic on top of object?
		beq.s	.no_collision				; if not, branch
		addq.b	#2,ost_routine(a0)			; goto Stair_Wait next
		
	.no_collision:
		move.w	ost_stair_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

Stair_ChkBtm:	; Routine 8
		bsr.w	SolidObject				; detect collision
		andi.b	#solid_bottom,d1			; has Sonic hit bottom of object?
		beq.s	.no_collision				; if not, branch
		addq.b	#2,ost_routine(a0)			; goto Stair_Jiggle next
		
	.no_collision:
		move.w	ost_stair_x_start(a0),d0
		bra.w	DespawnQuick_AltX
; ===========================================================================

Stair_Jiggle:	; Routine $A
		lea	Ani_Stair(pc),a1
		bsr.w	AnimateSprite

Stair_Wait:	; Routine 4
		subq.w	#1,ost_stair_wait_time(a0)		; decrement timer
		bne.w	.wait					; branch if time remains
		btst	#status_platform_bit,ost_status(a0)
		beq.s	.not_on_stair				; branch if Sonic isn't on object
		getsonic					; a1 = OST of Sonic
		addq.w	#2,ost_y_pos(a1)			; move Sonic down 2px so he sticks to the moving stairs
		
	.not_on_stair:
		move.w	ost_stair_x_start(a0),ost_x_pos(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#$10,ost_width(a0)
		move.b	#id_frame_stair_block,ost_frame(a0)	; switch to single block
		move.b	#id_Stair_Drop,ost_routine(a0)		; goto Stair_Drop next
		move.w	#128,ost_stair_wait_time(a0)		; move for 128 frames
		move.b	ost_status(a0),d0
		andi.w	#status_xflip,d0			; read xflip bit from status
		lsl.w	#3,d0					; multiply by 8
		lea	Stair_Speeds(pc,d0.w),a2		; jump to relevant drop speeds
		move.w	(a2)+,ost_y_vel(a0)			; set drop speed for main block
		moveq	#3-1,d1					; load 3 additional blocks
		move.w	ost_stair_x_start(a0),d2
		
	.loop:
		bsr.w	FindNextFreeObj				; a1 = free object slot
		bne.s	.wait
		move.l	#Staircase,ost_id(a1)			; load extra staircase block
		move.b	#id_Stair_Drop,ost_routine(a1)
		move.w	ost_stair_x_start(a0),ost_stair_x_start(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		addi.w	#32,d2					; each block is 32px to the right
		move.w	d2,ost_x_pos(a1)
		move.w	(a2)+,ost_y_vel(a1)
		move.l	ost_mappings(a0),ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.b	ost_priority(a0),ost_priority(a1)
		move.b	#$10,ost_displaywidth(a1)
		move.b	#$10,ost_width(a1)
		move.b	#$10,ost_height(a1)
		move.b	#id_frame_stair_block,ost_frame(a1)
		move.w	ost_stair_wait_time(a0),ost_stair_wait_time(a1)
		dbf	d1,.loop
		
	.wait:
		bsr.w	SolidObject
		move.w	ost_stair_x_start(a0),d0
		bra.w	DespawnQuick_AltX
		
Stair_Speeds:	dc.w $100, $C0, $80, $40
		dc.w $40, $80, $C0, $100
; ===========================================================================

Stair_Drop:	; Routine 6
		subq.w	#1,ost_stair_wait_time(a0)		; decrement timer
		bmi.s	Stair_Stop				; branch if time hits -1
		update_y_pos					; update position
		bsr.w	SolidObject
		move.w	ost_stair_x_start(a0),d0
		bra.w	DespawnQuick_AltX

Stair_Stop:
		shortcut
		bsr.w	SolidObject
		move.w	ost_stair_x_start(a0),d0
		bra.w	DespawnQuick_AltX

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Stair:	index *
		ptr ani_stair_jiggle
		
ani_stair_jiggle:
		dc.w 3
		dc.w id_frame_stair_jiggle1
		dc.w id_frame_stair_jiggle2
		dc.w id_Anim_Flag_Restart
