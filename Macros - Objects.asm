; ---------------------------------------------------------------------------
; Always return to this address, bypassing ost_routine (recommended for
;  objects which don't change ost_routine)
; ---------------------------------------------------------------------------

shortcut:	macro
		move.l	.shortcut_here,ost_id(a0)
	.shortcut_here:
		endm
		
; ---------------------------------------------------------------------------
; Save the parent OST address to ost_parent in a child object

; usage:
;		bsr.w	FindFreeObj
;		bne.s	.fail
;		move.l	#Crabmeat,ost_id(a0)
;		saveparent					; use after creating a new object
; ---------------------------------------------------------------------------

saveparent:	macro
		move.w	a0,ost_parent(a1)
		endm

; ---------------------------------------------------------------------------
; Set a1 as the parent object

;	uses d0.l
; ---------------------------------------------------------------------------

getparent:	macro
		moveq	#-1,d0					; d0 = $FFFFFFFF
		move.w	ost_parent(a0),d0			; d0 = $FFFFxxxx
		ifarg \1
		movea.l	d0,\1
		else
		movea.l	d0,a1					; set a1 as parent
		endc
		endm
		
; ---------------------------------------------------------------------------
; Set a1 as linked object

;	uses d0.l
; ---------------------------------------------------------------------------

getlinked:	macro
		moveq	#-1,d0					; d0 = $FFFFFFFF
		move.w	ost_linked(a0),d0			; d0 = $FFFFxxxx
		ifarg \1
		movea.l	d0,\1
		else
		movea.l	d0,a1					; set a1 as linked
		endc
		endm
		
; ---------------------------------------------------------------------------
; Set a1 as Sonic
; ---------------------------------------------------------------------------

getsonic:	macro
		ifarg \1
		lea	(v_ost_player).w,\1
		else
		lea	(v_ost_player).w,a1			; set a1 as Sonic
		endc
		endm
		
; ---------------------------------------------------------------------------
; Convert speed to position (speed of $100 will move an object 1px per frame)

;	uses d0.l
; ---------------------------------------------------------------------------

update_x_pos:	macro
		move.w	ost_x_vel(a0),d0			; load horizontal speed
		ext.l	d0
		asl.l	#8,d0					; multiply speed by $100
		add.l	d0,ost_x_pos(a0)			; update x position
		endm

update_y_pos:	macro
		move.w	ost_y_vel(a0),d0			; load vertical speed
		ext.l	d0
		asl.l	#8,d0					; multiply speed by $100
		add.l	d0,ost_y_pos(a0)			; update y position
		endm

update_xy_pos:	macro
		update_x_pos
		update_y_pos
		endm
		
; ---------------------------------------------------------------------------
; Convert speed to position and apply gravity

; input:
;	\1 = gravity (default $38)

;	uses d0.l
; ---------------------------------------------------------------------------

update_y_fall:	macro
		update_y_pos
		ifarg \1
		addi.w	#\1,ost_y_vel(a0)			; increase falling speed
		else
		addi.w	#$38,ost_y_vel(a0)			; increase falling speed
		endc
		endm
		
update_xy_fall:	macro
		update_x_pos
		update_y_pos
		ifarg \1
		addi.w	#\1,ost_y_vel(a0)			; increase falling speed
		else
		addi.w	#$38,ost_y_vel(a0)			; increase falling speed
		endc
		endm
		