; ---------------------------------------------------------------------------
; When debug mode is currently in use
; ---------------------------------------------------------------------------

DebugMode:
		moveq	#0,d0
		move.b	(v_debug_active_hi).w,d0
		move.w	Debug_Index(pc,d0.w),d1
		jsr	Debug_Index(pc,d1.w)
		jmp	DisplaySprite
; ===========================================================================
Debug_Index:	index *,,2
		ptr Debug_Main
		ptr Debug_Action
; ===========================================================================

Debug_Main:	; Routine 0
		addq.b	#2,(v_debug_active_hi).w
		;move.w	(v_boundary_top).w,(v_boundary_top_debugcopy).w ; buffer level top boundary
		;move.w	(v_boundary_bottom_next).w,(v_boundary_bottom_debugcopy).w ; buffer level bottom boundary
		;move.w	#0,(v_boundary_top).w
		;move.w	#$720,(v_boundary_bottom_next).w	; set new boundaries
		andi.w	#$7FF,ost_y_pos(a0)
		andi.w	#$7FF,(v_camera_y_pos).w
		andi.w	#$3FF,(v_bg1_y_pos).w
		moveq	#0,d0
		move.b	d0,ost_status(a0)
		move.b	d0,ost_anim(a0)
		move.w	d0,ost_inertia(a0)
		move.w	d0,ost_x_vel(a0)
		move.w	d0,ost_y_vel(a0)
		movea.l	(v_debug_ptr).w,a2
		move.w	(v_debug_item_index).w,d0
		movea.l	a0,a3
		
Debug_GetFrame:
		move.b	9(a2,d0.w),d1
		andi.b	#status_xflip+status_yflip,d1
		andi.b	#$FF-render_xflip-render_yflip,ost_render(a3)
		or.b	d1,ost_render(a3)			; load x/yflip for item
		or.b	d1,ost_status(a3)
		
Debug_GetFrame_SkipStatus:
		move.l	4(a2,d0.w),ost_mappings(a3)		; load mappings for item
		move.w	10(a2,d0.w),ost_frame_hi(a3)		; load frame number for item
		move.l	12(a2,d0.w),d1				; load VRAM setting
		bpl.s	.not_ram				; branch if not a RAM address
		movea.l	d1,a4
		move.w	(a4),d1					; get tile setting from RAM
		
	.not_ram:
		or.w	16(a2,d0.w),d1				; add modifier to VRAM setting
		move.w	d1,ost_tile(a3)				; load VRAM setting for item
		rts
; ===========================================================================

Debug_Action:	; Routine 2
		move.w	ost_x_pos(a0),d0
		move.w	ost_y_pos(a0),d1
		moveq	#3,d6
		bsr.w	WallLeftDist
		move.w	d5,ost_angle(a0)
		movea.l	(v_debug_ptr).w,a2
		bsr.s	Debug_Control
		bsr.w	Debug_ChgItem
		bsr.w	Debug_Create
		bra.w	Debug_Restore

; ---------------------------------------------------------------------------
; Subroutine for directional movement in debug mode
; ---------------------------------------------------------------------------

Debug_Control:
		move.b	(v_joypad_hold_actual).w,d0
		btst	#bitA,d0
		bne.s	.exit					; branch if A is held
		andi.w	#btnDir,d0
		bne.s	.move_constant				; branch if direction held
		
	.exit:
		move.w	#0,(v_debug_move_time).w		; reset timer
		rts
		
	.move_constant:
		move.w	(v_debug_move_time).w,d1
		move.w	Debug_Speeds(pc,d1.w),d2
		
		btst	#bitUp,d0
		beq.s	.not_up
		sub.w	d2,ost_y_pos(a0)
		
	.not_up:
		btst	#bitDn,d0
		beq.s	.not_down
		add.w	d2,ost_y_pos(a0)
		
	.not_down:
		btst	#bitL,d0
		beq.s	.not_left
		sub.w	d2,ost_x_pos(a0)
		
	.not_left:
		btst	#bitR,d0
		beq.s	.exit2
		add.w	d2,ost_x_pos(a0)
		
	.exit2:
		cmpi.w	#Debug_Speeds_end-Debug_Speeds-2,d1
		beq.s	.dont_inc				; branch if at max
		addq.w	#2,d1					; increment timer
		move.w	d1,(v_debug_move_time).w		; update timer
		
	.dont_inc:
		rts
		
Debug_Speeds:	dc.w 1,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,6,6,6,6,7,7,7,7,8,8,8,8
	Debug_Speeds_end:

; ---------------------------------------------------------------------------
; Subroutine to switch between objects
; ---------------------------------------------------------------------------

Debug_ChgItem:
		btst	#bitA,(v_joypad_press_actual).w		; is button A pressed?
		beq.s	.skip_item_menu				; if not, branch
		moveq	#2-1,d1
		move.w	#$40,d2
		
	.loop:
		jsr	FindFreeInert
		bne.s	.skip_item_menu
		move.l	#DebugItemAdjacent,ost_id(a1)		; load debug item menu
		move.b	d1,ost_subtype(a1)
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		add.w	d2,ost_x_pos(a1)			; first object is to the right
		move.b	#render_rel,ost_render(a1)
		neg.w	d2					; second object will be to the left
		dbf	d1,.loop
		
	.skip_item_menu:
		btst	#bitA,(v_joypad_hold_actual).w		; is button A held?
		beq.s	.exit					; if not, branch
		move.b	(v_joypad_press_actual).w,d1
		btst	#bitL,d1
		bne.s	.left					; branch if left is pressed
		btst	#bitR,d1
		bne.s	.right					; branch if right is pressed
		btst	#bitUp,d1
		bne.s	.up					; branch if up is pressed
		btst	#bitDn,d1
		beq.s	.exit					; branch if down isn't pressed
		
.down:
		bchg	#status_xflip_bit,ost_status(a0)
		bchg	#status_xflip_bit,ost_render(a0)	; toggle xflip
		bra.s	.blip
		
.up:
		bchg	#status_yflip_bit,ost_status(a0)
		bchg	#status_yflip_bit,ost_render(a0)	; toggle yflip
		bra.s	.blip

.right:
		move.w	(v_debug_item_index).w,d0
		cmp.w	(v_debug_lastitem).w,d0
		beq.s	.last_item				; branch if on the last item
		addi.w	#sizeof_dbitem,d0			; next item
		bra.s	.display				; update visual
		
	.last_item:
		moveq	#0,d0					; wrap to start
		bra.s	.display

.left:
		move.w	(v_debug_item_index).w,d0
		beq.s	.first_item				; branch if on the first item
		subi.w	#sizeof_dbitem,d0			; previous item
		bra.s	.display
		
	.first_item:
		move.w	(v_debug_lastitem).w,d0			; wrap to end

	.display:
		move.w	d0,(v_debug_item_index).w
		movea.l	a0,a3
		bsr.w	Debug_GetFrame
		
	.blip:
		play.w	1, jmp, sfx_Switch			; play sound

	.exit:
		rts
		
; ---------------------------------------------------------------------------
; Debug item menu objects
; ---------------------------------------------------------------------------

DebugItemAdjacent:
		tst.l	ost_mappings(a0)
		beq.s	.first_load				; branch if object has just been loaded
		btst	#bitA,(v_joypad_hold_actual).w		; is button A held?
		beq.s	.delete					; if not, branch
		move.b	(v_joypad_press_actual).w,d1
		andi.b	#btnL+btnR,d1
		beq.s	.display				; branch if left/right isn't pressed
		
	.first_load:
		tst.b	ost_subtype(a0)
		bne.s	.next_item				; branch if this is the "next item" object
		move.w	(v_debug_item_index).w,d0
		bne.s	.not_first				; branch if selected item isn't first item
		move.w	(v_debug_lastitem).w,d0			; wrap to end
		bra.s	.get_frame
		
	.not_first:
		subi.w	#sizeof_dbitem,d0			; use item before current one
		
	.get_frame:
		movea.l	a0,a3
		bsr.w	Debug_GetFrame				; get appropriate mappings/frame/VRAM settings
		
	.display:
		jmp	DisplaySprite
		
	.delete:
		jmp	DeleteObject

.next_item:
		move.w	(v_debug_item_index).w,d0
		cmp.w	(v_debug_lastitem).w,d0
		bne.s	.not_last				; branch if selected item isn't last item
		moveq	#0,d0					; wrap to start
		bra.s	.get_frame
		
	.not_last:
		addi.w	#sizeof_dbitem,d0			; use item after current one
		bra.s	.get_frame
		
; ---------------------------------------------------------------------------
; Subroutine to create an object
; ---------------------------------------------------------------------------

Debug_Create:
		btst	#bitC,(v_joypad_press_actual).w		; is button C pressed?
		beq.s	.exit					; if not, branch
		jsr	(FindFreeObj).l
		bne.s	.exit
		move.w	ost_x_pos(a0),ost_x_pos(a1)
		move.w	ost_y_pos(a0),ost_y_pos(a1)
		move.w	(v_debug_item_index).w,d0
		move.l	(a2,d0.w),ost_id(a1)			; create object
		move.b	8(a2,d0.w),ost_subtype(a1)
		move.b	9(a2,d0.w),d1
		andi.b	#$FF-status_xflip-status_yflip,d1
		or.b	ost_status(a0),d1			; use x/yflip from Sonic
		move.b	d1,ost_status(a1)
		move.b	ost_render(a0),ost_render(a1)
		movea.l	a1,a3
		bsr.w	Debug_GetFrame_SkipStatus		; get mappings, frame & tile setting
		play.w	1, jmp, sfx_ActionBlock			; play sound
		
	.exit:
		rts
		
; ---------------------------------------------------------------------------
; Subroutine to restore Sonic from debug mode
; ---------------------------------------------------------------------------

Debug_Restore:
		btst	#bitB,(v_joypad_press_actual).w		; is button B pressed?
		beq.s	.exit					; if not, branch
		moveq	#0,d0
		move.w	d0,(v_debug_active).w			; deactivate debug mode
		move.l	#Map_Sonic,ost_mappings(a0)
		move.w	#tile_sonic,ost_tile(a0)
		move.b	d0,ost_anim(a0)
		move.b	d0,ost_anim_frame(a0)
		move.w	d0,ost_x_sub(a0)
		move.w	d0,ost_y_sub(a0)
		move.w	#id_frame_walk13,ost_frame_hi(a0)
		;move.w	(v_boundary_top_debugcopy).w,(v_boundary_top).w ; restore level boundaries
		;move.w	(v_boundary_bottom_debugcopy).w,(v_boundary_bottom_next).w
		cmpi.b	#id_Special,(v_gamemode).w
		bne.s	.exit					; branch if not in the special stage

		clr.w	(v_ss_angle).w
		move.w	#$40,(v_ss_rotation_speed).w		; set new level rotation speed
		move.b	#id_Roll,ost_anim(a0)
		ori.b	#status_jump+status_air,ost_status(a0)

	.exit:
		rts
