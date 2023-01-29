; ---------------------------------------------------------------------------
; Object 80 - Continue screen elements

; spawned by:
;	GM_Continue - routines 0 (text), 4 (mini Sonic), $A (oval)
;	ContScrItem - routines 6 (mini Sonic), 8 (counter)
; ---------------------------------------------------------------------------

ContScrItem:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	CSI_Index(pc,d0.w),d1
		jmp	CSI_Index(pc,d1.w)
; ===========================================================================
CSI_Index:	index *,,2
		ptr CSI_Main
		ptr CSI_Display
		ptr CSI_MakeMiniSonic
		ptr CSI_AniMiniSonic
		ptr CSI_Counter
		ptr CSI_Oval
; ===========================================================================

CSI_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto CSI_Display next
		move.l	#Map_ContScr,ost_mappings(a0)
		move.w	#(vram_continue/sizeof_cell)+tile_hi,ost_tile(a0)
		move.b	#id_frame_cont_text,ost_frame(a0)
		move.b	#render_abs,ost_render(a0)
		move.b	#$3C,ost_displaywidth(a0)
		move.w	#screen_left+160,ost_x_pos(a0)
		move.w	#screen_top+64,ost_y_screen(a0)
		move.w	#0,(v_rings).w				; clear rings
		
		jsr	FindFreeInert
		move.l	#ContScrItem,ost_id(a1)			; load countdown object
		move.w	#screen_left+152,ost_x_pos(a1)
		move.w	#screen_top+118,ost_y_screen(a1)
		move.l	#v_rings_spriteindex,ost_mappings(a1)	; read mappings from RAM
		;move.w	#tile_Art_HUDNums_UPLC_Continue,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	#id_CSI_Counter,ost_routine(a1)
		move.w	#2,(v_rings_spriteindex).w		; sprite mappings internal pointer
		move.w	#2,(v_rings_spritecount).w		; 2 digits
		move.w	#$8000,(v_rings_sprite1+2).w		; sprite mappings priority high
		move.w	#$8000,(v_rings_sprite2+2).w
		move.w	#8,(v_rings_sprite1+4).w		; mappings position of low digit
		move.b	#1,(v_rings_sprite1+1).w		; 1x2 sprite size
		move.b	#1,(v_rings_sprite2+1).w

CSI_Display:	; Routine 2
		jmp	(DisplaySprite).l
; ===========================================================================

minisonic_width:	equ 16
minisonic_spacing:	equ 4

CSI_MakeMiniSonic:
		; Routine 4
		moveq	#0,d1
		move.b	(v_continues).w,d1
		bne.s	.got_continues				; branch if you have at least 1 continue
		jmp	(DeleteObject).l
		
	.got_continues:
		andi.b	#$F,d1					; max 15 mini Sonics
		move.w	d1,d2
		mulu.w	#minisonic_width/2,d2
		subq.b	#1,d1
		move.w	d1,d3
		mulu.w	#minisonic_spacing/2,d3
		add.w	d3,d2
		neg.w	d2
		add.w	#screen_left+(screen_width/2),d2	; d2 = x pos of leftmost mini Sonic
	
	.loop:
		jsr	FindFreeInert
		move.l	#ContScrItem,ost_id(a1)			; load mini Sonic object
		move.w	d2,ost_x_pos(a1)
		add.w	#minisonic_width+minisonic_spacing,d2	; x pos for next mini Sonic
		move.w	#screen_top+80,ost_y_screen(a1)
		move.b	#id_frame_cont_mini1,ost_frame(a1)
		move.b	#id_CSI_AniMiniSonic,ost_routine(a1)
		move.l	#Map_ContScr,ost_mappings(a1)
		move.w	#tile_Art_MiniSonic_UPLC_Continue+tile_hi,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		dbf	d1,.loop				; repeat for number of continues
		
		move.b	#1,ost_subtype(a1)			; flag last mini Sonic as rightmost
		jmp	(DeleteObject).l			; delete current spawner object

CSI_AniMiniSonic:
		; Routine 6
		tst.b	ost_subtype(a0)				; is this the rightmost mini Sonic?
		beq.s	CSI_Animate				; if not, branch
		cmpi.b	#id_CSon_Run,(v_ost_player+ost_routine).w ; is Sonic running?
		bcs.s	CSI_Animate				; if not, branch
		move.b	(v_vblank_counter_byte).w,d0
		andi.b	#1,d0					; read bit that changes every frame
		bne.s	CSI_Animate				; branch if 1
		tst.w	(v_ost_player+ost_x_vel).w		; is Sonic running?
		bne.s	CSI_Delete				; if yes, branch
		rts	

CSI_Animate:
		move.b	(v_vblank_counter_byte).w,d0
		andi.b	#$F,d0
		bne.s	.no_frame_chg
		bchg	#0,ost_frame(a0)			; animate every 16 frames

	.no_frame_chg:
		jmp	(DisplaySprite).l
; ===========================================================================

CSI_Delete:
		jmp	(DeleteObject).l

CSI_Counter:	; Routine 8
		cmpi.b	#id_CSon_Run,(v_ost_player+ost_routine).w
		bhs.s	.sonic_running				; branch if Sonic is running
		move.w	(v_countdown).w,d0			; get counter
		divu.w	#60,d0					; convert to seconds
		andi.w	#$F,d0					; read only lowest nybble
		jsr	HexToDec2
		move.b	(a1)+,(v_rings_sprite2+3).w		; set tile for tens digit
		move.b	(a1),(v_rings_sprite1+3).w		; set tile for low digit
		
	.sonic_running:
		jmp	(DisplaySprite).l

CSI_Oval:	; Routine $A
		move.l	#Map_ContScr,ost_mappings(a0)
		move.w	#(vram_continue/sizeof_cell)+tile_hi,ost_tile(a0)
		move.b	#render_abs,ost_render(a0)
		move.b	#$3C,ost_displaywidth(a0)
		move.w	#screen_left+160,ost_x_pos(a0)
		move.w	#screen_top+64,ost_y_screen(a0)
		move.b	#3,ost_priority(a0)
		move.b	#id_frame_cont_oval,ost_frame(a0)
		move.b	#id_CSI_Display,ost_routine(a0)		; goto CSI_Display next
		jmp	(DisplaySprite).l
