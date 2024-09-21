; ---------------------------------------------------------------------------
; Object code execution subroutine

; output:
;	d7.l = OST index of last object (not changed by any object)
;	a0 = address of OST of last object

;	uses d0.l, a1 (objects use registers d1-d6, a2-a4)
; ---------------------------------------------------------------------------

ExecuteObjects:
		lea	(v_ost_all).w,a0			; set address for object RAM
		moveq	#countof_ost-1,d7			; $80 objects -1
		cmpi.b	#id_Sonic_Death,(v_ost_player+ost_routine).w ; is Sonic dead?
		bhs.s	.dead					; if yes, branch

.run_object:
		move.l	ost_id(a0),d0				; load object pointer from RAM
		beq.s	.no_object				; branch if 0
		movea.l	d0,a1
		jsr	(a1)					; run the object's code

	.no_object:
		lea	sizeof_ost(a0),a0			; next object
		dbf	d7,.run_object
		rts	
; ===========================================================================

.dead:
		moveq	#countof_ost_inert-1,d7			; run first $20 objects normally
		bsr.s	.run_object
		moveq	#countof_ost_ert-1,d7			; remaining $60 objects are display only

ExeObj_Display:
		move.l	ost_id(a0),d0				; load object pointer
		beq.s	.no_object				; branch if 0
		tst.b	ost_render(a0)
		bpl.s	.no_object				; branch if off-screen
		bsr.w	DisplaySprite				; display only

	.no_object:
		lea	sizeof_ost(a0),a0			; next object
		dbf	d7,ExeObj_Display
		rts

; ---------------------------------------------------------------------------
; Display objects only without running them
; ---------------------------------------------------------------------------

ExecuteObjects_DisplayOnly:
		lea	(v_ost_all).w,a0			; set address for object RAM
		moveq	#countof_ost-1,d7			; all objects
		bra.s	ExeObj_Display
