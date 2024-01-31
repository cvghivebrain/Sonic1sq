; ---------------------------------------------------------------------------
; Decompress HiveRLE archive to RAM

; input:
;	a1 = source address
;	a2 = destination address

;	uses d0.l, d1.b, a1, a2, a3, a4

; usage:
;	lea	(source).l,a1
;	lea	(destination).w,a2
;	bsr.w	HiveDec
; ---------------------------------------------------------------------------

HiveDec:
		lea	HiveDec_Copy_Table_End(pc),a3
		lea	HiveDec_Repeat_Table_End(pc),a4
		moveq	#-1,d0					; d0 = $FFnn

HiveDec_Next:
		move.b	(a1)+,d0				; get n byte
		add.b	d0,d0					; multiply by 2, to both properly adjust to 68K opcode sizes...
		bcs.s	HiveDec_Repeat				; ...and put repeat flag into the carry flag, hence the byte size
		beq.s	HiveDec_End				; branch if 0 (including repeat flag)

; HiveDec_Copy:
		neg.b	d0					; turn n into -n
		jmp	(a3,d0.w)				; copy n bytes to destination
	
HiveDec_Repeat:
		move.b	(a1)+,d1				; get byte to write
		jmp	(a4,d0.w)				; write byte n times to destination
	
HiveDec_End:
		rts
	
HiveDec_Copy_Table:
		rept	127
		move.b	(a1)+,(a2)+				; copy byte from source to destination
		endr
	HiveDec_Copy_Table_End:
		bra.w	HiveDec_Next
	
HiveDec_Repeat_Table:
		rept	128
		move.b	d1,(a2)+				; write byte to destination
		endr
	HiveDec_Repeat_Table_End:
		bra.w	HiveDec_Next
