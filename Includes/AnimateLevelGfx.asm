; ---------------------------------------------------------------------------
; Subroutine to	load uncompressed gfx for level animations & giant ring

;	uses d0.l, d1.l, d2.l, d3.l, d4.w, a1, a2, a3, a4
; ---------------------------------------------------------------------------

AnimateLevelGfx:
		tst.w	(f_pause).w				; is the game paused?
		bne.s	.exit					; if yes, branch
		move.l	(v_aniart_ptr).w,d0
		beq.s	.exit					; branch if pointer is empty
		movea.l	d0,a1
		jmp	(a1)

	.exit:
		rts

; ---------------------------------------------------------------------------
; Animated pattern routine - Green Hill
; ---------------------------------------------------------------------------

AniArt_GHZ:
		lea	AniArt_GHZ_Script(pc),a3

AniArt_Run:
		lea	(v_levelani_0_frame).w,a4
		move.w	(a3)+,d4				; get script count

	.loop:
		movea.l	(a3)+,a2				; get script address
		subq.w	#1,2(a4)				; decrement timer
		bpl.s	.next					; branch if time remains

		addq.w	#1,(a4)					; increment frame number
		move.w	(a2)+,d3				; get frame count
		cmp.w	(a4),d3					; compare frame number with max
		bne.s	.valid_frame				; branch if valid
		move.w	#0,(a4)					; otherwise reset to 0
	.valid_frame:
		move.l	(a2)+,d1				; get VRAM address
		move.l	(a2)+,d2				; get size
		move.w	(a4),d3
		lsl.w	#3,d3					; multiply frame number by 8
		adda.w	d3,a2					; jump to duration for relevant frame
		move.w	(a2)+,2(a4)				; reset timer
		jsr	(AddDMA).w				; add to DMA queue

	.next:
		addq.w	#4,a4				; next time/frame counter in RAM
		dbf	d4,.loop				; repeat for all scripts
		rts

AniArt_GHZ_Script:
		dc.w 3-1					; number of scripts
		dc.l .waterfall
		dc.l .big_flower
		dc.l .small_flower
	.waterfall:
		dc.w 2						; frame count
		set_dma_dest $6D80				; VRAM destination
		set_dma_size 8*sizeof_cell			; size
		dc.w 5						; duration
		set_dma_src Art_GhzWater			; ROM source
		dc.w 5
		set_dma_src Art_GhzWater+(8*sizeof_cell)
	.big_flower:
		dc.w 2
		set_dma_dest $6A00
		set_dma_size 16*sizeof_cell
		dc.w 15
		set_dma_src Art_GhzFlower1
		dc.w 15
		set_dma_src Art_GhzFlower1+(16*sizeof_cell)
	.small_flower:
		dc.w 4
		set_dma_dest $6C00
		set_dma_size 12*sizeof_cell
		dc.w $7F
		set_dma_src Art_GhzFlower2
		dc.w 7
		set_dma_src Art_GhzFlower2+(12*sizeof_cell)
		dc.w $7F
		set_dma_src Art_GhzFlower2+(12*sizeof_cell*2)
		dc.w 7
		set_dma_src Art_GhzFlower2+(12*sizeof_cell)

; ---------------------------------------------------------------------------
; Animated pattern routine - Marble
; ---------------------------------------------------------------------------

AniArt_MZ_Script:
		dc.w 2-1					; number of scripts
		dc.l .lava
		dc.l .torch
	.lava:
		dc.w 3						; frame count
		set_dma_dest $55A0				; VRAM destination
		set_dma_size 8*sizeof_cell			; size
		dc.w 19						; duration
		set_dma_src Art_MzLava1				; ROM source
		dc.w 19
		set_dma_src Art_MzLava1+(8*sizeof_cell)
		dc.w 19
		set_dma_src Art_MzLava1+(8*sizeof_cell*2)
	.torch:
		dc.w 4
		set_dma_dest $52E0
		set_dma_size 6*sizeof_cell
		dc.w 7
		set_dma_src Art_MzTorch
		dc.w 7
		set_dma_src Art_MzTorch+(6*sizeof_cell)
		dc.w 7
		set_dma_src Art_MzTorch+(6*sizeof_cell*2)
		dc.w 7
		set_dma_src Art_MzTorch+(6*sizeof_cell*3)

AniArt_MZ:
		lea	AniArt_MZ_Script(pc),a3
		bsr.w	AniArt_Run

AniArt_MZ_Magma:

tilecount:	= 4						; 4 per column, 16 total

		lea	(vdp_data_port).l,a2
		subq.w	#1,(v_levelani_2_time).w		; decrement timer
		bpl.s	.exit					; branch if not -1

		move.w	#1,(v_levelani_2_time).w		; time between each gfx change
		move.w	(v_levelani_0_frame).w,d0		; get surface lava frame number
		lea	(Art_MzLava2).l,a4			; magma gfx
		ror.w	#7,d0					; multiply frame num by $200
		adda.w	d0,a4					; jump to appropriate tile
		locVRAM	$53A0
		moveq	#0,d3
		move.b	(v_oscillating_0_to_40).w,d3		; get oscillating value
		moveq	#4-1,d2					; number of columns of tiles

	.loop:
		move.w	d3,d0
		add.w	d0,d0
		andi.w	#$1E,d0					; d0 = low nybble of oscillating value * 2
		lea	AniArt_MZ_Magma_Index(pc),a3
		move.w	(a3,d0.w),d0
		lea	(a3,d0.w),a3
		movea.l	a4,a1					; a1 = magma gfx
		moveq	#((tilecount*sizeof_cell)/4)-1,d1	; $1F
		jsr	(a3)					; copy gfx to VRAM
		addq.w	#4,d3					; increment initial oscillating value
		dbf	d2,.loop				; repeat 3 times

	.exit:
		rts

; ---------------------------------------------------------------------------
; Animated pattern routine - Scrap Brain
; ---------------------------------------------------------------------------

AniArt_SBZ:
		tst.b	(v_act).w
		bne.s	.exit					; branch if not act 1
		lea	AniArt_SBZ_Script(pc),a3
		bsr.w	AniArt_Run

	.exit:
		rts

AniArt_SBZ_Script:
		dc.w 2-1					; number of scripts
		dc.l .puff1
		dc.l .puff2
	.puff1:
		dc.w 8						; frame count
		set_dma_dest $5520				; VRAM destination
		set_dma_size 12*sizeof_cell			; size
		dc.w 180					; duration
		set_dma_src Art_SbzSmoke			; ROM source
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*2)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*3)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*4)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*5)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*6)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*7)
	.puff2:
		dc.w 8
		set_dma_dest $56A0
		set_dma_size 12*sizeof_cell
		dc.w 120
		set_dma_src Art_SbzSmoke
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*2)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*3)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*4)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*5)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*6)
		dc.w 7
		set_dma_src Art_SbzSmoke+(12*sizeof_cell*7)

; ---------------------------------------------------------------------------
; Animated pattern routine - ending sequence
; ---------------------------------------------------------------------------

AniArt_Ending:
		lea	AniArt_Ending_Script(pc),a3
		bra.w	AniArt_Run

AniArt_Ending_Script:
		dc.w 5-1					; number of scripts
		dc.l .big_flower1
		dc.l .big_flower2
		dc.l .small_flower
		dc.l .round_flower1
		dc.l .round_flower2
	.big_flower1:
		dc.w 2
		set_dma_dest $6A00
		set_dma_size 16*sizeof_cell
		dc.w 7
		set_dma_src Art_GhzFlower1
		dc.w 7
		set_dma_src Art_GhzFlower1+(16*sizeof_cell)
	.big_flower2:
		dc.w 2
		set_dma_dest $7080
		set_dma_size 16*sizeof_cell
		dc.w 7
		set_dma_src Art_EndFlowers
		dc.w 7
		set_dma_src Art_EndFlowers+(16*sizeof_cell)
	.small_flower:
		dc.w 4
		set_dma_dest $6C00
		set_dma_size 12*sizeof_cell
		dc.w 21
		set_dma_src Art_GhzFlower2
		dc.w 7
		set_dma_src Art_GhzFlower2+(12*sizeof_cell)
		dc.w 21
		set_dma_src Art_GhzFlower2+(12*sizeof_cell*2)
		dc.w 7
		set_dma_src Art_GhzFlower2+(12*sizeof_cell)
	.round_flower1:
		dc.w 4
		set_dma_dest $6E80
		set_dma_size 16*sizeof_cell
		dc.w 14
		set_dma_src Art_EndFlowers+$400
		dc.w 14
		set_dma_src Art_EndFlowers+(16*sizeof_cell)+$400
		dc.w 14
		set_dma_src Art_EndFlowers+(16*sizeof_cell*2)+$400
		dc.w 14
		set_dma_src Art_EndFlowers+(16*sizeof_cell)+$400
	.round_flower2:
		dc.w 4
		set_dma_dest $6680
		set_dma_size 16*sizeof_cell
		dc.w 11
		set_dma_src Art_EndFlowers+$400
		dc.w 11
		set_dma_src Art_EndFlowers+(16*sizeof_cell)+$A00
		dc.w 11
		set_dma_src Art_EndFlowers+(16*sizeof_cell*2)+$A00
		dc.w 11
		set_dma_src Art_EndFlowers+(16*sizeof_cell)+$A00

; ---------------------------------------------------------------------------
; Animated pattern routine - none
; ---------------------------------------------------------------------------

AniArt_none:
		rts

; ---------------------------------------------------------------------------
; Subroutines to animate MZ magma

; input:
;	d1.w = number of longwords to write to VRAM
;	a1 = address of magma gfx (stored as 32x32 image)
;	a2 = vdp_data_port ($C00000)

;	uses d0.l, a1
; ---------------------------------------------------------------------------

AniArt_MZ_Magma_Index:
		index *
		ptr AniArt_MZ_Magma_Shift0_Col0
		ptr AniArt_MZ_Magma_Shift1_Col0
		ptr AniArt_MZ_Magma_Shift2_Col0
		ptr AniArt_MZ_Magma_Shift3_Col0
		ptr AniArt_MZ_Magma_Shift0_Col1
		ptr AniArt_MZ_Magma_Shift1_Col1
		ptr AniArt_MZ_Magma_Shift2_Col1
		ptr AniArt_MZ_Magma_Shift3_Col1
		ptr AniArt_MZ_Magma_Shift0_Col2
		ptr AniArt_MZ_Magma_Shift1_Col2
		ptr AniArt_MZ_Magma_Shift2_Col2
		ptr AniArt_MZ_Magma_Shift3_Col2
		ptr AniArt_MZ_Magma_Shift0_Col3
		ptr AniArt_MZ_Magma_Shift1_Col3
		ptr AniArt_MZ_Magma_Shift2_Col3
		ptr AniArt_MZ_Magma_Shift3_Col3
; ===========================================================================

AniArt_MZ_Magma_Shift0_Col0:
		move.l	(a1),(a2)				; write 8px row to VRAM
		lea	$10(a1),a1				; read next 32px row from source
		dbf	d1,AniArt_MZ_Magma_Shift0_Col0		; repeat for column of 4 tiles
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift1_Col0:
		move.l	2(a1),d0
		move.b	1(a1),d0
		ror.l	#8,d0
		move.l	d0,(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift1_Col0
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift2_Col0:
		move.l	2(a1),(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift2_Col0
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift3_Col0:
		move.l	4(a1),d0
		move.b	3(a1),d0
		ror.l	#8,d0
		move.l	d0,(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift3_Col0
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift0_Col1:
		move.l	4(a1),(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift0_Col1
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift1_Col1:
		move.l	6(a1),d0
		move.b	5(a1),d0
		ror.l	#8,d0
		move.l	d0,(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift1_Col1
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift2_Col1:
		move.l	6(a1),(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift2_Col1
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift3_Col1:
		move.l	8(a1),d0
		move.b	7(a1),d0
		ror.l	#8,d0
		move.l	d0,(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift3_Col1
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift0_Col2:
		move.l	8(a1),(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift0_Col2
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift1_Col2:
		move.l	$A(a1),d0
		move.b	9(a1),d0
		ror.l	#8,d0
		move.l	d0,(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift1_Col2
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift2_Col2:
		move.l	$A(a1),(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift2_Col2
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift3_Col2:
		move.l	$C(a1),d0
		move.b	$B(a1),d0
		ror.l	#8,d0
		move.l	d0,(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift3_Col2
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift0_Col3:
		move.l	$C(a1),(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift0_Col3
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift1_Col3:
		move.l	$C(a1),d0
		rol.l	#8,d0
		move.b	0(a1),d0
		move.l	d0,(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift1_Col3
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift2_Col3:
		move.w	$E(a1),(a2)
		move.w	0(a1),(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift2_Col3
		rts
; ===========================================================================

AniArt_MZ_Magma_Shift3_Col3:
		move.l	0(a1),d0
		move.b	$F(a1),d0
		ror.l	#8,d0
		move.l	d0,(a2)
		lea	$10(a1),a1
		dbf	d1,AniArt_MZ_Magma_Shift3_Col3
		rts
