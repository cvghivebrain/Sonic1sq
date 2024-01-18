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
		dbf	d0,.loop				; repeat for all DMA slots

	.found:
		rts

; ---------------------------------------------------------------------------
; Subroutine to add an item to the DMA queue

; input:
;	d1.l = destination address (as DMA instruction)
;	d2.l = length (as DMA instruction)
;	(a2).l = source address (as DMA instruction)

;	uses a2
; ---------------------------------------------------------------------------

AddDMA:
		pushr	d0/a1
		bsr.s	FindFreeDMA				; find free DMA slot
		bne.s	.not_found				; branch if no slots are available
		move.l	(a2)+,(a1)+				; write source address
		move.w	(a2)+,(a1)+				; write source address
		move.l	d2,(a1)+				; write length
		move.l	d1,(a1)					; write destination address

	.not_found:
		popr	d0/a1
		rts

; ---------------------------------------------------------------------------
; As above, but with length stored after source in (a2)

; input:
;	d1.l = destination address (as DMA instruction)
;	(a2).l = source address and length (as DMA instructions)

;	uses a2
; ---------------------------------------------------------------------------

AddDMA2:
		pushr	d0/a1
		bsr.s	FindFreeDMA				; find free DMA slot
		bne.s	.not_found				; branch if no slots are available
		move.l	(a2)+,(a1)+				; write source address
		move.w	(a2)+,(a1)+				; write source address
		move.l	(a2)+,(a1)+				; write length
		move.l	d1,(a1)					; write destination address

	.not_found:
		popr	d0/a1
		rts

; ---------------------------------------------------------------------------
; Subroutine to run all items stored in the DMA queue

; output:
;	a6 = vdp_control_port

;	uses d0.l, d1.l, a1
; ---------------------------------------------------------------------------

ProcessDMA:
		lea	(v_dma_queue).w,a1			; start address for DMA queue
		lea	(vdp_control_port).l,a6			; control port
		moveq	#countof_dma-1,d0			; number of DMA slots in total
		moveq	#0,d1

	.loop:
		tst.b	(a1)					; is DMA slot empty?
		beq.s	.empty					; if yes, branch
		move.l	(a1),(a6)				; write source address (high and mid)
		move.l	d1,(a1)+				; delete from queue
		move.l	(a1),(a6)				; write source address (low) and length (high)
		move.l	d1,(a1)+
		move.l	(a1),(a6)				; write length (low) and destination (high)
		move.l	d1,(a1)+
		move.w	(a1),(a6)				; write destination address (low)
		move.w	d1,(a1)+
		dbf	d0,.loop				; repeat for all DMA slots

	.empty:
		rts
