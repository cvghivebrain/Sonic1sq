; ---------------------------------------------------------------------------
; Subroutine to	move Sonic in demo mode

;	uses d0, d1, d2, a0, a1
; ---------------------------------------------------------------------------

MoveSonicInDemo:
		tst.w	(v_demo_mode).w				; is demo mode on?
		bne.s	.demo_on				; if yes, branch
		rts

.demo_on:
		tst.b	(v_joypad_hold_actual).w		; is start button pressed?
		bpl.s	.dontquit				; if not, branch
		tst.w	(v_demo_mode).w				; is this an ending sequence demo?
		bmi.s	.dontquit				; if yes, branch
		move.b	#id_Title,(v_gamemode).w		; go to title screen

	.dontquit:
		movea.l	(v_demo_ptr).w,a1			; get pointer for demo data
		move.w	(v_demo_input_counter).w,d0		; get number of inputs so far
		adda.w	d0,a1					; jump to current input
		move.b	(a1),d0					; get joypad state from demo
		lea	(v_joypad_hold_actual).w,a0		; (a0) = actual joypad state
		move.b	d0,d1
		moveq	#0,d2
		eor.b	d2,d0
		move.b	d1,(a0)+				; force demo input
		and.b	d1,d0
		move.b	d0,(a0)+
		subq.b	#1,(v_demo_input_time).w		; decrement timer for current input
		bcc.s	.end					; branch if 0 or higher
		move.b	3(a1),(v_demo_input_time).w		; get time for next input
		addq.w	#2,(v_demo_input_counter).w		; increment counter

	.end:
		rts

; ---------------------------------------------------------------------------
; Unused subroutine for recording a demo

;	uses d0, a1
; ---------------------------------------------------------------------------

DemoRecorder:
		lea	($80000).l,a1				; memory address to record demo to
		move.w	(v_demo_input_counter).w,d0		; get number of inputs so far
		adda.w	d0,a1					; jump to last position in recorded data
		move.b	(v_joypad_hold_actual).w,d0		; get joypad input state
		cmp.b	(a1),d0					; is joypad input same as last frame?
		bne.s	.next					; if not, branch
		addq.b	#1,1(a1)				; increment time for current input
		cmpi.b	#$FF,1(a1)				; has input timer hit 255 (maximum)?
		beq.s	.next					; if yes, branch
		rts	

	.next:
		move.b	d0,2(a1)				; write new input state
		move.b	#0,3(a1)				; set time to 0
		addq.w	#2,(v_demo_input_counter).w		; increment counter
		andi.w	#$3FF,(v_demo_input_counter).w		; counter stops at $200 inputs
		rts
