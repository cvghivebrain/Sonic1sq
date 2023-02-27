; ---------------------------------------------------------------------------
; Subroutine to	wait for VBlank routines to complete
; ---------------------------------------------------------------------------

CPUGfxIndex:	set_dma_src	Art_LivesNums
		set_dma_src	Art_LivesNums+sizeof_cell
		set_dma_src	Art_LivesNums+(sizeof_cell*2)
		set_dma_src	Art_LivesNums+(sizeof_cell*3)
		set_dma_src	Art_LivesNums+(sizeof_cell*4)
		set_dma_src	Art_LivesNums+(sizeof_cell*5)
		set_dma_src	Art_LivesNums+(sizeof_cell*6)
		set_dma_src	Art_LivesNums+(sizeof_cell*7)
		set_dma_src	Art_LivesNums+(sizeof_cell*8)
		set_dma_src	Art_LivesNums+(sizeof_cell*9)
		
WaitForVBlank_CPU:
		pushr.w	(vdp_counter).l
		moveq	#0,d0
		popr.b	d0					; get vertical position
		cmpi.b	#223,d0
		bls.s	.vert_ok				; branch if 223 or less
		move.b	#223,d0
	.vert_ok:
		add.w	d0,d0
		lea	CPUPercent(pc,d0.w),a1			; convert to percentage
		moveq	#0,d0
		move.b	(a1)+,d0				; get tens digit
		lea	CPUGfxIndex(pc,d0.w),a2
		set_dma_dest	$DF40,d1			; VRAM address
		set_dma_size	sizeof_cell,d2
		jsr	AddDMA					; load tens digit
		move.b	(a1),d0					; get low digit
		lea	CPUGfxIndex(pc,d0.w),a2
		set_dma_dest	$DF60,d1			; VRAM address
		set_dma_size	sizeof_cell,d2
		jsr	AddDMA					; load low digit

WaitForVBlank:
		enable_ints

	.wait:
		tst.b	(v_vblank_routine).w			; has VBlank routine finished?
		bne.s	.wait					; if not, branch
		rts

		i: = 0
		percent: = 0
CPUPercent:	rept 224
		dc.b (percent/10)*6, (percent%10)*6
		i: = i+1
		percent: = (i*100)/224
		endr
; ---------------------------------------------------------------------------
; Subroutine to	freeze the game for a set time

; inputs:
;	d0.w = number of frames to wait
;	d1.b = VBlank routine

;	uses d0.w
; ---------------------------------------------------------------------------

WaitLoop:
		move.b	d1,(v_vblank_routine).w
		bsr.w	WaitForVBlank				; wait for frame to end
		dbf	d0,WaitLoop				; repeat for d0 frames
		rts
