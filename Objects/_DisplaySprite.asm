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
		movea.w	Disp_OffsetList(pc,d0.w),a1		; get RAM address for priority level
		move.w	(a1),d0
		cmpi.w	#sizeof_priority-2,d0			; is this section full? ($7E)
		bcc.s	.full					; if yes, branch
		addq.w	#2,d0					; increment sprite count
		move.w	d0,(a1)
		move.w	a0,(a1,d0.w)				; insert RAM address for OST of object

	.full:
		rts

Disp_OffsetList:
		dc.w v_sprite_queue
		dc.w v_sprite_queue+sizeof_priority
		dc.w v_sprite_queue+(sizeof_priority*2)
		dc.w v_sprite_queue+(sizeof_priority*3)
		dc.w v_sprite_queue+(sizeof_priority*4)
		dc.w v_sprite_queue+(sizeof_priority*5)
		dc.w v_sprite_queue+(sizeof_priority*6)
		if (*-Disp_OffsetList)/2 <> countof_priority
		inform 3,"Mismatch between DisplaySprite and countof_priority."
		endc
		
