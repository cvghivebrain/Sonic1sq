; ---------------------------------------------------------------------------
; Always return to this address, bypassing ost_routine (recommended for
;  objects which don't change ost_routine)
; ---------------------------------------------------------------------------

shortcut:	macro
		ifarg \1
		move.l	#\1,ost_id(a0)
		else
		move.l	#.shortcut_here\@,ost_id(a0)
	.shortcut_here\@:
		endc
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
		
; ---------------------------------------------------------------------------
; Get distance between two objects (a0 and a1)

; output:
;	d0.w = x distance (-ve if Sonic is to the left)
;	d1.w = x distance (always +ve)
;	d2.w = y distance (-ve if Sonic is above)
;	d3.w = y distance (always +ve)
; ---------------------------------------------------------------------------

range_x:	macro
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0			; d0 = x dist (-ve if Sonic is to the left)
		mvabs.w	d0,d1					; make d1 +ve
		endm
		
range_y:	macro
		move.w	ost_y_pos(a1),d2
		sub.w	ost_y_pos(a0),d2			; d2 = y dist (-ve if Sonic is above)
		mvabs.w	d2,d3					; make d3 +ve
		endm

range_x_quick:	macro
		move.w	ost_x_pos(a1),d0
		sub.w	ost_x_pos(a0),d0			; d0 = x dist (-ve if Sonic is to the left)
		endm
		
range_y_quick:	macro
		move.w	ost_y_pos(a1),d2
		sub.w	ost_y_pos(a0),d2			; d2 = y dist (-ve if Sonic is above)
		endm

; ---------------------------------------------------------------------------
; Get distance between the hitboxes of two objects (a0 and a1)

; output:
;	d0.w = x distance (-ve if Sonic is to the left)
;	d1.w = x distance between hitbox edges (-ve if overlapping)
;	d2.w = y distance (-ve if Sonic is above)
;	d3.w = y distance between hitbox edges (-ve if overlapping)
;	d4.w = x position of Sonic on object, starting at 0 on left edge

;	uses d4.l, d5.l
; ---------------------------------------------------------------------------

range_x_exact:	macro
		range_x
		moveq	#0,d4
		move.b	ost_width(a1),d4
		sub.w	d4,d1
		move.b	ost_width(a0),d4
		sub.w	d4,d1					; d1 = x dist between hitbox edges (-ve if overlapping)
		endm
		
range_x_sonic:	macro
		range_x
		moveq	#0,d4
		move.b	(v_player1_width).w,d4			; use fixed player width value
		sub.w	d4,d1
		move.b	ost_width(a0),d4
		sub.w	d4,d1					; d1 = x dist between hitbox edges (-ve if overlapping)
		add.w	d0,d4					; d4 = Sonic's x pos relative to left edge
		endm
		
range_x_sonic0:	macro						; as above, but ignoring Sonic's width
		range_x
		moveq	#0,d4
		move.b	ost_width(a0),d4
		sub.w	d4,d1					; d1 = x dist between Sonic's x pos and object hitbox edge (-ve if overlapping)
		add.w	d0,d4					; d4 = Sonic's x pos relative to left edge
		endm
		
range_y_exact:	macro
		range_y
		moveq	#0,d5
		move.b	ost_height(a1),d5
		sub.w	d5,d3
		move.b	ost_height(a0),d5
		sub.w	d5,d3					; d3 = y dist between hitbox edges (-ve if overlapping)
		endm
		
; ---------------------------------------------------------------------------
; Set the animation id of an object to d0 (do nothing if it's the same as d0)

; input:
;	d0.b = new animation id

; output:
;	d1.b = previous animation id

; usage:
;		moveq	#id_ani_roll_roll,d0
;		set_anim
; ---------------------------------------------------------------------------

set_anim:	macro
		move.b	ost_anim(a0),d1				; get previous animation id
		andi.b	#$7F,d1					; ignore high bit (the no-restart flag)
		cmp.b	d0,d1					; compare with new id
		beq.s	.keepanim\@				; branch if same
		move.b	d0,ost_anim(a0)				; update animation id (and clear high bit)
	.keepanim\@:
		endm

; ---------------------------------------------------------------------------
; Halt object execution if it's above or below the screen

; input:
;	d0.w = y position

; usage:
;		move.w	ost_y_pos(a0),d0
;		waitvisible	120,240				; halt if object is 120px above or 240px below screen
; ---------------------------------------------------------------------------

waitvisible:	macro
		sub.w	(v_camera_y_pos).w,d0			; d0 = dist between object and top of screen (-ve if object is above)
		ifarg	\1
		cmpi.w	#-\1,d0
		else
		cmpi.w	#-256,d0
		endc
		bgt.s	.inrangetop\@				; branch if below upper limit
		rts						; object is above
	.inrangetop\@:
		ifarg	\2
		cmpi.w	#\2+screen_height,d0
		else
		cmpi.w	#256+screen_height,d0
		endc
		blt.s	.inrangebtm\@				; branch if above lower limit
		rts						; object is below
	.inrangebtm\@:
		endm
		