; ---------------------------------------------------------------------------
; Subroutine to	clear CRAM and set default VDP register values

; output:
;	a1 = vdp_data_port ($C00000)
;	a6 = vdp_control_port ($C00004)

;	uses d0.l, d1.l, d7.l, a2
; ---------------------------------------------------------------------------

VDPSetupGame:
		lea	(vdp_control_port).l,a6
		lea	-4(a6),a1				; vdp_data_port
		lea	VDPSetupArray(pc),a2
		moveq	#((VDPSetupArray_end-VDPSetupArray)/2)-1,d7
	.setreg:
		move.w	(a2)+,(a6)
		dbf	d7,.setreg				; set the VDP registers

		move.w	(VDPSetupArray+2).l,d0
		move.w	d0,(v_vdp_mode_buffer).w		; save $8134 to buffer for later use
		move.w	#vdp_hint_counter+223,(v_vdp_hint_counter).w ; horizontal interrupt every 224th scanline

		moveq	#0,d0
		move.l	#$C0000000,(a6)				; set VDP to CRAM write
		move.w	#$40-1,d7
	.clrCRAM:
		move.w	d0,(a1)
		dbf	d7,.clrCRAM				; clear	the CRAM

		clr.l	(v_fg_y_pos_vsram).w
		
		locVRAM	0,d0
		move.l	#$FFFF,d1
		moveq	#0,d2
		bsr.w	ClearVRAM
		rts

; ===========================================================================
VDPSetupArray:	dc.w vdp_md_color				; $8004 - normal colour mode
		dc.w vdp_enable_vint|vdp_enable_dma|vdp_md_display ; $8134 - enable V.interrupts, enable DMA
		dc.w vdp_fg_nametable+(vram_fg>>10)		; set foreground nametable address
		dc.w vdp_window_nametable+(vram_window>>10)	; set window nametable address
		dc.w vdp_bg_nametable+(vram_bg>>13)		; set background nametable address
		dc.w vdp_sprite_table+(vram_sprites>>9)		; set sprite table address
		dc.w vdp_bg_color				; $8700 - set background colour (palette entry 0)
		dc.w vdp_hint_counter+0				; $8A00 - default H.interrupt register
		dc.w vdp_full_vscroll|vdp_full_hscroll		; $8B00 - full-screen vertical scrolling
		dc.w vdp_320px_screen_width			; $8C81 - 40-cell display mode
		dc.w vdp_hscroll_table+(vram_hscroll>>10)	; set background hscroll address
		dc.w vdp_auto_inc+2				; $8F02 - set VDP increment size
		dc.w vdp_plane_width_64|vdp_plane_height_32	; $9001 - 64x32 cell plane size
		dc.w vdp_window_x_pos				; $9100 - window horizontal position
		dc.w vdp_window_y_pos				; $9200 - window vertical position
		
		dc.w vdp_sprite_table2				; unused stuff that just needs initialising
		dc.w vdp_sms_hscroll
		dc.w vdp_sms_vscroll
		dc.w vdp_nametable_hi
	VDPSetupArray_end:
	
