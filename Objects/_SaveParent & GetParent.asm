; ---------------------------------------------------------------------------
; Subroutine to save the parent OST address to ost_parent in a child object

; input:
;	a0 = address of OST of parent object
;	a1 = address of OST of child object
; ---------------------------------------------------------------------------

SaveParent:
		move.w	a0,ost_parent(a1)
		rts

; ---------------------------------------------------------------------------
; Subroutine to set a1 as the parent object

; output:
;	a1 = address of OST of parent object

;	uses d0.l
; ---------------------------------------------------------------------------

GetParent:
		moveq	#-1,d0					; d0 = $FFFFFFFF
		move.w	ost_parent(a0),d0			; d0 = $FFFFxxxx
		movea.l	d0,a1					; set a1 as parent
		rts
