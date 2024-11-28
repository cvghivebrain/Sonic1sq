; ---------------------------------------------------------------------------
; Subroutine to find a free OST

; output:
;	a1 = address of free OST slot

;	uses d0.w

; usage:
;		bsr.w	FindFreeObj
;		bne.s	.fail					; branch if empty slot isn't found
;		move.l	#Crabmeat,ost_id(a1)			; load Crabmeat object
; ---------------------------------------------------------------------------

FindFreeObj:
		lea	(v_ost_level_obj).w,a1			; start address for OSTs
		move.w	#countof_ost_ert-1,d0

FindFreeObj2:
	.loop:
		tst.l	ost_id(a1)				; is OST slot empty?
		beq.s	.found					; if yes, branch
		lea	sizeof_ost(a1),a1			; goto next OST
		dbf	d0,.loop				; repeat $5F times

	.found:
		rts

; ---------------------------------------------------------------------------
; Subroutine to find a free OST, including inert object slots

; output:
;	a1 = address of free OST slot

;	uses d0.w
; ---------------------------------------------------------------------------

FindFreeInert:
		lea	(v_ost_all+sizeof_ost).w,a1		; start at OST after Sonic
		move.w	#countof_ost-2,d0
		bra.s	FindFreeObj2
		
; ---------------------------------------------------------------------------
; Subroutine to find the last free OST slot

; output:
;	a1 = address of free OST slot

;	uses d0.w
; ---------------------------------------------------------------------------

FindFreeFinal:
		lea	(v_ost_final).w,a1			; last possible OST slot
		move.w	#countof_ost_ert-1,d0

	.loop:
		tst.l	ost_id(a1)				; is OST slot empty?
		beq.s	.found					; if yes, branch
		lea	-sizeof_ost(a1),a1			; goto previous OST
		dbf	d0,.loop				; repeat $5F times

	.found:
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to find a free OST AFTER the current one

; input:
;	a0 = address of current OST slot

; output:
;	a1 = address of free OST slot

;	uses d0.l

; usage:
;		bsr.w	FindNextFreeObj
;		bne.s	.fail					; branch if empty slot isn't found
;		move.b	#id_Bomb,ost_id(a1)			; load Bomb object
; ---------------------------------------------------------------------------

FindNextFreeObj:
		lea	sizeof_ost(a0),a1			; a1 = OST after current one
		
	.loop:
		cmpa.w	#v_ost_end&$FFFF,a1
		beq.s	.fail					; branch if at end of OSTs
		tst.l	ost_id(a1)				; is OST slot empty?
		beq.s	.found					; if yes, branch
		lea	sizeof_ost(a1),a1			; goto next OST
		bra.s	.loop					; repeat until end of OSTs
		
	.fail:
		moveq	#1,d0
		
	.found:
		rts
