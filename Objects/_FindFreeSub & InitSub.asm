; ---------------------------------------------------------------------------
; Subroutine to find a free subsprite slot

; output:
;	a1 = address of free subsprite slot

;	uses d0.l

; usage:
;		bsr.w	FindFreeSub
;		bne.s	.fail					; branch if empty slot isn't found
;		addq.w	#1,(a1)					; create first subsprite
; ---------------------------------------------------------------------------

FindFreeSub:
		lea	(v_subsprite_queue).w,a1		; start address for subsprites
		moveq	#countof_subsprite-1,d0

	.loop:
		tst.w	(a1)					; is OST slot empty?
		beq.s	.found					; if yes, branch
		lea	sizeof_subsprite(a1),a1			; goto next slot
		dbf	d0,.loop				; repeat
		rts

	.found:
		move.w	a1,ost_subsprite(a0)			; save subsprite table address
		moveq	#0,d0					; flag that subsprite slot was found
		rts

; ---------------------------------------------------------------------------
; Subroutine to initialise subsprites

; input:
;	d1.w = number of subsprites
;	d2.w = sprite size
;	d3.w = tile setting
;	a1 = address of free subsprite slot

;	uses d1.l, a1

; usage:
;		bsr.w	FindFreeSub
;		bne.s	.fail					; branch if empty slot isn't found
;		moveq	#4,d1					; 4 subsprites
;		moveq	#sprite1x2,d2				; size 1x2
;		move.w	ost_tile(a0),d3				; tile setting
;		bsr.w	InitSub
; ---------------------------------------------------------------------------

InitSub:
		cmpi.w	#countof_subsprite,d1
		bls.s	.num_ok					; branch if number is within max
		moveq	#countof_subsprite,d1			; enforce limit
		
	.num_ok:
		move.w	d1,(a1)+				; write subsprite count
		subq.w	#1,d1					; subtract 1 for loops
		
	.loop:
		move.w	d2,(a1)+				; write y pos (blank) & sprite size
		move.w	d3,(a1)+				; write tile setting
		clr.w	(a1)+					; write x pos (blank)
		dbf	d1,.loop				; repeat for all subsprites
		rts

; ---------------------------------------------------------------------------
; Subroutine to initialise subsprites using a list

; input:
;	d1.w = number of subsprites
;	a1 = address of free subsprite slot
;	a2 = address of subsprite data to write

;	uses d1.l, a1, a2

; usage:
;		bsr.w	FindFreeSub
;		bne.s	.fail					; branch if empty slot isn't found
;		lea	.subdata(pc),a2
;		bsr.w	InitSubFromList
; ---------------------------------------------------------------------------

InitSubFromList:
		cmpi.w	#countof_subsprite,d1
		bls.s	.num_ok					; branch if number is within max
		moveq	#countof_subsprite,d1			; enforce limit
		
	.num_ok:
		move.w	d1,(a1)+				; write subsprite count
		subq.w	#1,d1					; subtract 1 for loops
		
	.loop:
		move.w	(a2)+,(a1)+				; write y pos (blank) & sprite size
		move.w	(a2)+,(a1)+				; write tile setting
		clr.w	(a1)+					; write x pos (blank)
		dbf	d1,.loop				; repeat for all subsprites
		rts
