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
		tst.w	(a1)					; is subsprite slot empty?
		beq.s	FindFreeSub_Found			; if yes, branch
		lea	sizeof_subsprite(a1),a1			; goto next slot
		dbf	d0,.loop				; repeat
		rts

FindFreeSub_Found:
		move.w	a1,ost_subsprite(a0)			; save subsprite table address
		moveq	#0,d0					; flag that subsprite slot was found
		rts

; ---------------------------------------------------------------------------
; As above, but using a smaller subsprite table
; ---------------------------------------------------------------------------

FindFreeSubMini:
		lea	(v_subsprite_queue_mini).w,a1		; start address for subsprites
		moveq	#countof_subsprite_mini-1,d0

	.loop:
		tst.w	(a1)					; is subsprite slot empty?
		beq.s	FindFreeSub_Found			; if yes, branch
		lea	sizeof_subsprite_mini(a1),a1		; goto next slot
		dbf	d0,.loop				; repeat
		rts

; ---------------------------------------------------------------------------
; Subroutine to initialise subsprites

; input:
;	d1.w = number of subsprite pieces
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
		cmpi.w	#countof_piece,d1
		bls.s	InitSub_SkipChk				; branch if number is within max
		moveq	#countof_piece,d1			; enforce limit
		
InitSub_SkipChk:
		move.w	d1,(a1)+				; write subsprite piece count
		subq.w	#1,d1					; subtract 1 for loops
		
	.loop:
		clr.w	(a1)+					; write y pos (blank)
		move.w	d2,(a1)+				; write sprite size
		move.w	d3,(a1)+				; write tile setting
		clr.w	(a1)+					; write x pos (blank)
		dbf	d1,.loop				; repeat for all subsprites
		rts

InitSubMini:
		cmpi.w	#countof_piece_mini,d1
		bls.s	InitSub_SkipChk				; branch if number is within max
		moveq	#countof_piece_mini,d1			; enforce limit
		bra.s	InitSub_SkipChk

; ---------------------------------------------------------------------------
; Subroutine to initialise subsprites using a list

; input:
;	d1.w = number of subsprite pieces
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
		cmpi.w	#countof_piece,d1
		bls.s	InitSubFromList_SkipChk			; branch if number is within max
		moveq	#countof_piece,d1			; enforce limit
		
InitSubFromList_SkipChk:
		move.w	d1,(a1)+				; write subsprite piece count
		subq.w	#1,d1					; subtract 1 for loops
		
	.loop:
		clr.w	(a1)+					; write y pos (blank)
		move.w	(a2)+,(a1)+				; write sprite size
		move.w	(a2)+,(a1)+				; write tile setting
		clr.w	(a1)+					; write x pos (blank)
		dbf	d1,.loop				; repeat for all subsprites
		rts

InitSubFromListMini:
		cmpi.w	#countof_piece_mini,d1
		bls.s	InitSubFromList_SkipChk			; branch if number is within max
		moveq	#countof_piece_mini,d1			; enforce limit
		bra.s	InitSubFromList_SkipChk
