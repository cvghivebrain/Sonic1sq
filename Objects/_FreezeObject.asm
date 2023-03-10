; ---------------------------------------------------------------------------
; Subroutine to freeze an object when it's 256px above or below the screen

; input:
;	d0.w = y position of object

;	uses d0.l, d1.w, a1

; usage:
;		move.w	ost_y_pos(a0),d0
;		bsr.w	FreezeObject				; place at the start of an object, before the routine index code
;		moveq	#0,d0
;		move.b	ost_routine(a0),d0
; ---------------------------------------------------------------------------

FreezeObject:
		sub.w	(v_camera_y_pos).w,d0			; d0 = -ve if object is above screen
		cmpi.w	#-256,d0
		ble.s	.offscreen				; branch if 256px+ above screen
		cmpi.w	#256+screen_height,d0
		bge.s	.offscreen				; branch if 256px+ below screen
		rts						; do nothing if within 256px of screen
		
	.offscreen:
		addq.l	#4,sp					; don't execute object code after leaving this subroutine
		move.w	ost_x_pos(a0),d0
		bsr.s	CheckActive
		bne.w	DeleteObject				; delete if outside x range
		rts
		
; ---------------------------------------------------------------------------
; As above, but object doesn't delete itself (until it moves back into y range,
;  or if the parent object deletes it)

; input:
;	d0.w = y position of object

;	uses d0.w
; ---------------------------------------------------------------------------

FreezeQuick:
		sub.w	(v_camera_y_pos).w,d0			; d0 = -ve if object is above screen
		cmpi.w	#-256,d0
		ble.s	.offscreen				; branch if 256px+ above screen
		cmpi.w	#256+screen_height,d0
		bge.s	.offscreen				; branch if 256px+ below screen
		rts						; do nothing if within 256px of screen
		
	.offscreen:
		addq.l	#4,sp					; don't execute object code after leaving this subroutine
		rts
