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
; ===========================================================================

Overlay_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Overlay_Sonic next
		move.l	#Map_HUD,ost_mappings(a0)
		move.b	#id_frame_hud_debugsonic,ost_frame(a0)
		move.w	#vram_overlay/sizeof_cell,ost_tile(a0)
		move.b	#render_rel,ost_render(a0)
		move.w	#priority_0,ost_priority(a0)
		move.b	#16,ost_displaywidth(a0)
		move.b	#StrId_Overlay,ost_name(a0)
		moveq	#id_UPLC_Overlay,d0
		jsr	UncPLC					; load corner & dot gfx
		jsr	CloneObjectLast				; create copy of this object
		bne.s	Overlay_Sonic
		move.b	#id_Overlay_Nearest,ost_routine(a1)
		move.w	#vram_overlay2/sizeof_cell,ost_tile(a1)
		saveparent
		
Overlay_Sonic:	; Routine 2
		bsr.w	Overlay_MakeBox				; create subsprite table
		tst.w	ost_subsprite(a0)
		beq.w	DeleteFamily				; branch if subsprites weren't loaded
		
		shortcut
		tst.b	(v_titlecard_loaded).w
		bne.w	Overlay_Hidden				; branch if title cards are visible
		getsubsprite					; a2 = subsprite table
		move.w	(v_debug_ost_setting).w,d4
		
		move.b	(v_joypad_press_actual_xyz).w,d0
		btst	#bitX,d0				; is X pressed?
		beq.s	.x_not_pressed				; if not, branch
		clr.w	(v_nearest_obj).w			; trigger other overlay to find another object
		
	.x_not_pressed:
		btst	#bitY,d0				; is Y pressed?
		beq.s	.y_not_pressed				; if not, branch
		addq.w	#4,d4					; increment setting
		cmpi.w	#Overlay_Words_end-Overlay_Words,d4
		bne.s	.setting_ok				; branch if setting is valid
		moveq	#0,d4					; wrap to 0
	.setting_ok:
		move.w	d4,(v_debug_ost_setting).w		; update setting
		
	.y_not_pressed:
		btst	#bitZ,d0				; is Z pressed?
		beq.s	.z_not_pressed				; if not, branch
		bchg	#0,(v_debug_hitbox_setting).w
		bset	#7,(v_debug_hitbox_setting).w
		bchg	#tile_pal12_bit,sub1+piece_tile(a2)	; toggle hitbox between red/yellow
		bchg	#tile_pal12_bit,sub2+piece_tile(a2)
		bchg	#tile_pal12_bit,sub3+piece_tile(a2)
		bchg	#tile_pal12_bit,sub4+piece_tile(a2)
		
	.z_not_pressed:
		btst	#bitM,d0				; is Mode pressed?
		beq.s	.m_not_pressed				; if not, branch
		bchg	#0,(f_debug_overlay_hide).w
		
	.m_not_pressed:
		tst.b	(f_debug_overlay_hide).w
		bne.w	Overlay_Hidden				; branch if overlay is set to hidden
		
		getsonic					; a1 = OST of Sonic
		set_dma_dest	vram_overlay,d1			; VRAM address
		moveq	#0,d5
		btst	#0,(v_debug_hitbox_setting).w
		bne.s	.yellow_hitbox				; branch if hitbox is set to yellow
		move.w	ost_height_hi(a1),d0			; use standard width/height
		move.w	ost_width_hi(a1),d2
		bra.s	Overlay_ShowBox
		
	.yellow_hitbox:
		move.w	(v_player1_hitbox_height_roll).w,d0
		move.w	(v_player1_hitbox_width_roll).w,d2
		cmpi.b	#id_Roll,ost_anim(a1)
		beq.s	Overlay_ShowBox				; branch if Sonic is rolling/jumping
		move.w	(v_player1_hitbox_height).w,d0
		move.w	(v_player1_hitbox_width).w,d2
		cmpi.b	#id_Duck,ost_anim(a1)
		bne.s	Overlay_ShowBox				; branch if Sonic isn't ducking
		moveq	#6,d5					; hitbox is 6px lower
		subq.w	#6,d0					; smaller hitbox when ducking
		
Overlay_ShowBox:
		move.w	#5,(a2)
		move.w	d0,d6
		neg.w	d0
		move.w	d0,sub1+piece_y_pos(a2)
		move.w	d0,sub2+piece_y_pos(a2)
		subq.w	#8,d6
		move.w	d6,sub3+piece_y_pos(a2)
		move.w	d6,sub4+piece_y_pos(a2)
		move.w	d2,d6
		neg.w	d2
		move.w	d2,sub1+piece_x_pos(a2)
		subq.w	#8,d6
		move.w	d6,sub2+piece_x_pos(a2)
		move.w	d2,sub3+piece_x_pos(a2)
		move.w	d6,sub4+piece_x_pos(a2)
		
Overlay_ShowDigits:
		lea	Overlay_Words(pc,d4.w),a3
		move.w	(a3)+,d0				; get OST variable
		move.w	(a1,d0.w),d0				; get value from OST
		cmp.w	ost_overlay_x_prev(a0),d0
		beq.s	.skip_word1				; branch if value hasn't changed
		move.w	d0,ost_overlay_x_prev(a0)
		bsr.w	HUD_ShowWord				; show object's x pos
		bra.s	.next_word
		
	.skip_word1:
		addi.l	#$800000,d1				; next word in VRAM
		
	.next_word:
		move.w	(a3)+,d0				; get OST variable
		move.w	(a1,d0.w),d0				; get value from OST
		cmp.w	ost_overlay_y_prev(a0),d0
		beq.s	.skip_word2				; branch if value hasn't changed
		move.w	d0,ost_overlay_y_prev(a0)
		bsr.w	HUD_ShowWord				; show object's y pos
		
	.skip_word2:
		move.w	ost_x_pos(a1),ost_x_pos(a0)		; match position to Sonic
		move.w	ost_y_pos(a1),d0
		add.w	d5,d0
		move.w	d0,ost_y_pos(a0)
		move.b	#id_frame_hud_debugsonic,ost_frame(a0)
		sub.w	(v_camera_y_pos).w,d0			; d0 = y pos relative to camera
		cmpi.w	#screen_height-40,d0
		ble.s	.on_screen				; branch if not outside bottom of screen
		move.b	#id_frame_hud_debugsonictop,ost_frame(a0) ; make digits appear above Sonic
		
	.on_screen:
		jmp	DisplaySprite
		
Overlay_Hidden:
		rts
		
Overlay_Words:
		dc.w ost_x_pos, ost_y_pos
		dc.w ost_x_vel, ost_y_vel
		dc.w ost_angle, ost_routine			; ost_routine includes ost_mode as low byte
	Overlay_Words_end:
	
; ---------------------------------------------------------------------------
; Subroutine to create subsprite table for hitbox
; ---------------------------------------------------------------------------

Overlay_MakeBox:
		bsr.w	FindFreeSub				; find free subsprite table
		bne.s	.fail
		move.w	a1,a3
		moveq	#5,d1					; 5 subsprites (centre dot & 4 corners)
		lea	Overlay_Box_Sprites(pc),a2
		bsr.w	InitSubFromList				; populate subsprite list
		move.w	#-1,sub0+piece_x_pos(a3)
		move.w	#-2,sub0+piece_y_pos(a3)		; set position of centre dot
		
	.fail:
		rts
		
Overlay_Box_Sprites:
		dc.w sprite1x1,tile_Art_Overlay+1+tile_hi	; piece size, tile setting
		dc.w sprite1x1,tile_Art_Overlay+tile_hi
		dc.w sprite1x1,tile_Art_Overlay+tile_xflip+tile_hi
		dc.w sprite1x1,tile_Art_Overlay+tile_yflip+tile_hi
		dc.w sprite1x1,tile_Art_Overlay+tile_xflip+tile_yflip+tile_hi
; ===========================================================================

Overlay_Nearest:
		; Routine 4
		bsr.w	Overlay_MakeBox				; create subsprite table
		tst.w	ost_subsprite(a0)
		beq.w	DeleteObject				; branch if subsprites weren't loaded
		
		shortcut
		tst.b	(f_debug_overlay_hide).w
		bne.w	Overlay_Hidden				; branch if overlay is set to hidden
		tst.b	(v_titlecard_loaded).w
		bne.w	Overlay_Hidden				; branch if title cards are visible
		tst.w	(v_nearest_obj).w
		bne.s	.linked					; branch if target object is specified
		
	.find_new:
		bsr.w	FindNearestSonic			; link to nearest object
		beq.w	Overlay_Hidden				; branch if no objects were found
		
	.linked:
		movea.w	(v_nearest_obj).w,a1			; a1 = OST of nearest object
		tst.l	ost_id(a1)
		beq.s	.find_new				; branch if nearest object is deleted
		
		getsubsprite					; a2 = subsprite table
		move.w	(v_debug_ost_setting).w,d4
		set_dma_dest	vram_overlay2,d1		; VRAM address
		moveq	#0,d5
		move.b	(v_debug_hitbox_setting).w,d0
		bpl.s	.skip_update				; branch if high bit of setting is 0
		bclr	#7,(v_debug_hitbox_setting).w
		bchg	#tile_pal12_bit,sub1+piece_tile(a2)	; toggle hitbox between red/yellow
		bchg	#tile_pal12_bit,sub2+piece_tile(a2)
		bchg	#tile_pal12_bit,sub3+piece_tile(a2)
		bchg	#tile_pal12_bit,sub4+piece_tile(a2)
		
	.skip_update:
		btst	#0,d0
		bne.s	.yellow_hitbox				; branch if hitbox is set to yellow
		move.w	ost_height_hi(a1),d0			; use standard width/height
		beq.s	.hide_hitbox				; branch if 0
		move.w	ost_width_hi(a1),d2
		bne.w	Overlay_ShowBox				; branch if not 0
		
	.hide_hitbox:
		move.w	#1,(a2)					; only show centre dot
		bra.w	Overlay_ShowDigits
		
	.yellow_hitbox:
		tst.b	ost_col_type(a1)			; get hitbox type id
		beq.s	.hide_hitbox				; don't display if object has no hitbox
		move.w	ost_col_height_hi(a1),d0		; get height
		move.w	ost_col_width_hi(a1),d2			; get width
		bra.w	Overlay_ShowBox
		
