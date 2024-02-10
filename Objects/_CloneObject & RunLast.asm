; ---------------------------------------------------------------------------
; Subroutine to duplicate an object

; output:
;	a1 = address of OST of duplicate object

;	uses d0.w, a2, a3
; ---------------------------------------------------------------------------

CloneObject:
		bsr.w	FindNextFreeObj				; a1 = free OST slot
		
CloneObject2:
		movea.l	a0,a2					; a2 = OST of original object
		movea.l	a1,a3					; a3 = OST of empty slot
		rept sizeof_ost/4
		move.l	(a2)+,(a3)+				; copy contents of OST to new slot
		endr
		rts

; ---------------------------------------------------------------------------
; Subroutine to move the current object to the last available OST slot

; output:
;	a1 = address of new OST of object

;	uses d0.l, a2, a3

; usage:
;		addq.b	#2,ost_routine(a0)			; don't repeat this routine
;		bra.w	RunLast
; ---------------------------------------------------------------------------

RunLast:
		bsr.w	FindFreeFinal				; a1 = new OST slot
		bsr.s	CloneObject2				; copy object to new slot
		bra.w	DeleteObject				; delete original
