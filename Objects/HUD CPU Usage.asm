; ---------------------------------------------------------------------------
; Debug CPU usage indicators

; spawned by:
;	HUD, CPUUsage
; ---------------------------------------------------------------------------

CPUUsage:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Usage_Index(pc,d0.w),d1
		jmp	Usage_Index(pc,d1.w)
; ===========================================================================
Usage_Index:	index *,,2
		ptr Usage_Main
		ptr Usage_VBlank
		ptr Usage_Frame
; ===========================================================================

Usage_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Usage_VBlank next
		move.l	#Map_HUD,ost_mappings(a0)
		move.b	#StrId_CPU,ost_name(a0)
		move.w	#tile_Art_Overlay,ost_tile(a0)
		move.b	#render_abs,ost_render(a0)
		move.w	#priority_0,ost_priority(a0)
		move.w	#screen_left,ost_x_pos(a0)
		move.b	#id_frame_hud_debugcpu,ost_frame(a0)
		
		jsr	FindFreeInert
		move.l	#CPUUsage,ost_id(a1)			; load frame usage object
		move.b	#id_Usage_Frame,ost_routine(a1)		; goto Usage_Frame next
		move.l	#Map_HUD,ost_mappings(a1)
		move.b	#StrId_CPU,ost_name(a1)
		move.w	#tile_Art_Overlay+tile_pal2,ost_tile(a1)
		move.b	#render_abs,ost_render(a1)
		move.w	#priority_0,ost_priority(a1)
		move.w	#screen_left,ost_x_pos(a1)
		move.b	#id_frame_hud_debugcpu,ost_frame(a1)
		saveparent

Usage_VBlank:	; Routine 2
		shortcut
		moveq	#0,d0
		move.b	(v_vblank_overflow_prev).w,d0		; get scanline drawn when VBlank overflows into frame
		addi.w	#screen_top,d0
		move.w	d0,ost_y_screen(a0)
		jmp	DisplaySprite
; ===========================================================================

Usage_Frame:	; Routine 4
		shortcut
		moveq	#0,d0
		move.b	(v_frame_usage).w,d0			; get scanline drawn when CPU usage for frame is complete
		addi.w	#screen_top,d0
		move.w	d0,ost_y_screen(a0)
		jmp	DisplaySprite
