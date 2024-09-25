; ---------------------------------------------------------------------------
; Object 69 - spinning platforms (SBZ)

; spawned by:
;	ObjPos_SBZ1, ObjPos_SBZ2

; subtypes:
;	%00MMDDDD
;	MM - bitmask id for triggering spin (0 = every 64 frame; 1 = 128th frame)
;	DDDD - delay after spin is triggered (*6 frames)

type_spin_wait32:	equ 0					; spin every 32 frames
type_spin_wait64:	equ $10					; spin every 64 frames
type_spin_wait128:	equ $20					; spin every 128 frames
type_spin_wait256:	equ $30					; spin every 256 frames
; ---------------------------------------------------------------------------

SpinPlatform:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Spin_Index(pc,d0.w),d1
		jmp	Spin_Index(pc,d1.w)
; ===========================================================================
Spin_Index:	index *,,2
		ptr Spin_Main
		ptr Spin_Wait
		ptr Spin_Wait2
		ptr Spin_Animate
		ptr Spin_Animate2
		ptr Spin_Reset

		rsobj SpinPlatform
ost_spin_wait_time:	rs.w 1					; time until change
ost_spin_wait_master:	rs.w 1					; time between changes
ost_spin_bitmask:	rs.w 1					; bitmask used to synchronise timing: subtype $8x = $3F; subtype $9x = $7F
		rsobjend
		
Spin_Masks:	dc.w $1F, $3F, $7F, $FF
; ===========================================================================

Spin_Main:	; Routine 0
		ori.b	#render_rel,ost_render(a0)
		move.b	#16,ost_displaywidth(a0)
		move.b	#16,ost_width(a0)
		move.b	#7,ost_height(a0)
		addq.b	#2,ost_routine(a0)			; goto Spin_Wait next
		move.l	#Map_Spin,ost_mappings(a0)
		move.w	#tile_Kos_SpinPlatform,ost_tile(a0)
		move.w	#priority_0,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.b	#StrId_Platform,ost_name(a0)
		move.b	ost_subtype(a0),d0			; get object type
		move.w	d0,d1
		andi.w	#$F,d0					; read only low nybble
		mulu.w	#6,d0					; multiply by 6
		move.w	d0,ost_spin_wait_time(a0)
		move.w	d0,ost_spin_wait_master(a0)		; set time delay
		andi.w	#%00110000,d1				; read bits 4-5
		lsr.b	#3,d1
		move.w	Spin_Masks(pc,d1.w),ost_spin_bitmask(a0) ; get bitmask from list

Spin_Wait:	; Routine 2
		move.w	(v_frame_counter).w,d0			; read frame counter
		and.w	ost_spin_bitmask(a0),d0			; apply bitmask ($3F or $7F)
		beq.s	.next					; branch if 0
		bsr.w	SolidObject
		bra.w	DespawnQuick

	.next:
		addq.b	#2,ost_routine(a0)			; goto Spin_Wait2 next

Spin_Wait2:	; Routine 4
		subq.w	#1,ost_spin_wait_time(a0)		; decrement timer
		bmi.s	.next					; branch if time ran out
		bsr.w	SolidObject
		bra.w	DespawnQuick
		
	.next:
		move.w	ost_spin_wait_master(a0),ost_spin_wait_time(a0) ; reset timer
		addq.b	#2,ost_routine(a0)			; goto Spin_Animate next
		bclr	#7,ost_anim(a0)

Spin_Animate:	; Routine 6
		btst	#status_platform_bit,ost_status(a0)
		beq.s	.not_solid				; branch if not being stood on
		cmpi.b	#id_frame_spin_1,ost_frame(a0)
		bne.s	Spin_Animate2				; branch if not on the first tilted frame
		bsr.w	UnSolid
		
	.not_solid:
		addq.b	#2,ost_routine(a0)			; goto Spin_Animate2 next

Spin_Animate2:	; Routine 8
		lea	Ani_Spin(pc),a1
		jsr	(AnimateSprite).l			; animate and goto Spin_Reset when done
		bra.w	DespawnQuick
; ===========================================================================

Spin_Reset:	; Routine $A
		move.b	#id_Spin_Wait,ost_routine(a0)		; goto Spin_Wait next
		bra.s	Spin_Wait

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Spin:	index *
		ptr ani_spin_1

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
		dc.w id_Anim_Flag_Routine
