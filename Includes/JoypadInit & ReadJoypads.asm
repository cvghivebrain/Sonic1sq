; ---------------------------------------------------------------------------
; Subroutine to	initialise joypads

;	uses d0.l
; ---------------------------------------------------------------------------

JoypadInit:
		stopZ80
		waitZ80
		moveq	#$40,d0
		move.b	d0,(port_1_control).l			; set TH pin of port 1 to write, other pins to read
		move.b	d0,(port_2_control).l			; set TH pin of port 2 to write, other pins to read
		move.b	d0,(port_e_control).l			; set TH pin of expansion port to write, other pins to read
		startZ80
		rts

; ---------------------------------------------------------------------------
; Subroutine to	read joypad input, and send it to the RAM

;	uses d0.b, d1.b, d2.b, a0, a1
; ---------------------------------------------------------------------------

ReadJoypads:
		lea	(v_joypad_hold_actual).w,a0		; address where joypad states are written
		lea	(port_1_data).l,a1			; first joypad port
		bsr.s	.read					; do the first joypad
		addq.w	#2,a1					; do the second	joypad

	.read:
		move.b	#0,(a1)					; set port to read 00SA00DU
		nop	
		nop	
		move.b	(a1),d0					; d0 = 00SA00DU
		add.b	d0,d0
		add.b	d0,d0					; d0 = SA00DU00
		andi.b	#%11000000,d0				; d0 = SA000000
		move.b	#$40,(a1)				; set port to read 00CBRLDU
		nop	
		nop	
		move.b	(a1),d1					; d1 = 00CBRLDU
		
		move.b	#0,(a1)
		nop	
		nop	
		move.b	#$40,(a1)
		nop	
		nop	
		move.b	#0,(a1)
		nop	
		nop	
		move.b	#$40,(a1)				; set port to read 00CBMXYZ
		nop	
		nop	
		move.b	(a1),d2					; d2 = 00CBMXYZ
		
		andi.b	#%00111111,d1				; d1 = 00CBRLDU
		or.b	d1,d0					; d0 = SACBRLDU
		not.b	d0					; invert bits, so that 1 = pressed
		move.b	(a0),d1					; d1 = previous joypad state
		eor.b	d0,d1
		move.b	d0,(a0)+				; v_joypad_hold_actual = SACBRLDU
		and.b	d0,d1					; d1 = new joypad inputs only
		move.b	d1,(a0)+				; v_joypad_press_actual = SACBRLDU (new only)
		
		not.b	d2					; invert bits, so that 1 = pressed
		andi.b	#%00001111,d2				; d2 = 0000MXYZ
		move.b	(a0),d1					; d1 = previous joypad state
		eor.b	d2,d1
		move.b	d2,(a0)+				; v_joypad_hold_actual_xyz = 0000MXYZ
		and.b	d2,d1					; d1 = new joypad inputs only
		move.b	d1,(a0)+				; v_joypad_press_actual_xyz = 0000MXYZ (new only)
		rts
