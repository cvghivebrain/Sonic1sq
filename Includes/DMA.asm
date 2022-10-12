; ---------------------------------------------------------------------------
; Subroutine to find a free DMA slot

; output:
;	a1 = address of free DMA slot

;	uses d0.w
; ---------------------------------------------------------------------------

FindFreeDMA:
		lea	(v_dma_queue).w,a1			; start address for DMA queue
		move.w	#countof_dma-1,d0			; number of DMA slots in total

	.loop:
		tst.b	(a1)					; is DMA slot empty?
		beq.s	.found					; if yes, branch
		lea	sizeof_dma(a1),a1			; goto next DMA slot
		dbf	d0,.loop				; repeat 15 times

	.found:
		rts

; ---------------------------------------------------------------------------
; Subroutine to add an item to the DMA queue

; input:
;	d1.l = destination address (as DMA instruction)
;	d2.l = length (as DMA instruction)
;	(a2).l = source address (as DMA instruction)

;	uses d0.w, a1
; ---------------------------------------------------------------------------

AddDMA:
		bsr.s	FindFreeDMA				; find free DMA slot (overwrites last slot if none are found)
		move.l	(a2)+,(a1)+				; write source address
		move.w	(a2)+,(a1)+				; write source address
		move.l	d2,(a1)+				; write length
		move.l	d1,(a1)					; write destination address
		rts

; ---------------------------------------------------------------------------
; As above, but with length stored after source in (a2)

; input:
;	d1.l = destination address (as DMA instruction)
;	(a2).l = source address and length (as DMA instructions)

;	uses d0.w, a1
; ---------------------------------------------------------------------------

AddDMA2:
		bsr.s	FindFreeDMA				; find free DMA slot (overwrites last slot if none are found)
		move.l	(a2)+,(a1)+				; write source address
		move.w	(a2)+,(a1)+				; write source address
		move.l	(a2)+,(a1)+				; write length
		move.l	d1,(a1)					; write destination address
		rts

; ---------------------------------------------------------------------------
; Subroutine to run all items stored in the DMA queue

; output:
;	a5 = vdp_control_port

;	uses d0.w, d1.l, a1
; ---------------------------------------------------------------------------

ProcessDMA:
		lea	(v_dma_queue).w,a1			; start address for DMA queue
		lea	(vdp_control_port).l,a5			; control port
		move.w	#countof_dma-1,d0			; number of DMA slots in total

	.loop:
		tst.b	(a1)					; is DMA slot empty?
		beq.s	.empty					; if yes, branch
		move.l	(a1),(a5)				; write source address
		move.w	4(a1),(a5)				; write source address
		move.l	6(a1),(a5)				; write length
		move.l	10(a1),d1
		move.l	d1,(a5)					; write destination address
		move.l	#0,(a1)
		move.w	#0,4(a1)
		move.l	#0,6(a1)
		move.l	#0,10(a1)				; delete from queue
	
	.empty:
		lea	sizeof_dma(a1),a1			; goto next DMA slot
		dbf	d0,.loop				; repeat 15 times
		rts
