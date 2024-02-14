; ---------------------------------------------------------------------------
; Object 22 - Buzz Bomber enemy	(GHZ, MZ, SYZ)

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3
; ---------------------------------------------------------------------------

BuzzBomber:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Buzz_Index(pc,d0.w),d1
		jmp	Buzz_Index(pc,d1.w)
; ===========================================================================
Buzz_Index:	index *,,2
		ptr Buzz_Main
		ptr Buzz_Fly
		ptr Buzz_Wait
		ptr Buzz_Fire
		ptr Buzz_Escape

		rsobj BuzzBomber
ost_buzz_wait_time:	rs.w 1					; time delay for each action (2 bytes)
		rsobjend
; ===========================================================================

Buzz_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Buzz_Fly next
		move.l	#Map_Buzz,ost_mappings(a0)
		move.w	(v_tile_buzzbomber).w,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.b	#priority_3,ost_priority(a0)
		move.b	#id_React_Enemy,ost_col_type(a0)
		move.b	#24,ost_col_width(a0)
		move.b	#12,ost_col_height(a0)
		move.b	#$18,ost_displaywidth(a0)
		move.b	#id_frame_buzz_fly3,ost_frame(a0)	; use frame with exhaust flame
		move.w	#-$400,ost_x_vel(a0)			; move Buzz Bomber to the left
		btst	#status_xflip_bit,ost_status(a0)
		beq.s	Buzz_Fly				; branch if facing left
		neg.w	ost_x_vel(a0)				; move Buzz Bomber to the right
		bset	#render_xflip_bit,ost_render(a0)

Buzz_Fly:	; Routine 2
		toggleframe	1				; animate
		update_x_pos					; update position
		getsonic					; a1 = OST of Sonic
		range_x_test	96
		bcc.w	DespawnObject				; branch if > 96px from Sonic
		
		addq.b	#2,ost_routine(a0)			; goto Buzz_Wait next
		move.w	#29,ost_buzz_wait_time(a0)		; set timer to half a second
		move.b	#id_frame_buzz_fly1,ost_frame(a0)	; use frame without exhaust flame

Buzz_Wait:	; Routine 4
		toggleframe	1				; animate
		subq.w	#1,ost_buzz_wait_time(a0)		; decrement timer
		bpl.w	DespawnObject				; branch if time remains
		
		addq.b	#2,ost_routine(a0)			; goto Buzz_Fire next
		move.w	#59,ost_buzz_wait_time(a0)		; set timer to 1 second
		move.b	#id_frame_buzz_fire1,ost_frame(a0)	; use firing animation
		bsr.w	FindFreeObj
		bne.s	Buzz_Fire
		move.l	#Missile,ost_id(a1)			; load missile object
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		addi.w	#$1C,ost_y_pos(a1)
		move.w	#$200,ost_y_vel(a1)			; move missile downwards
		move.w	#$200,ost_x_vel(a1)			; move missile to the right
		move.w	#$18,d0
		btst	#status_xflip_bit,ost_status(a0)
		bne.s	.noflip					; branch if facing right
		neg.w	d0
		neg.w	ost_x_vel(a1)				; move missile to the left

	.noflip:
		add.w	d0,ost_x_pos(a1)
		move.b	ost_status(a0),ost_status(a1)
		move.b	ost_render(a0),ost_render(a1)
		move.w	#14,ost_missile_wait_time(a1)
		saveparent

Buzz_Fire:	; Routine 6
		toggleframe	1				; animate
		subq.w	#1,ost_buzz_wait_time(a0)		; decrement timer
		bpl.w	DespawnObject				; branch if time remains
		
		addq.b	#2,ost_routine(a0)			; goto Buzz_Escape next
		move.b	#id_frame_buzz_fly3,ost_frame(a0)	; use frame with exhaust flame

Buzz_Escape:	; Routine 8
		shortcut
		toggleframe	1				; animate
		update_x_pos					; update position
		bra.w	DespawnObject
