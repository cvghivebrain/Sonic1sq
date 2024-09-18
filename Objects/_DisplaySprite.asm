; ---------------------------------------------------------------------------
; Subroutine to	add an object to the sprite queue for display by BuildSprites
;
; input:
;	a0 = address of OST for object

;	uses a1
; ---------------------------------------------------------------------------

DisplaySprite:
                movea.w ost_priority(a0),a1    			; get sprite priority pointer
                cmpi.w  #sizeof_priority-2,(a1)			; is this section full? ($7E)
                bhs.s   .full					; if yes, branch
                addq.w  #2,(a1)					; increment sprite count
                adda.w  (a1),a1					; jump to empty position
                move.w  a0,(a1)					; insert RAM address for OST of object

	.full:
		rts		
