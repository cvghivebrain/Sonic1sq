; ---------------------------------------------------------------------------
; Subroutine to	add an object to the sprite queue for display by BuildSprites
;
; input:
;	a0 = address of OST for object

;	uses d0.w, a1
; ---------------------------------------------------------------------------

DisplaySprite:
		moveq	#0,d0
		move.b	ost_priority(a0),d0			; get sprite priority
		add.b	d0,d0
		add.b	d0,d0
		movea.l	Disp_OffsetList(pc,d0.w),a1		; get RAM address for priority level
		cmpi.w	#sizeof_priority-2,(a1)			; is this section full? ($7E)
		bcc.s	.full					; if yes, branch
		addq.w	#2,(a1)					; increment sprite count
		adda.w	(a1),a1					; jump to empty position
		move.w	a0,(a1)					; insert RAM address for OST of object

	.full:
		rts

Disp_OffsetList:
		dc.l v_sprite_queue
		dc.l v_sprite_queue+sizeof_priority
		dc.l v_sprite_queue+(sizeof_priority*2)
		dc.l v_sprite_queue+(sizeof_priority*3)
		dc.l v_sprite_queue+(sizeof_priority*4)
		dc.l v_sprite_queue+(sizeof_priority*5)
		dc.l v_sprite_queue+(sizeof_priority*6)
		dc.l v_sprite_queue+(sizeof_priority*7)
