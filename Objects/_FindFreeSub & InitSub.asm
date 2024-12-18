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
;	d0.w = number of subsprite pieces
;	d1.w = sprite size
;	d2.w = tile setting
;	a1 = address of free subsprite slot

;	uses d0.l, a1

; usage:
;		bsr.w	FindFreeSub
;		bne.s	.fail					; branch if empty slot isn't found
;		moveq	#4,d0					; 4 subsprites
;		moveq	#sprite1x2,d1				; size 1x2
;		move.w	ost_tile(a0),d2				; tile setting
;		bsr.w	InitSub
; ---------------------------------------------------------------------------

InitSub:
		cmpi.w	#countof_piece,d0
		bls.s	InitSub_SkipChk				; branch if number is within max
		moveq	#countof_piece,d0			; enforce limit
		
InitSub_SkipChk:
		move.w	d0,(a1)+				; write subsprite piece count
		subq.w	#1,d0					; subtract 1 for loops
		
	.loop:
		clr.w	(a1)+					; write y pos (blank)
		move.w	d1,(a1)+				; write sprite size
		move.w	d2,(a1)+				; write tile setting
		clr.w	(a1)+					; write x pos (blank)
		dbf	d0,.loop				; repeat for all subsprites
		rts

InitSubMini:
		cmpi.w	#countof_piece_mini,d0
		bls.s	InitSub_SkipChk				; branch if number is within max
		moveq	#countof_piece_mini,d0			; enforce limit
		bra.s	InitSub_SkipChk

; ---------------------------------------------------------------------------
; As above, but with specified x and y pos

; input:
;	d0.w = number of subsprite pieces
;	d1.w = sprite size
;	d2.w = tile setting
;	d3.w = initial x pos
;	d4.w = initial y pos
;	d5.w = value to add to x pos
;	d6.w = value to add to y pos
;	a1 = address of free subsprite slot

;	uses d0.l, d3.w, d4.w, a1
; ---------------------------------------------------------------------------

InitSubXY:
		cmpi.w	#countof_piece,d0
		bls.s	InitSubXY_SkipChk			; branch if number is within max
		moveq	#countof_piece,d0			; enforce limit
		
InitSubXY_SkipChk:
		move.w	d0,(a1)+				; write subsprite piece count
		subq.w	#1,d0					; subtract 1 for loops
		
	.loop:
		move.w	d4,(a1)+				; write y pos
		move.w	d1,(a1)+				; write sprite size
		move.w	d2,(a1)+				; write tile setting
		move.w	d3,(a1)+				; write x pos
		add.w	d5,d3					; update x pos for next subsprite
		add.w	d6,d4					; update y pos for next subsprite
		dbf	d0,.loop				; repeat for all subsprites
		rts

InitSubXYMini:
		cmpi.w	#countof_piece_mini,d0
		bls.s	InitSubXY_SkipChk			; branch if number is within max
		moveq	#countof_piece_mini,d0			; enforce limit
		bra.s	InitSubXY_SkipChk

; ---------------------------------------------------------------------------
; Subroutine to initialise subsprites using a list

; input:
;	d0.w = number of subsprite pieces
;	a1 = address of free subsprite slot
;	a2 = address of subsprite data to write

;	uses d0.l, a1, a2

; usage:
;		bsr.w	FindFreeSub
;		bne.s	.fail					; branch if empty slot isn't found
;		lea	.subdata(pc),a2
;		bsr.w	InitSubFromList
; ---------------------------------------------------------------------------

InitSubFromList:
		cmpi.w	#countof_piece,d0
		bls.s	InitSubFromList_SkipChk			; branch if number is within max
		moveq	#countof_piece,d0			; enforce limit
		
InitSubFromList_SkipChk:
		move.w	d0,(a1)+				; write subsprite piece count
		subq.w	#1,d0					; subtract 1 for loops
		
	.loop:
		clr.w	(a1)+					; write y pos (blank)
		move.w	(a2)+,(a1)+				; write sprite size
		move.w	(a2)+,(a1)+				; write tile setting
		clr.w	(a1)+					; write x pos (blank)
		dbf	d0,.loop				; repeat for all subsprites
		rts

InitSubFromListMini:
		cmpi.w	#countof_piece_mini,d0
		bls.s	InitSubFromList_SkipChk			; branch if number is within max
		moveq	#countof_piece_mini,d0			; enforce limit
		bra.s	InitSubFromList_SkipChk
