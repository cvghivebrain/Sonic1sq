; ---------------------------------------------------------------------------
; Object 69 - spinning platforms (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2 - subtypes $80-$83, $90-$9E
; ---------------------------------------------------------------------------

SpinPlatform:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Spin_Index(pc,d0.w),d1
		jmp	Spin_Index(pc,d1.w)
; ===========================================================================
Spin_Index:	index *,,2
		ptr Spin_Main
		ptr Spin_Spinner

		rsobj SpinPlatform
ost_spin_wait_time:	rs.w 1 ; $30				; time until change (2 bytes)
ost_spin_wait_master:	rs.w 1 ; $32				; time between changes (2 bytes)
ost_spin_flag:		rs.b 1 ; $34				; 1 = switch between animations, spinning platforms only
ost_spin_sync:		rs.w 1 ; $36				; bitmask used to synchronise timing: subtype $8x = $3F; subtype $9x = $7F (2 bytes)
		rsobjend
; ===========================================================================

Spin_Main:	; Routine 0
		ori.b	#render_rel,ost_render(a0)
		move.b	#16,ost_displaywidth(a0)
		move.b	#16,ost_width(a0)
		move.b	#7,ost_height(a0)
		addq.b	#2,ost_routine(a0)			; goto Spin_Spinner next
		move.l	#Map_Spin,ost_mappings(a0)
		move.w	#tile_Kos_SpinPlatform,ost_tile(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#id_ani_spin_1,ost_anim(a0)
		moveq	#0,d0
		move.b	ost_subtype(a0),d0			; get object type
		move.w	d0,d1
		andi.w	#$F,d0					; read only low nybble
		mulu.w	#6,d0					; multiply by 6
		move.w	d0,ost_spin_wait_time(a0)
		move.w	d0,ost_spin_wait_master(a0)		; set time delay
		andi.w	#$70,d1					; read high nybble (e.g. $80/$90), ignore high bit ($00/$10)
		addi.w	#$10,d1					; add $10 ($10/$20)
		lsl.w	#2,d1					; multiply by 4 ($40/$80)
		subq.w	#1,d1					; subtract 1 ($3F/$7F)
		move.w	d1,ost_spin_sync(a0)

Spin_Spinner:	; Routine 2
		move.w	(v_frame_counter).w,d0			; read frame counter
		and.w	ost_spin_sync(a0),d0			; apply bitmask ($3F or $7F)
		bne.s	.delay					; branch if not 0
		move.b	#1,ost_spin_flag(a0)			; set flag (occurs every 64 or 128 frames)

	.delay:
		tst.b	ost_spin_flag(a0)			; is flag set?
		beq.s	.animate				; if not, branch
		subq.w	#1,ost_spin_wait_time(a0)		; decrement timer
		bpl.s	.animate				; branch if time remains
		move.w	ost_spin_wait_master(a0),ost_spin_wait_time(a0) ; reset timer
		clr.b	ost_spin_flag(a0)
		bchg	#0,ost_anim(a0)				; restart animation (switches between identical animations)
		bclr	#7,ost_anim(a0)

	.animate:
		lea	(Ani_Spin).l,a1
		jsr	(AnimateSprite).l
		tst.b	ost_frame(a0)				; check	if frame number	0 is displayed
		bne.s	.notsolid2				; if not, branch
		bsr.w	SolidNew
		bra.w	DespawnQuick
; ===========================================================================

.notsolid2:
		btst	#status_platform_bit,ost_status(a0)	; is Sonic on the platform?
		beq.s	.display				; if not, branch
		lea	(v_ost_player).w,a1
		bclr	#status_platform_bit,ost_status(a1)
		bclr	#status_platform_bit,ost_status(a0)
		clr.b	ost_solid(a0)

	.display:
		bra.w	DespawnQuick

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Spin:	index *
		ptr ani_spin_1
		ptr ani_spin_2

ani_spin_1:
		dc.w 1
		dc.w id_frame_spin_flat
		dc.w id_frame_spin_1
		dc.w id_frame_spin_2
		dc.w id_frame_spin_3
		dc.w id_frame_spin_4
		dc.w id_frame_spin_3+afyflip
		dc.w id_frame_spin_2+afyflip
		dc.w id_frame_spin_1+afyflip
		dc.w id_frame_spin_flat+afyflip
		dc.w id_frame_spin_1+afxflip+afyflip
		dc.w id_frame_spin_2+afxflip+afyflip
		dc.w id_frame_spin_3+afxflip+afyflip
		dc.w id_frame_spin_4+afxflip+afyflip
		dc.w id_frame_spin_3+afxflip
		dc.w id_frame_spin_2+afxflip
		dc.w id_frame_spin_1+afxflip
		dc.w id_frame_spin_flat
		dc.w id_Anim_Flag_Back, 1

ani_spin_2:
		dc.w 1
		dc.w id_frame_spin_flat
		dc.w id_frame_spin_1
		dc.w id_frame_spin_2
		dc.w id_frame_spin_3
		dc.w id_frame_spin_4
		dc.w id_frame_spin_3+afyflip
		dc.w id_frame_spin_2+afyflip
		dc.w id_frame_spin_1+afyflip
		dc.w id_frame_spin_flat+afyflip
		dc.w id_frame_spin_1+afxflip+afyflip
		dc.w id_frame_spin_2+afxflip+afyflip
		dc.w id_frame_spin_3+afxflip+afyflip
		dc.w id_frame_spin_4+afxflip+afyflip
		dc.w id_frame_spin_3+afxflip
		dc.w id_frame_spin_2+afxflip
		dc.w id_frame_spin_1+afxflip
		dc.w id_frame_spin_flat
		dc.w id_Anim_Flag_Back, 1
		even
