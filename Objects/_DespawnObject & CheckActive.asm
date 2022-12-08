; ---------------------------------------------------------------------------
; Routine to check if object is still on-screen: display if yes, delete if not

;	uses d0.l, d1.l, a1, a2
; ---------------------------------------------------------------------------

DespawnObject:
		move.w	ost_x_pos(a0),d0
		bsr.s	CheckActive
		bne.s	.offscreen				; branch if object moves off screen
		bra.w	DisplaySprite				; display instead of despawn

	.offscreen:
		lea	(v_respawn_list).w,a2
		moveq	#0,d0
		move.b	ost_respawn(a0),d0			; get respawn id
		beq.s	.delete					; branch if not set
		bclr	#7,2(a2,d0.w)				; clear high bit of respawn entry (i.e. object was despawned not broken)

	.delete:
		bra.w	DeleteObject				; delete the object

; ---------------------------------------------------------------------------
; Subroutine to check if object is within active space around the screen

; input:
;	d0.w = object x position

; output:
;	d0.l = 0 if on screen; 1 if off screen

;	uses d1.w

; usage:
;		bsr.w	CheckActive
;		bne.w	.offscreen				; branch if outside active area

; ---------------------------------------------------------------------------

CheckActive:
		andi.w	#$FF80,d0				; round down to nearest $80
		move.w	(v_camera_x_pos).w,d1			; get screen position
		subi.w	#128,d1
		andi.w	#$FF80,d1
		sub.w	d1,d0					; d0 = approx distance between object and screen (negative if object is left of screen)
		cmpi.w	#128+320+192,d0
		bhi.s	.offscreen				; branch if d0 is negative or higher than 640
		
		moveq	#0,d0
		rts
		
	.offscreen:
		moveq	#1,d0
		rts
