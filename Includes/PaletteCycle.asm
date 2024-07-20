; ---------------------------------------------------------------------------
; Palette cycling routine loading subroutine

;	uses d0.w, d1.l, d2.w, d3.w, a0, a1, a2, a3
; ---------------------------------------------------------------------------

PaletteCycle:
		move.l	(v_palcycle_ptr).w,d0
		beq.s	.exit					; branch if pointer was blank
		movea.l	d0,a1
		jmp	(a1)
		
	.exit:
		rts

; ---------------------------------------------------------------------------
; Title screen (referenced from GM_Title)
; ---------------------------------------------------------------------------

PCycle_Title:
		lea	PCycle_Title_Script(pc),a0
		bra.s	PCycle_Run

pcyclescript:	macro time,frames,colours,flags,source,dest
		dc.w time
		dc.w colours
		dc.w flags
		dc.w frames*colours*2
		dc.l source
		dc.l dest
		endm
		
pcyclehead:	macro
		dc.w ((.end-(*+2))/16)-1
		endm

PCycle_Title_Script:
		pcyclehead
		; time between frames, frame count, colour count, flags, source, destination
		pcyclescript 5,4,4,0,Pal_TitleCyc,v_pal_dry_line3+(8*2)
		.end:

; ---------------------------------------------------------------------------
; Green Hill Zone
; ---------------------------------------------------------------------------

PCycle_GHZ:
		lea	PCycle_GHZ_Script(pc),a0

PCycle_Run:
		move.w	(a0)+,d0				; get script count
		lea	(v_palcycle_buffer).w,a1

	.loop:
		subq.w	#1,(a1)					; decrement timer
		bpl.s	.skip					; branch if time remains

		move.w	(a0)+,(a1)+				; reset timer
		move.w	(a0)+,d1				; get colour count
		move.w	d1,d3					; save original colour count
		add.w	d1,d1					; multiply by 2
		move.w	(a0)+,d2				; get flag bitfield
		btst	#0,d2
		beq.s	.no_reverse				; branch if not reversible
		tst.b	(f_convey_reverse).w			; check if reverse flag is set
		beq.s	.no_reverse				; branch if not
		neg.w	d1
		
	.no_reverse:
		add.w	d1,(a1)					; increment counter
		move.w	(a0)+,d1				; get max value
		cmp.w	(a1),d1					; compare current frame with max
		bne.s	.not_at_max				; branch if not at max
		clr.w	(a1)					; reset frame counter
		
	.not_at_max:
		tst.w	(a1)					; check if -ve
		bpl.s	.frame_ok				; branch if not
		sub.w	d3,d1
		sub.w	d3,d1
		move.w	d1,(a1)					; wrap to final frame
		
	.frame_ok:
		movea.l	(a0)+,a2				; palette source
		adda.w	(a1)+,a2				; jump to current position in source
		movea.l	(a0)+,a3				; palette destination
		subq.w	#1,d3					; colour count -1 for loops
		
	.loop_colour:
		move.w	(a2)+,(a3)+				; copy colour
		dbf	d3,.loop_colour				; repeat for number of colours
		dbf	d0,.loop				; repeat for all scripts
		rts
		
	.skip:
		lea	16(a0),a0				; next script
		addq.w	#4,a1					; next time/frame counter
		dbf	d0,.loop				; repeat for all scripts
		rts

PCycle_GHZ_Script:
		pcyclehead
		; time between frames, frame count, colour count, flags, source, destination
		pcyclescript 5,4,4,0,Pal_GHZCyc,v_pal_dry_line3+(8*2)
		.end:

; ---------------------------------------------------------------------------
; Labyrinth Zone
; ---------------------------------------------------------------------------

PCycle_LZ:
		lea	PCycle_LZ_Script(pc),a0
		bra.w	PCycle_Run

PCycle_LZ_Script:
		pcyclehead
		; time between frames, frame count, colour count, flags, source, destination
		pcyclescript 2,4,4,0,Pal_LZCyc1,v_pal_dry_line3+(11*2) ; waterfalls
		pcyclescript 3,3,3,1,Pal_LZCyc2,v_pal_dry_line4+(11*2) ; conveyors
		.end:

PCycle_SBZ3:
		lea	PCycle_SBZ3_Script(pc),a0
		bra.w	PCycle_Run

PCycle_SBZ3_Script:
		pcyclehead
		pcyclescript 2,4,4,0,Pal_SBZ3Cyc1,v_pal_dry_line3+(11*2)
		.end:

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
		pcyclehead
		; time between frames, frame count, colour count, flags, source, destination
		pcyclescript 7,6,1,0,Pal_SLZCyc,v_pal_dry_line3+(11*2) ; blue light
		pcyclescript 7,6,2,0,Pal_SLZCyc+12,v_pal_dry_line3+(13*2) ; red/yellow lights
		.end:

; ---------------------------------------------------------------------------
; Spring Yard Zone
; ---------------------------------------------------------------------------

PCycle_SYZ:
		lea	PCycle_SYZ_Script(pc),a0
		bra.w	PCycle_Run

PCycle_SYZ_Script:
		pcyclehead
		; time between frames, frame count, colour count, flags, source, destination
		pcyclescript 5,4,4,0,Pal_SYZCyc1,v_pal_dry_line4+(7*2) ; yellow light
		pcyclescript 5,4,1,0,Pal_SYZCyc2,v_pal_dry_line4+(11*2) ; red light
		pcyclescript 5,4,1,0,Pal_SYZCyc2+8,v_pal_dry_line4+(13*2) ; blue light
		.end:

; ---------------------------------------------------------------------------
; Scrap Brain Zone
; ---------------------------------------------------------------------------

PCycle_SBZ:
		lea	PCycle_SBZ_Script(pc),a0
		bra.w	PCycle_Run

PCycle_SBZ_Script:
		pcyclehead
		; time between frames, frame count, colour count, flags, source, destination
		pcyclescript 1,3,3,1,Pal_SBZCyc4,v_pal_dry_line3+(12*2) ; conveyor
		pcyclescript 7,8,1,0,Pal_SBZCyc1,v_pal_dry_line3+(8*2) ; lights
		pcyclescript $D,8,1,0,Pal_SBZCyc2,v_pal_dry_line3+(9*2)
		pcyclescript $E,8,1,0,Pal_SBZCyc3,v_pal_dry_line4+(7*2)
		pcyclescript $B,8,1,0,Pal_SBZCyc5,v_pal_dry_line4+(8*2)
		pcyclescript 7,8,1,0,Pal_SBZCyc6,v_pal_dry_line4+(9*2)
		pcyclescript $1C,$10,1,0,Pal_SBZCyc7,v_pal_dry_line4+(15*2)
		pcyclescript 3,3,1,0,Pal_SBZCyc8,v_pal_dry_line4+(12*2)
		pcyclescript 3,3,1,0,Pal_SBZCyc8+2,v_pal_dry_line4+(13*2)
		pcyclescript 3,3,1,0,Pal_SBZCyc8+4,v_pal_dry_line4+(14*2)
		.end:

PCycle_SBZ2:
		lea	PCycle_SBZ2_Script(pc),a0
		bra.w	PCycle_Run

PCycle_SBZ2_Script:
		pcyclehead
		pcyclescript 0,3,3,1,Pal_SBZCyc10,v_pal_dry_line3+(12*2) ; conveyor
		pcyclescript 7,8,1,0,Pal_SBZCyc1,v_pal_dry_line3+(8*2) ; lights
		pcyclescript $D,8,1,0,Pal_SBZCyc2,v_pal_dry_line3+(9*2)
		pcyclescript 9,8,1,0,Pal_SBZCyc9,v_pal_dry_line4+(8*2)
		pcyclescript 7,8,1,0,Pal_SBZCyc6,v_pal_dry_line4+(9*2)
		pcyclescript 3,3,1,0,Pal_SBZCyc8,v_pal_dry_line4+(12*2)
		pcyclescript 3,3,1,0,Pal_SBZCyc8+2,v_pal_dry_line4+(13*2)
		pcyclescript 3,3,1,0,Pal_SBZCyc8+4,v_pal_dry_line4+(14*2)
		.end:
