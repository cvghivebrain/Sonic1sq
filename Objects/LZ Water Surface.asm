; ---------------------------------------------------------------------------
; Object 1B - water surface (LZ)

; spawned by:
;	GM_Level
; ---------------------------------------------------------------------------

WaterSurface:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Surf_Index(pc,d0.w),d1
		jmp	Surf_Index(pc,d1.w)
; ===========================================================================
Surf_Index:	index *,,2
		ptr Surf_Main
		ptr Surf_Action
; ===========================================================================

Surf_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Surf_Action next
		move.l	#Map_Surf,ost_mappings(a0)
		move.w	#tile_Kos_Water+tile_pal3+tile_hi,ost_tile(a0)
		move.b	#render_rel+render_onscreen,ost_render(a0)
		move.b	#screen_width/2,ost_displaywidth(a0)

Surf_Action:	; Routine 2
		shortcut
		tst.b	ost_render(a0)
		bpl.w	DisplaySprite				; branch if above or below screen
		btst	#bitStart,(v_joypad_press_actual).w
		bne.s	Surf_Pause				; branch if paused
		move.w	(v_camera_x_pos).w,d1			; get camera x position
		andi.w	#$FFE0,d1				; align to $20
		btst	#0,(v_frame_counter_low).w
		beq.s	.even_frame				; branch on even frames
		addi.w	#$20,d1					; add $20 every other frame to create flicker

	.even_frame:
		move.w	d1,ost_x_pos(a0)			; match x position to screen position
		move.w	(v_water_height_actual).w,ost_y_pos(a0)	; match y position to water height
		lea	Ani_Surf(pc),a1
		jsr	AnimateSprite
		jmp	DisplaySprite
; ===========================================================================
		
Surf_Pause:
		move.b	#id_frame_surf_paused1,ost_frame(a0)
		move.w	(v_camera_x_pos).w,ost_x_pos(a0)
		move.w	(v_water_height_actual).w,ost_y_pos(a0)
		jmp	DisplaySprite
		
; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Surf:	index *
		ptr ani_surf_0
		
ani_surf_0:	dc.w 7
		dc.w id_frame_surf_normal1
		dc.w id_frame_surf_normal2
		dc.w id_frame_surf_normal3
		dc.w id_Anim_Flag_Restart
