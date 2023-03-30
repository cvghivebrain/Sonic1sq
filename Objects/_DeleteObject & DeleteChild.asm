; ---------------------------------------------------------------------------
; Subroutine to	delete an object

; input:
;	a0 = address of OST of object (DeleteObject only)
;	a1 = address of OST of object (DeleteChild only)

; output:
;	a1 = address of next OST

;	uses d0.l

; usage (DeleteParent):
;		getparent					; a1 = OST of parent, assuming ost_parent is set
;		bsr.w	DeleteParent
; ---------------------------------------------------------------------------

DeleteObject:
		movea.l	a0,a1					; move current OST address to a1

DeleteChild:							; child objects are already in (a1)
DeleteParent:
		move.w	a1,d0
		beq.s	.exit					; branch if no OST was defined
		moveq	#0,d0
		rept sizeof_ost/4
		move.l	d0,(a1)+
		endr
		
	.exit:
		rts	

; ---------------------------------------------------------------------------
; Subroutine to	delete an object and all its children

; input:
;	a0 = address of OST of object

;	uses d0.l, d1.w, a1
; ---------------------------------------------------------------------------

DeleteFamily:
		movea.l	a0,a1					; move current OST address to a1
		move.w	a1,d1
		beq.s	.exit					; branch if no OST was defined
		moveq	#0,d0
		rept sizeof_ost/4
		move.l	d0,(a1)+				; delete parent
		endr
		
	.loop:
		cmp.w	ost_parent(a1),d1
		bne.s	.next					; branch if next object isn't a child
		rept sizeof_ost/4
		move.l	d0,(a1)+				; delete child object
		endr
		bra.s	.chk_end
		
	.next:
		lea	sizeof_ost(a1),a1			; goto next OST slot
		
	.chk_end:
		cmpa.w	#v_ost_end&$FFFF,a1
		bne.s	.loop					; repeat if not at end of OSTs
		
	.exit:
		rts	
