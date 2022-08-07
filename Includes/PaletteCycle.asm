; ---------------------------------------------------------------------------
; Palette cycling routine loading subroutine

;	uses d0, d1, d2, a0, a1, a2, a3
; ---------------------------------------------------------------------------

PaletteCycle:
		movea.l	(v_palcycle_ptr).w,a1
		jmp	(a1)

; ---------------------------------------------------------------------------
; Title screen (referenced from GM_Title)
; ---------------------------------------------------------------------------

PCycle_Title:
		lea	PCycle_Title_Script(pc),a0
		bra.s	PCycle_Run

PCycle_Title_Script:
		dc.w 1-1					; script count
		dc.w 5						; time between changes
		dc.w 4						; number of frames
		dc.b 4						; number of colours to copy
		dc.b 0						; flags: +1 = affected by f_convey_reverse
		dc.l Pal_TitleCyc				; source
		dc.l v_pal_dry_line3+(8*2)			; destination

; ---------------------------------------------------------------------------
; Green Hill Zone
; ---------------------------------------------------------------------------

PCycle_GHZ:
		lea	PCycle_GHZ_Script(pc),a0

PCycle_Run:
		moveq	#0,d0
		move.w	(a0)+,d0				; get script count
		lea	(v_palcycle_buffer).w,a1

	.loop:
		sub.w	#1,(a1)					; decrement timer
		bpl.s	.next					; branch if time remains

		move.w	(a0),(a1)				; reset timer
		moveq	#1,d2
		btst.b	#0,5(a0)				; check for reversibility
		beq.s	.ignore_rev
		tst.b	(f_convey_reverse).w			; check if reverse flag is set
		beq.s	.ignore_rev
		moveq	#-1,d2					; decrement frame counter instead
	.ignore_rev:
		add.w	d2,2(a1)				; increment frame counter
		moveq	#0,d1
		move.w	2(a0),d1				; get frame count
		cmp.w	2(a1),d1				; compare current frame with max
		bne.s	.not_at_max				; branch if not at max
		move.w	#0,2(a1)				; reset frame counter
	.not_at_max:
		tst.w	2(a1)					; check if -1
		bpl.s	.valid_frame				; branch if not
		move.w	d1,2(a1)
		sub.w	#1,2(a1)				; jump to final frame if reversed
	.valid_frame:
		moveq	#0,d1
		move.b	4(a0),d1				; get colour count
		move.w	d1,d2
		add.w	d2,d2
		mulu.w	2(a1),d2				; d2 = position within source
		sub.w	#1,d1					; subtract 1 for loops
		movea.l	6(a0),a2				; get palette data source address
		movea.l	10(a0),a3				; get palette destination RAM address

	.loop_colour:
		move.w	(a2,d2.w),(a3)+				; copy 1 colour
		add.w	#2,d2
		dbf	d1,.loop_colour				; repeat for number of colours

	.next:
		lea	14(a0),a0				; next script
		lea	4(a1),a1				; next timer/frame counter
		dbf	d0,.loop				; repeat for all scripts
		rts

PCycle_GHZ_Script:
		dc.w 1-1					; script count
		dc.w 5						; time between changes
		dc.w 4						; number of frames
		dc.b 4						; number of colours to copy
		dc.b 0						; flags: +1 = affected by f_convey_reverse
		dc.l Pal_GHZCyc					; source
		dc.l v_pal_dry_line3+(8*2)			; destination

; ---------------------------------------------------------------------------
; Labyrinth Zone
; ---------------------------------------------------------------------------

PCycle_LZ:
		lea	PCycle_LZ_Script(pc),a0
		bra.w	PCycle_Run

PCycle_LZ_Script:
		dc.w 4-1					; script count
		; waterfalls
		dc.w 2						; time between changes
		dc.w 4						; number of frames
		dc.b 4						; number of colours to copy
		dc.b 0						; flags: +1 = affected by f_convey_reverse
		dc.l Pal_LZCyc1					; source
		dc.l v_pal_dry_line3+(11*2)			; destination
		; waterfalls - underwater
		dc.w 2
		dc.w 4
		dc.b 4
		dc.b 0
		dc.l Pal_LZCyc1
		dc.l v_pal_water_line3+(11*2)
		; conveyors
		dc.w 3
		dc.w 3
		dc.b 3
		dc.b 1
		dc.l Pal_LZCyc2
		dc.l v_pal_dry_line4+(11*2)
		; conveyors - underwater
		dc.w 3
		dc.w 3
		dc.b 3
		dc.b 1
		dc.l Pal_LZCyc3
		dc.l v_pal_water_line4+(11*2)

PCycle_SBZ3:
		lea	PCycle_SBZ3_Script(pc),a0
		bra.w	PCycle_Run

PCycle_SBZ3_Script:
		dc.w 2-1					; script count
		dc.w 2						; time between changes
		dc.w 4						; number of frames
		dc.b 4						; number of colours to copy
		dc.b 0						; flags: +1 = affected by f_convey_reverse
		dc.l Pal_SBZ3Cyc1				; source
		dc.l v_pal_dry_line3+(11*2)			; destination
		dc.w 2
		dc.w 4
		dc.b 4
		dc.b 0
		dc.l Pal_SBZ3Cyc1
		dc.l v_pal_water_line3+(11*2)

; ---------------------------------------------------------------------------
; Marble Zone
; ---------------------------------------------------------------------------

PCycle_MZ:
		rts	

; ---------------------------------------------------------------------------
; Star Light Zone
; ---------------------------------------------------------------------------

PCycle_SLZ:
		lea	PCycle_SLZ_Script(pc),a0
		bra.w	PCycle_Run

PCycle_SLZ_Script:
		dc.w 2-1					; script count
		; blue light
		dc.w 7						; time between changes
		dc.w 6						; number of frames
		dc.b 1						; number of colours to copy
		dc.b 0						; flags: +1 = affected by f_convey_reverse
		dc.l Pal_SLZCyc					; source
		dc.l v_pal_dry_line3+(11*2)			; destination
		; red/yellow lights
		dc.w 7
		dc.w 6
		dc.b 2
		dc.b 0
		dc.l Pal_SLZCyc+12
		dc.l v_pal_dry_line3+(13*2)

; ---------------------------------------------------------------------------
; Spring Yard Zone
; ---------------------------------------------------------------------------

PCycle_SYZ:
		lea	PCycle_SYZ_Script(pc),a0
		bra.w	PCycle_Run

PCycle_SYZ_Script:
		dc.w 3-1					; script count
		; yellow light
		dc.w 5						; time between changes
		dc.w 4						; number of frames
		dc.b 4						; number of colours to copy
		dc.b 0						; flags: +1 = affected by f_convey_reverse
		dc.l Pal_SYZCyc1				; source
		dc.l v_pal_dry_line4+(7*2)			; destination
		; red light
		dc.w 5
		dc.w 4
		dc.b 1
		dc.b 0
		dc.l Pal_SYZCyc2
		dc.l v_pal_dry_line4+(11*2)
		; blue light
		dc.w 5
		dc.w 4
		dc.b 1
		dc.b 0
		dc.l Pal_SYZCyc2+8
		dc.l v_pal_dry_line4+(13*2)

; ---------------------------------------------------------------------------
; Scrap Brain Zone
; ---------------------------------------------------------------------------

PCycle_SBZ:
		lea	PCycle_SBZ_Script(pc),a0
		bra.w	PCycle_Run

PCycle_SBZ_Script:
		dc.w 10-1					; script count
		; conveyor
		dc.w 1						; time between changes
		dc.w 3						; number of frames
		dc.b 3						; number of colours to copy
		dc.b 1						; flags: +1 = affected by f_convey_reverse
		dc.l Pal_SBZCyc4				; source
		dc.l v_pal_dry_line3+(12*2)			; destination
		; lights
		dc.w 7
		dc.w 8
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc1
		dc.l v_pal_dry_line3+(8*2)
		
		dc.w $D
		dc.w 8
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc2
		dc.l v_pal_dry_line3+(9*2)
		
		dc.w $E
		dc.w 8
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc3
		dc.l v_pal_dry_line4+(7*2)
		
		dc.w $B
		dc.w 8
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc5
		dc.l v_pal_dry_line4+(8*2)
		
		dc.w 7
		dc.w 8
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc6
		dc.l v_pal_dry_line4+(9*2)
		
		dc.w $1C
		dc.w $10
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc7
		dc.l v_pal_dry_line4+(15*2)
		
		dc.w 3
		dc.w 3
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc8
		dc.l v_pal_dry_line4+(12*2)
		
		dc.w 3
		dc.w 3
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc8+2
		dc.l v_pal_dry_line4+(13*2)
		
		dc.w 3
		dc.w 3
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc8+4
		dc.l v_pal_dry_line4+(14*2)

PCycle_SBZ2:
		lea	PCycle_SBZ2_Script(pc),a0
		bra.w	PCycle_Run

PCycle_SBZ2_Script:
		dc.w 8-1					; script count
		; conveyor
		dc.w 0						; time between changes
		dc.w 3						; number of frames
		dc.b 3						; number of colours to copy
		dc.b 1						; flags: +1 = affected by f_convey_reverse
		dc.l Pal_SBZCyc10				; source
		dc.l v_pal_dry_line3+(12*2)			; destination
		; lights
		dc.w 7
		dc.w 8
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc1
		dc.l v_pal_dry_line3+(8*2)
		
		dc.w $D
		dc.w 8
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc2
		dc.l v_pal_dry_line3+(9*2)
		
		dc.w 9
		dc.w 8
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc9
		dc.l v_pal_dry_line4+(8*2)
		
		dc.w 7
		dc.w 8
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc6
		dc.l v_pal_dry_line4+(9*2)
		
		dc.w 3
		dc.w 3
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc8
		dc.l v_pal_dry_line4+(12*2)
		
		dc.w 3
		dc.w 3
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc8+2
		dc.l v_pal_dry_line4+(13*2)
		
		dc.w 3
		dc.w 3
		dc.b 1
		dc.b 0
		dc.l Pal_SBZCyc8+4
		dc.l v_pal_dry_line4+(14*2)
