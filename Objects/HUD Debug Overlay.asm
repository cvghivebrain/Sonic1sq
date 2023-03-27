; ---------------------------------------------------------------------------
; Debug overlay objects

; spawned by:
;	HUD
; ---------------------------------------------------------------------------

DebugOverlay:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Overlay_Index(pc,d0.w),d1
		jmp	Overlay_Index(pc,d1.w)
; ===========================================================================
Overlay_Index:	index *,,2
		ptr Overlay_Main
		ptr Overlay_Sonic
		ptr Overlay_Nearest
		
		rsobj DebugOverlay
ost_overlay_x_prev:	rs.w 1
ost_overlay_y_prev:	rs.w 1
		rsobjend
		
Overlay_Settings:
		dc.b id_frame_hud_debugsonic, id_Overlay_Sonic
		dc.w vram_overlay/sizeof_cell
		dc.w v_ost_player&$FFFF
		
		dc.b id_frame_hud_debugsonic, id_Overlay_Nearest
		dc.w vram_overlay2/sizeof_cell
		dc.w 0
; ===========================================================================

Overlay_Main:	; Routine 0
		movea.l	a0,a1					; write current object first
		lea	Overlay_Settings(pc),a2
		moveq	#2-1,d1
		bra.s	.first_obj

	.loop:
		jsr	FindFreeInert
		bne.s	.fail
		move.l	#DebugOverlay,ost_id(a1)
		
	.first_obj:
		move.l	#Map_HUD,ost_mappings(a1)
		move.b	(a2)+,ost_frame(a1)
		move.b	(a2)+,ost_routine(a1)
		move.w	(a2)+,ost_tile(a1)
		move.w	(a2)+,ost_linked(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#0,ost_priority(a1)
		move.b	#16,ost_displaywidth(a1)
		dbf	d1,.loop
		
	.fail:
		rts
; ===========================================================================
		
Overlay_Display:
		tst.b	(f_hide_hud).w
		bne.s	.dont_display				; branch if HUD is set to not display
		tst.b	ost_subtype(a0)
		bne.s	.dont_display				; branch if overlay is set to invisible
		jmp	DisplaySprite
		
	.dont_display:
		rts
; ===========================================================================

Overlay_Sonic:	; Routine 2
		tst.b	(v_titlecard_loaded).w
		bne.s	.hide					; branch if title cards are visible
		btst	#bitY,(v_joypad_press_actual_xyz).w	; is Y pressed?
		beq.s	.y_not_pressed				; if not, branch
		move.w	(v_debug_ost_setting).w,d0
		addq.w	#4,d0					; increment setting
		cmpi.w	#Overlay_Words_end-Overlay_Words,d0
		bls.s	.setting_ok				; branch if setting is valid
		moveq	#0,d0					; wrap to 0
		
	.setting_ok:
		move.w	d0,(v_debug_ost_setting).w		; update setting
		
	.y_not_pressed:
		set_dma_dest	vram_overlay,d1			; VRAM address
		set_dma_dest	vram_overlay+$80,d4		; VRAM address
		bsr.s	Overlay_ShowWords
		bra.s	Overlay_Display
		
	.hide:
		rts
; ===========================================================================

Overlay_Nearest:
		; Routine 4
		tst.b	(v_titlecard_loaded).w
		bne.s	.hide					; branch if title cards are visible
		tst.w	ost_linked(a0)
		bne.s	.linked					; branch if target object is specified
		bsr.w	FindNearestSonic			; link to nearest object
		
	.linked:
		set_dma_dest	vram_overlay2,d1		; VRAM address
		set_dma_dest	vram_overlay2+$80,d4		; VRAM address
		bsr.s	Overlay_ShowWords
		
		btst	#bitX,(v_joypad_press_actual_xyz).w	; is X pressed?
		beq.w	Overlay_Display				; if not, branch
		clr.w	ost_linked(a0)				; recalculate nearest object
		bra.w	Overlay_Display
		
	.hide:
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to update overlay if values change
; ---------------------------------------------------------------------------

Overlay_ShowWords:
		bsr.w	GetLinked				; a1 = OST of Sonic/linked object
		move.w	(v_debug_ost_setting).w,d5
		cmpi.w	#Overlay_Words_end-Overlay_Words,d5
		beq.s	.dont_display				; branch if setting is $C
		move.b	#0,ost_subtype(a0)
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		
		move.w	Overlay_Words(pc,d5.w),d0		; get OST variable
		move.w	(a1,d0.w),d0				; get value from OST
		cmp.w	ost_overlay_x_prev(a0),d0
		beq.s	.skip_x					; branch if value hasn't changed
		move.w	d0,ost_overlay_x_prev(a0)
		bsr.w	HUD_ShowWord				; show object's x pos
		
	.skip_x:
		move.w	ost_y_pos(a1),d0
		addi.w	#32,d0
		move.w	(v_camera_y_pos).w,d1
		addi.w	#screen_height-16,d1			; d1 = y pos of bottom of screen
		cmp.w	d0,d1
		bcc.s	.is_visible				; branch if numbers are fully visible
		subi.w	#64+16,d0				; move numbers above linked object instead
	.is_visible:
		move.w	d0,ost_y_pos(a0)
		
		addq.w	#2,d5					; next variable in list
		move.w	Overlay_Words(pc,d5.w),d0		; get OST variable
		move.w	(a1,d0.w),d0				; get value from OST
		cmp.w	ost_overlay_y_prev(a0),d0
		beq.w	.exit					; branch if value hasn't changed
		move.w	d0,ost_overlay_y_prev(a0)
		move.l	d4,d1					; VRAM address
		bra.w	HUD_ShowWord				; show object's y pos
		
	.dont_display:
		move.b	#1,ost_subtype(a0)			; set flag to hide
		
	.exit:
		rts
		
Overlay_Words:
		dc.w ost_x_pos, ost_y_pos
		dc.w ost_x_vel, ost_y_vel
		dc.w ost_angle, ost_routine
	Overlay_Words_end:
		