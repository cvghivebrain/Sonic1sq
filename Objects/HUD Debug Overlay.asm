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
		ptr Overlay_Centre
		ptr Overlay_BoxLeft
		ptr Overlay_BoxRight
		ptr Overlay_CentreObj
		ptr Overlay_BoxLeftObj
		ptr Overlay_BoxRightObj
		
		rsobj DebugOverlay
ost_overlay_x_prev:	rs.w 1
ost_overlay_y_prev:	rs.w 1
		rsobjend
		
Overlay_Settings:
		dc.l Map_HUD
		dc.b id_frame_hud_debugsonic, id_Overlay_Sonic
		dc.w vram_overlay/sizeof_cell
		dc.w v_ost_player&$FFFF
		
		dc.l Map_HUD
		dc.b id_frame_hud_debugsonic, id_Overlay_Nearest
		dc.w vram_overlay2/sizeof_cell
		dc.w 0
		
		dc.l Map_Overlay
		dc.b id_frame_overlay_centre, id_Overlay_Centre
		dc.w vram_overlay3/sizeof_cell
		dc.w v_ost_player&$FFFF
		
		dc.l Map_Overlay
		dc.b id_frame_overlay_4, id_Overlay_BoxLeft
		dc.w vram_overlay3/sizeof_cell
		dc.w v_ost_player&$FFFF
		
		dc.l Map_Overlay
		dc.b id_frame_overlay_4, id_Overlay_BoxRight
		dc.w vram_overlay3/sizeof_cell
		dc.w v_ost_player&$FFFF
		
		dc.l Map_Overlay
		dc.b id_frame_overlay_centre, id_Overlay_CentreObj
		dc.w vram_overlay3/sizeof_cell
		dc.w 0
		
		dc.l Map_Overlay
		dc.b id_frame_overlay_4, id_Overlay_BoxLeftObj
		dc.w vram_overlay3/sizeof_cell
		dc.w 0
		
		dc.l Map_Overlay
		dc.b id_frame_overlay_4, id_Overlay_BoxRightObj
		dc.w vram_overlay3/sizeof_cell
		dc.w 0
; ===========================================================================

Overlay_Main:	; Routine 0
		movea.l	a0,a1					; write current object first
		lea	Overlay_Settings(pc),a2
		moveq	#8-1,d1
		bra.s	.first_obj

	.loop:
		jsr	FindFreeFinal
		bne.s	.fail
		move.l	#DebugOverlay,ost_id(a1)
		
	.first_obj:
		move.l	(a2)+,ost_mappings(a1)
		move.b	(a2)+,ost_frame(a1)
		move.b	(a2)+,ost_routine(a1)
		move.w	(a2)+,ost_tile(a1)
		move.w	(a2)+,ost_linked(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#priority_0,ost_priority(a1)
		move.b	#16,ost_displaywidth(a1)
		dbf	d1,.loop
		
		moveq	#id_UPLC_Overlay,d0
		jsr	UncPLC
		
	.fail:
		rts
; ===========================================================================
		
Overlay_Display:
		tst.b	ost_subtype(a0)
		bne.s	.dont_display				; branch if overlay is set to invisible
		jmp	DisplaySprite
		
	.dont_display:
		rts
; ===========================================================================

Overlay_Sonic:	; Routine 2
		shortcut
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
		shortcut
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
		getlinked					; a1 = OST of Sonic/linked object
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
		addi.w	#24,d0
		move.w	(v_camera_y_pos).w,d1
		addi.w	#screen_height-16,d1			; d1 = y pos of bottom of screen
		cmp.w	d0,d1
		bcc.s	.is_visible				; branch if numbers are fully visible
		subi.w	#48+16,d0				; move numbers above linked object instead
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
; ===========================================================================

Overlay_Centre:	; Routine 6
		shortcut
		btst	#bitZ,(v_joypad_press_actual_xyz).w	; is Z pressed?
		beq.s	Overlay_Centre_Display			; if not, branch
		move.w	(v_debug_hitbox_setting).w,d0
		addi.w	#1,d0
		cmpi.w	#3,d0
		bne.s	.value_valid				; branch if 0-2
		moveq	#0,d0					; wrap to 0
		
	.value_valid:
		move.w	d0,(v_debug_hitbox_setting).w		; update setting
		
Overlay_Centre_Display:
		cmpi.w	#2,(v_debug_hitbox_setting).w
		beq.s	Overlay_Hide				; don't display on setting #2
		getlinked					; a1 = OST of Sonic/linked object
		move.w	ost_x_pos(a1),ost_x_pos(a0)
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		jmp	DisplaySprite
		
Overlay_Hide:
		rts
; ===========================================================================

Overlay_CentreObj:
		; Routine $C
		move.w	(v_nearest_obj).w,ost_linked(a0)	; link to object nearest Sonic
		bra.s	Overlay_Centre_Display
; ===========================================================================

Overlay_BoxRight:
		; Routine $A
		bset	#render_xflip_bit,ost_render(a0)
		move.b	#id_Overlay_BoxLeft,ost_routine(a0)
		
Overlay_BoxLeft:
		; Routine 8
		shortcut
		moveq	#0,d2
		move.w	(v_debug_hitbox_setting).w,d0
		bne.s	.hitbox_or_none				; branch on settings 1-2
		getsonic					; a1 = OST of Sonic object
		move.b	ost_width(a1),d0
		moveq	#0,d1
		move.b	ost_height(a1),d1
		bclr	#tile_pal12_bit,ost_tile(a0)
		bra.s	Overlay_SetBox
		
	.hitbox_or_none:
		cmpi.w	#2,d0
		beq.s	Overlay_Hide				; don't display on setting #2
		getsonic					; a1 = OST of Sonic object
		moveq	#0,d1
		move.b	(v_player1_hitbox_width).w,d0
		move.b	(v_player1_hitbox_height).w,d1
		cmpi.b	#id_Roll,ost_anim(a1)
		bne.s	.not_rolling				; branch if Sonic isn't rolling/jumping
		move.b	(v_player1_hitbox_width_roll).w,d0
		move.b	(v_player1_hitbox_height_roll).w,d1
		
	.not_rolling:
		cmpi.b	#id_Duck,ost_anim(a1)
		bne.s	.not_ducking				; branch if Sonic isn't ducking
		moveq	#6,d2					; hitbox is 6px lower
		subi.b	#6,d1					; smaller hitbox when ducking
		
	.not_ducking:
		bset	#tile_pal12_bit,ost_tile(a0)
		
Overlay_SetBox:
		btst	#render_xflip_bit,ost_render(a0)
		bne.s	.not_left				; branch if not the left side
		neg.w	d0
		
	.not_left:
		add.w	ost_x_pos(a1),d0
		move.w	d0,ost_x_pos(a0)			; adjust x pos according to width
		move.w	ost_y_pos(a1),ost_y_pos(a0)
		add.w	d2,ost_y_pos(a0)
		move.w	d1,ost_frame_hi(a0)			; use frame according to height
		jmp	DisplaySprite
; ===========================================================================

Overlay_BoxRightObj:
		; Routine $10
		bset	#render_xflip_bit,ost_render(a0)
		move.b	#id_Overlay_BoxLeftObj,ost_routine(a0)
		
Overlay_BoxLeftObj:
		; Routine $E
		shortcut
		moveq	#0,d2
		move.w	(v_debug_hitbox_setting).w,d0
		bne.s	.hitbox_or_none				; branch on settings 1-2
		moveq	#-1,d3
		move.w	(v_nearest_obj).w,d3
		movea.l	d3,a1					; a1 = OST of linked object
		move.b	ost_width(a1),d0
		beq.w	Overlay_Hide				; don't display if width is 0
		moveq	#0,d1
		move.b	ost_height(a1),d1
		beq.w	Overlay_Hide				; don't display if height is 0
		bclr	#tile_pal12_bit,ost_tile(a0)
		bra.s	Overlay_SetBox
		
	.hitbox_or_none:
		cmpi.w	#2,d0
		beq.w	Overlay_Hide				; don't display on setting #2
		moveq	#-1,d3
		move.w	(v_nearest_obj).w,d3
		movea.l	d3,a1					; a1 = OST of linked object
		tst.b	ost_col_type(a1)			; get hitbox id
		beq.w	Overlay_Hide				; don't display if object has no hitbox
		moveq	#0,d0
		moveq	#0,d1
		move.b	ost_col_width(a1),d0			; get width
		move.b	ost_col_height(a1),d1			; get height
		bset	#tile_pal12_bit,ost_tile(a0)
		bra.w	Overlay_SetBox
		