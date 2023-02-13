; ---------------------------------------------------------------------------
; Mega Drive setup/initialisation
; ---------------------------------------------------------------------------

EntryPoint:
		tst.l	(port_1_control_hi).l			; test port 1 & 2 control registers
		bne.s	.skip					; branch if not 0
		tst.w	(port_e_control_hi).l			; test ext port control register
	.skip:
		bne.w	SkipSetup				; branch if not 0

		lea	(vdp_control_port).l,a6
		lea	-4(a6),a4				; vdp_data_port
		move.b	(console_version).l,d0			; get hardware version (from $A10001)
		andi.b	#console_revision,d0
		beq.s	.no_tmss				; if the console has no TMSS, skip the security stuff
		move.l	#'SEGA',(tmss_sega).l			; move "SEGA" to TMSS register ($A14000)

	.no_tmss:
		move.w	(a6),d0					; clear write-pending flag in VDP to prevent issues if the 68k has been reset in the middle of writing a command long word to the VDP.
		moveq	#0,d0					; clear d0
		movea.l	d0,a0					; clear a0
		move.l	a0,usp					; set usp to $0

		stopZ80						; stop the Z80
		resetZ80_release				; reset	the Z80
		waitZ80						; wait for Z80 to stop
		
		lea	Z80_Startup(pc),a0
		lea	(z80_ram).l,a1
		moveq	#Z80_Startup_size-1,d0
	.loadz80:
		move.b	(a0)+,(a1)+				; load the Z80_Startup program byte by byte to Z80 RAM
		dbf	d0,.loadz80

		resetZ80_assert
		startZ80					; start	the Z80
		resetZ80_release				; reset	the Z80

		lea	($FF0000).l,a0
		moveq	#0,d0
		move.w	#(sizeof_ram/4)-1,d1
	.loop_ram:
		move.l	d0,(a0)+				; clear 4 bytes of RAM
		dbf	d1,.loop_ram				; repeat until the entire RAM is clear
		
		move.w	#vdp_md_display,(a6)			; set VDP display mode
		move.w	#vdp_auto_inc+2,(a6)			; set VDP increment
		
		move.l	#$C0000000,(a6)				; set VDP to CRAM write
		moveq	#(sizeof_pal_all/4)-1,d1		; set repeat times
	.loop_cram:
		move.l	d0,(a4)					; clear 2 palette colours
		dbf	d1,.loop_cram				; repeat until the entire CRAM is clear
		
		move.l	#$40000010,(a6)				; set VDP to VSRAM write
		moveq	#(sizeof_vsram/4)-1,d1
	.loop_vsram:
		move.l	d0,(a4)					; clear 4 bytes of VSRAM.
		dbf	d1,.loop_vsram				; repeat until the entire VSRAM is clear

		move.b	#$95,(psg_input).l			; set PSG channel volumes
		move.b	#$BF,(psg_input).l
		move.b	#$DF,(psg_input).l
		move.b	#$FF,(psg_input).l

		resetZ80_assert
		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		moveq	#0,d7
		movea.l	#0,a0
		movea.l	#0,a1
		movea.l	#0,a2
		movea.l	#0,a3
		movea.l	#0,a4
		movea.l	#0,a5					; clear all registers
		disable_ints

SkipSetup:
		bra.s	GameProgram				; begin game

; ===========================================================================
Z80_Startup:
		cpu	z80
		phase 	0

	; fill the Z80 RAM with 0 (with the exception of this program)
		xor	a					; a = 00h
		ld	bc,2000h-(.end+1)			; load the number of bytes to fill
		ld	de,.end+1				; load the destination address of the RAM fill (1 byte after end of program)
		ld	hl,.end					; load the source address of the RAM fill (a single 00 byte)
		ld	sp,hl					; set stack pointer to end of program(?)
		ld	(hl),a					; clear the first byte after the program code
		ldir						; fill the rest of the Z80 RAM with 00's

	; clear all registers
		pop	ix
		pop	iy
		ld	i,a
		ld	r,a
		pop	de
		pop	hl
		pop	af

		ex	af,af					; swap af with af'
		exx						; swap bc, de, and hl
		pop	bc
		pop	de
		pop	hl
		pop	af
		ld	sp,hl					; clear stack pointer

	; put z80 into an infinite loop
		di						; disable interrupts
		im	1					; set interrupt mode to 1 (the only officially supported interrupt mode on the MD)
		ld	(hl),0E9h				; set the first byte into a jp	(hl) instruction
		jp	(hl)					; jump to the first byte, causing an infinite loop to occur.

	.end:							; the space from here til end of Z80 RAM will be filled with 00's
		even						; align the Z80 start up code to the next even byte. Values below require alignment

Z80_Startup_size:
		cpu	68000
		dephase
