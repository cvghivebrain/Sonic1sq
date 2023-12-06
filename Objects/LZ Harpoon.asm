; ---------------------------------------------------------------------------
; Object 16 - harpoon (LZ)

; spawned by:
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3, ObjPos_SBZ3 - subtypes 0/2

; subtypes:
;	%RRRRS0AA
;	RRRR - time between animations (+1, *30 for ost_harp_time_master)
;	S - 1 for forced synchronisation (ignores RRRR, changes every 64 frames instead)
;	AA - starting animation (0/1 = horizontal; 2/3 = vertical)
; ---------------------------------------------------------------------------

Harpoon:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Harp_Index(pc,d0.w),d1
		jmp	Harp_Index(pc,d1.w)
; ===========================================================================
Harp_Index:	index *,,2
		ptr Harp_Main
		ptr Harp_Move
		ptr Harp_Wait
		ptr Harp_Move2
		ptr Harp_Wait2

		rsobj Harpoon
ost_harp_time:		rs.w 1					; time between stabbing/retracting (2 bytes)
ost_harp_time_master:	rs.w 1
		rsobjend
; ===========================================================================

Harp_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Harp_Move next
		move.l	#Map_Harp,ost_mappings(a0)
		move.w	#tile_Kos_Harpoon,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#4,ost_priority(a0)
		move.b	ost_subtype(a0),d0
		move.w	d0,d1
		andi.b	#%11,d0					; read bits 0-1 of subtype
		move.b	d0,ost_anim(a0)				; get type (vert/horiz)
		move.b	#$14,ost_displaywidth(a0)
		btst	#3,d1
		beq.s	.no_sync				; branch if not synchronised
		addq.b	#4,ost_routine(a0)			; goto Harp_Move2 next
		bra.s	Harp_Move2
		
	.no_sync:
		lsr.b	#4,d1					; read high nybble of subtype
		addq.b	#1,d1
		mulu.w	#30,d1
		move.w	d1,ost_harp_time_master(a0)		; set timer
		move.w	d1,ost_harp_time(a0)			; set timer with delay

Harp_Move:	; Routine 2
Harp_Move2:	; Routine 6
		lea	Ani_Harp(pc),a1
		bsr.w	AnimateSprite				; animate and goto Harp_Wait next
		cmpi.b	#3,ost_anim_time(a0)
		bne.w	DespawnQuick				; branch if frame hasn't updated
		moveq	#0,d0
		move.b	ost_frame(a0),d0			; get frame number
		move.b	Harp_Hitbox_List(pc,d0.w),ost_col_type(a0) ; get collision type
		bra.w	DespawnQuick

Harp_Hitbox_List:
		dc.b id_col_8x4+id_col_hurt			; horizontal, short
		dc.b id_col_24x4+id_col_hurt			; horizontal, middle
		dc.b id_col_40x4+id_col_hurt			; horizontal, extended
		dc.b id_col_4x8+id_col_hurt			; vertical, short
		dc.b id_col_4x24+id_col_hurt			; vertical, middle
		dc.b id_col_4x40+id_col_hurt			; vertical, extended
		even

Harp_Wait:	; Routine 4
		subq.w	#1,ost_harp_time(a0)			; decrement timer
		bpl.w	DespawnQuick				; branch if time remains
		move.w	ost_harp_time_master(a0),ost_harp_time(a0) ; reset timer
		subq.b	#2,ost_routine(a0)			; goto Harp_Move next
		bchg	#0,ost_anim(a0)				; reverse animation
		bclr	#7,ost_anim(a0)				; restart animation
		bra.w	DespawnQuick
; ===========================================================================

Harp_Wait2:	; Routine 8
		move.b	(v_frame_counter_low).w,d0
		move.b	d0,d2
		andi.b	#%00111111,d0
		bne.w	DespawnQuick				; branch if not on 64th frame
		subq.b	#2,ost_routine(a0)			; goto Harp_Move2 next
		btst	#0,ost_subtype(a0)
		beq.s	.not_inverted
		not.b	d2					; stab/retract are reversed
		
	.not_inverted:
		andi.b	#%01000000,d2
		lsr.b	#6,d2					; get bit 6 from frame counter
		move.b	ost_anim(a0),d0
		andi.b	#%01111110,d0				; clear bits 0 and 7 of anim id
		or.b	d2,d0					; combine with bit from frame counter
		move.b	d0,ost_anim(a0)				; next animation
		bra.w	DespawnQuick

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Harp:	index *
		ptr ani_harp_h_extending
		ptr ani_harp_h_retracting
		ptr ani_harp_v_extending
		ptr ani_harp_v_retracting
		
ani_harp_h_extending:
		dc.w 3
		dc.w id_frame_harp_h_middle
		dc.w id_frame_harp_h_extended
		dc.w id_Anim_Flag_Routine

ani_harp_h_retracting:
		dc.w 3
		dc.w id_frame_harp_h_middle
		dc.w id_frame_harp_h_retracted
		dc.w id_Anim_Flag_Routine

ani_harp_v_extending:
		dc.w 3
		dc.w id_frame_harp_v_middle
		dc.w id_frame_harp_v_extended
		dc.w id_Anim_Flag_Routine

ani_harp_v_retracting:
		dc.w 3
		dc.w id_frame_harp_v_middle
		dc.w id_frame_harp_v_retracted
		dc.w id_Anim_Flag_Routine
