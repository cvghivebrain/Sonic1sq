; ---------------------------------------------------------------------------
; New format based on Kosinski. It changes several design decisions to allow
; a faster decompressor without loss of compression ratio.
; Created originally by Flamewing and vladikcomper (by discussions on IRC),
; further improvements by Clownacy.

; input:
;	a0 = source address
;	a1 = destination address

; usage:
;	lea	(source).l,a0
;	lea	(destination).l,a1
;	bsr.w	KosDec
; ---------------------------------------------------------------------------

_KosPlus_LoopUnroll = 3

_KosPlus_ReadBit macro
	dbra	d2,.skip\@
	moveq	#7,d2						; We have 8 new bits, but will use one up below.
	move.b	(a0)+,d0					; Get desc field low-byte.
.skip\@:
	add.b	d0,d0						; Get a bit from the bitstream.
	endm
; ===========================================================================

KosDec:
KosPlusDec:
	movem.l	d0-d6/a0-a2,-(sp)
	if _KosPlus_LoopUnroll>0
		moveq	#(1<<_KosPlus_LoopUnroll)-1,d1
	endc
	moveq	#0,d2						; Flag as having no bits left.
	bra.s	.FetchNewCode
; ---------------------------------------------------------------------------
.FetchCodeLoop:
	; Code 1 (Uncompressed byte).
	move.b	(a0)+,(a1)+

.FetchNewCode:
	_KosPlus_ReadBit
	bcs.s	.FetchCodeLoop				; If code = 1, branch.

	; Codes 00 and 01.
	moveq	#-1,d5
	lea	(a1),a2
	_KosPlus_ReadBit
	bcs.s	.Code_01

	; Code 00 (Dictionary ref. short).
	move.b	(a0)+,d5					; d5 = displacement.
	adda.w	d5,a2
	; Always copy at least two bytes.
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+
	_KosPlus_ReadBit
	bcc.s	.Copy_01
	move.b	(a2)+,(a1)+
	move.b	(a2)+,(a1)+

.Copy_01:
	_KosPlus_ReadBit
	bcc.s	.FetchNewCode
	move.b	(a2)+,(a1)+
	bra.s	.FetchNewCode
; ---------------------------------------------------------------------------
.Code_01:
	moveq	#0,d4						; d4 will contain copy count.
	; Code 01 (Dictionary ref. long / special).
	move.b	(a0)+,d4					; d4 = %HHHHHCCC.
	move.b	d4,d5						; d5 = %11111111 HHHHHCCC.
	lsl.w	#5,d5						; d5 = %111HHHHH CCC00000.
	move.b	(a0)+,d5					; d5 = %111HHHHH LLLLLLLL.
	if _KosPlus_LoopUnroll=3
		and.w	d1,d4					; d4 = %00000CCC.
	else
		andi.w	#7,d4
	endc
	if _KosPlus_LoopUnroll>0
		bne.s	.StreamCopy				; if CCC=0, branch.

		; special mode (extended counter)
		move.b	(a0)+,d4				; Read cnt
		beq.s	.Quit					; If cnt=0, quit decompression.

		adda.w	d5,a2
		move.w	d4,d6
		not.w	d6
		and.w	d1,d6
		add.w	d6,d6
		lsr.w	#_KosPlus_LoopUnroll,d4
		jmp	.largecopy(pc,d6.w)
	else
		beq.s	.dolargecopy
	endc
; ---------------------------------------------------------------------------
.StreamCopy:
	adda.w	d5,a2
	move.b	(a2)+,(a1)+					; Do 1 extra copy (to compensate +1 to copy counter).
	add.w	d4,d4
	jmp	.mediumcopy-2(pc,d4.w)
; ---------------------------------------------------------------------------
	if _KosPlus_LoopUnroll=0
.dolargecopy:
		; special mode (extended counter)
		move.b	(a0)+,d4				; Read cnt
		beq.s	.Quit					; If cnt=0, quit decompression.
		adda.w	d5,a2
	endc

.largecopy:
	rept (1<<_KosPlus_LoopUnroll)
		move.b	(a2)+,(a1)+
	endr
	dbra	d4,.largecopy

.mediumcopy:
	rept 8
		move.b	(a2)+,(a1)+
	endr
	bra.w	.FetchNewCode
; ---------------------------------------------------------------------------
.Quit:
	movem.l	(sp)+,d0-d6/a0-a2
	rts
