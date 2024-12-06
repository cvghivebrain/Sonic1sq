; ---------------------------------------------------------------------------
; Object 6C - vanishing	platforms (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2 - subtypes 0/$40/$80/$C0/$C6/$D6/$E6

; subtypes:
;	%SSSSTTTT
;	SSSS - synchronisation value
;	TTTT - time between vanishing/appearing (0 = approx 2 secs; 6 = approx 15 secs)
; ---------------------------------------------------------------------------

VanishPlatform:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	VanP_Index(pc,d0.w),d1
		jmp	VanP_Index(pc,d1.w)
; ===========================================================================
VanP_Index:	index *,,2
		ptr VanP_Main
		ptr VanP_Sync
		ptr VanP_Wait
		ptr VanP_Appear
		ptr VanP_Solid
		ptr VanP_Vanish
		ptr VanP_Reset

		rsobj VanishPlatform
ost_vanish_wait_time:	rs.w 1					; time until change
ost_vanish_wait_master:	rs.w 1					; time between changes
ost_vanish_sync_sub:	rs.w 1					; value to subtract from framecount for synchronising
ost_vanish_sync_mask:	rs.w 1					; bitmask for synchronising
		rsobjend
; ===========================================================================

VanP_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto VanP_Sync next
		move.l	#Map_VanP,ost_mappings(a0)
		move.w	#tile_Kos_SbzBlock+tile_pal3,ost_tile(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#StrId_Platform,ost_name(a0)
		move.b	#$10,ost_width(a0)
		move.b	#8,ost_height(a0)
		move.w	#priority_4,ost_priority(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get object type
		andi.w	#$F,d0					; read only low nybble
		addq.w	#1,d0					; add 1
		lsl.w	#7,d0					; multiply by $80
		move.w	d0,d1					; copy to d1
		subq.w	#1,d0
		move.w	d0,ost_vanish_wait_time(a0)
		move.w	d0,ost_vanish_wait_master(a0)		; set as time between changes
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get object type
		andi.w	#$F0,d0					; read only high nybble
		addi.w	#$80,d1
		mulu.w	d1,d0
		lsr.l	#8,d0
		move.w	d0,ost_vanish_sync_sub(a0)
		subq.w	#1,d1					; d1 = $FF if type $x0; $3FF if type $x6
		move.w	d1,ost_vanish_sync_mask(a0)

VanP_Sync:	; Routine 2
		move.w	(v_frame_counter).w,d0			; get word that increments every frame
		sub.w	ost_vanish_sync_sub(a0),d0
		and.w	ost_vanish_sync_mask(a0),d0		; apply bitmask
		bne.w	DespawnQuick_NoDisplay			; branch if not 0
		addq.b	#2,ost_routine(a0)			; goto VanP_Wait next

VanP_Wait:	; Routine 4
		subq.w	#1,ost_vanish_wait_time(a0)		; decrement timer
		bpl.w	DespawnQuick_NoDisplay			; branch if time remains
		
		move.w	ost_vanish_wait_master(a0),ost_vanish_wait_time(a0) ; reset timer
		addq.b	#2,ost_routine(a0)			; goto VanP_Appear next
		move.b	#id_ani_vanish_appear,ost_anim(a0)

VanP_Appear:	; Routine 6
		lea	Ani_Van(pc),a1
		jsr	(AnimateSprite).l			; animate & goto VAnP_Solid/VanP_Reset when done
		cmpi.b	#id_frame_vanish_quarter,ost_frame(a0)
		bcc.w	DespawnQuick				; branch if vanished or mostly vanished
		bsr.w	SolidObjectTop
		bra.w	DespawnQuick
; ===========================================================================

VanP_Solid:	; Routine 8
		subq.w	#1,ost_vanish_wait_time(a0)		; decrement timer
		bmi.s	.next					; branch if time hits -1
		bsr.w	SolidObjectTop
		bra.w	DespawnQuick
		
	.next:
		move.w	ost_vanish_wait_master(a0),ost_vanish_wait_time(a0) ; reset timer
		addq.b	#2,ost_routine(a0)			; goto VanP_Vanish next
		move.b	#id_ani_vanish_vanish,ost_anim(a0)
		
VanP_Vanish:	; Routine $A
		lea	Ani_Van(pc),a1
		jsr	(AnimateSprite).l			; animate & goto VanP_Reset when done
		btst	#status_platform_bit,ost_status(a0)
		beq.w	DespawnQuick				; branch if not being stood on
		cmpi.b	#id_frame_vanish_quarter,ost_frame(a0)
		beq.s	.unsolid				; branch if mostly vanished
		bsr.w	SolidObjectTop
		bra.w	DespawnQuick
		
	.unsolid:
		bsr.w	UnSolid
		bra.w	DespawnQuick
; ===========================================================================

VanP_Reset:	; Routine $C
		move.b	#id_VanP_Wait,ost_routine(a0)		; goto VanP_Wait next
		bra.w	VanP_Wait

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Van:	index *
		ptr ani_vanish_vanish
		ptr ani_vanish_appear
		
ani_vanish_vanish:
		dc.w 7
		dc.w id_frame_vanish_whole
		dc.w id_frame_vanish_half
		dc.w id_frame_vanish_quarter
		dc.w id_frame_vanish_gone
		dc.w id_Anim_Flag_Routine

ani_vanish_appear:
		dc.w 7
		dc.w id_frame_vanish_gone
		dc.w id_frame_vanish_quarter
		dc.w id_frame_vanish_half
		dc.w id_frame_vanish_whole
		dc.w id_Anim_Flag_Routine
