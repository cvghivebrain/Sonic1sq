; ---------------------------------------------------------------------------
; Object 79 - lamppost

; spawned by:
;	ObjPos_GHZ1, ObjPos_GHZ2, ObjPos_GHZ3 - subtypes 1/2/3/4
;	ObjPos_MZ1, ObjPos_MZ2, ObjPos_MZ3 - subtypes 1/2/5
;	ObjPos_SYZ1, ObjPos_SYZ2, ObjPos_SYZ3 - subtypes 1/2
;	ObjPos_LZ1, ObjPos_LZ2, ObjPos_LZ3 - subtypes 1/2
;	ObjPos_SLZ3 - subtype 1
;	ObjPos_SBZ1, ObjPos_SBZ3 - subtypes 1/2

; subtypes:
;	%LIIIIIII
;	L - 1 to lock screen to disallow backtracking after Sonic respawns
;	IIIIIII - lamppost id
; ---------------------------------------------------------------------------

Lamppost:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Lamp_Index(pc,d0.w),d1
		jmp	Lamp_Index(pc,d1.w)
; ===========================================================================
Lamp_Index:	index *,,2
		ptr Lamp_Main
		ptr Lamp_Blue
		ptr Lamp_Red
		ptr Lamp_Twirl

		rsobj Lamppost
ost_lamp_x_start:	rs.w 1					; original x-axis position
ost_lamp_y_start:	rs.w 1					; original y-axis position
ost_lamp_twirl_count:	rs.w 1					; length of time lamp has been twirled
		rsobjend
; ===========================================================================

Lamp_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Lamp_Blue next
		move.l	#Map_Lamp,ost_mappings(a0)
		move.w	(v_tile_lamppost).w,ost_tile(a0)
		move.b	#render_rel+render_useheight,ost_render(a0)
		move.b	#$2C,ost_height(a0)
		move.b	#8,ost_displaywidth(a0)
		move.b	#priority_5,ost_priority(a0)
		bsr.w	GetState
		bne.s	.red					; branch if lamppost has been hit

		move.b	(v_last_lamppost).w,d1			; get number of last lamppost hit
		andi.b	#$7F,d1
		move.b	ost_subtype(a0),d2			; get lamppost number
		andi.b	#$7F,d2
		cmp.b	d2,d1					; is this a "new" lamppost?
		bcs.s	Lamp_Blue				; if yes, branch

	.red:
		move.b	#id_Lamp_Red,ost_routine(a0)		; goto Lamp_Red next
		move.b	#id_frame_lamp_red,ost_frame(a0)	; use red lamppost frame
		bra.w	DespawnObject
; ===========================================================================

Lamp_Blue:	; Routine 2
		tst.w	(v_debug_active).w
		bne.w	DespawnObject				; branch if debug mode is in use
		tst.b	(v_lock_multi).w
		bmi.w	DespawnObject				; branch if collision is disabled
		
		getsonic					; a1 = OST of Sonic
		range_x_test	8
		bcc.w	DespawnObject
		range_y_test	$28
		bcc.w	DespawnObject

		play.w	1, jsr, sfx_Lamppost			; play lamppost sound
		addq.b	#2,ost_routine(a0)			; goto Lamp_Red next
		jsr	(FindNextFreeObj).l			; find free OST slot
		bne.s	.fail					; branch if not found
		move.l	#Lamppost,ost_id(a1)			; load twirling lamp object
		move.b	#id_Lamp_Twirl,ost_routine(a1)		; child object goto Lamp_Twirl next
		move.w	ost_x_pos(a0),ost_lamp_x_start(a1)
		move.w	ost_y_pos(a0),ost_lamp_y_start(a1)
		subi.w	#$18,ost_lamp_y_start(a1)
		move.l	#Map_Lamp,ost_mappings(a1)
		move.w	ost_tile(a0),ost_tile(a1)
		move.b	#render_rel,ost_render(a1)
		move.b	#8,ost_displaywidth(a1)
		move.b	#priority_4,ost_priority(a1)
		move.b	#id_frame_lamp_redballonly,ost_frame(a1) ; use "ball only" frame
		saveparent

	.fail:
		move.b	#id_frame_lamp_poleonly,ost_frame(a0)	; use "post only" frame
		bsr.w	Lamp_StoreInfo				; store Sonic's position, rings, lives etc.
		bsr.w	SaveState
		beq.w	DespawnObject				; branch if not in respawn table
		bset	#0,(a2)					; remember lamppost as red
; ===========================================================================

Lamp_Red:	; Routine 4
		shortcut	DespawnObject
		bra.w	DespawnObject
; ===========================================================================

Lamp_Twirl:	; Routine 6
		shortcut
		move.w	ost_lamp_twirl_count(a0),d0
		add.w	#4,d0					; increment counter
		cmpi.w	#32*4,d0
		bne.s	.keep_twirling				; keep twirling until finished
		getparent					; a1 = OST of actual lamppost
		move.b	#id_frame_lamp_red,ost_frame(a1)	; use red lamppost frame
		jmp	DeleteObject

	.keep_twirling:
		move.w	d0,ost_lamp_twirl_count(a0)		; update counter
		andi.w	#$3F,d0					; limit to 16 positions
		lea	Lamp_Twirl_Pos(pc,d0.w),a2		; get relative position
		move.w	(a2)+,d1
		add.w	ost_lamp_x_start(a0),d1
		move.w	d1,ost_x_pos(a0)
		move.w	(a2),d1
		add.w	ost_lamp_y_start(a0),d1
		move.w	d1,ost_y_pos(a0)
		jmp	DisplaySprite

Lamp_Twirl_Pos:	; x pos, y pos
		dc.w 0,-12					; default position
		dc.w -5,-12
		dc.w -9,-9
		dc.w -12,-5
		dc.w -12,0					; left position
		dc.w -12,4
		dc.w -9,8
		dc.w -5,11
		dc.w 0,12					; down position
		dc.w 4,11
		dc.w 8,8
		dc.w 11,4
		dc.w 12,0					; right position
		dc.w 11,-5
		dc.w 8,-9
		dc.w 4,-12
; ---------------------------------------------------------------------------
; Subroutine to	store information when you hit a lamppost
; ---------------------------------------------------------------------------

Lamp_StoreInfo:
		move.b	ost_subtype(a0),(v_last_lamppost).w	; lamppost number
		move.b	(v_last_lamppost).w,(v_last_lamppost_lampcopy).w
		move.w	ost_x_pos(a0),(v_sonic_x_pos_lampcopy).w ; x-position
		move.w	ost_y_pos(a0),(v_sonic_y_pos_lampcopy).w ; y-position
		move.l	(v_time).w,(v_time_lampcopy).w		; time
		move.b	(v_dle_routine).w,(v_dle_routine_lampcopy).w ; routine counter for dynamic level mod
		move.w	(v_boundary_bottom).w,(v_boundary_bottom_lampcopy).w ; lower y-boundary of level
		move.w	(v_camera_x_pos).w,(v_camera_x_pos_lampcopy).w ; screen x-position
		move.w	(v_camera_y_pos).w,(v_camera_y_pos_lampcopy).w ; screen y-position
		move.w	(v_bg1_x_pos).w,(v_bg1_x_pos_lampcopy).w ; bg position
		move.w	(v_bg1_y_pos).w,(v_bg1_y_pos_lampcopy).w ; bg position
		move.w	(v_bg2_x_pos).w,(v_bg2_x_pos_lampcopy).w ; bg position
		move.w	(v_bg2_y_pos).w,(v_bg2_y_pos_lampcopy).w ; bg position
		move.w	(v_bg3_x_pos).w,(v_bg3_x_pos_lampcopy).w ; bg position
		move.w	(v_bg3_y_pos).w,(v_bg3_y_pos_lampcopy).w ; bg position
		move.w	(v_water_height_normal).w,(v_water_height_normal_lampcopy).w ; water height
		move.b	(v_water_routine).w,(v_water_routine_lampcopy).w ; routine counter for water
		move.b	(f_water_pal_full).w,(f_water_pal_full_lampcopy).w ; water direction
		rts	

; ---------------------------------------------------------------------------
; Subroutine to	load stored info when you start	a level	from a lamppost
; ---------------------------------------------------------------------------

Lamp_LoadInfo:
		move.b	(v_last_lamppost_lampcopy).w,(v_last_lamppost).w
		move.w	(v_sonic_x_pos_lampcopy).w,(v_ost_player+ost_x_pos).w
		move.w	(v_sonic_y_pos_lampcopy).w,(v_ost_player+ost_y_pos).w
		clr.w	(v_rings).w
		clr.b	(v_ring_reward).w
		move.l	(v_time_lampcopy).w,(v_time).w
		move.b	#59,(v_time_frames).w			; second counter ticks at next frame
		subq.b	#1,(v_time_sec).w
		move.b	(v_dle_routine_lampcopy).w,(v_dle_routine).w
		move.w	(v_boundary_bottom_lampcopy).w,(v_boundary_bottom).w
		move.w	(v_boundary_bottom_lampcopy).w,(v_boundary_bottom_next).w
		move.w	(v_camera_x_pos_lampcopy).w,(v_camera_x_pos).w
		move.w	(v_camera_y_pos_lampcopy).w,(v_camera_y_pos).w
		move.w	(v_bg1_x_pos_lampcopy).w,(v_bg1_x_pos).w
		move.w	(v_bg1_y_pos_lampcopy).w,(v_bg1_y_pos).w
		move.w	(v_bg2_x_pos_lampcopy).w,(v_bg2_x_pos).w
		move.w	(v_bg2_y_pos_lampcopy).w,(v_bg2_y_pos).w
		move.w	(v_bg3_x_pos_lampcopy).w,(v_bg3_x_pos).w
		move.w	(v_bg3_y_pos_lampcopy).w,(v_bg3_y_pos).w
		tst.b	(f_water_enable).w			; is this a water level?
		beq.s	.notwater				; if not, branch

		move.w	(v_water_height_normal_lampcopy).w,(v_water_height_normal).w
		move.b	(v_water_routine_lampcopy).w,(v_water_routine).w
		move.b	(f_water_pal_full_lampcopy).w,(f_water_pal_full).w

	.notwater:
		tst.b	(v_last_lamppost).w
		bpl.s	.dont_lock				; branch if high bit of lamppost id is clear
		move.w	(v_sonic_x_pos_lampcopy).w,d0
		subi.w	#screen_width/2,d0
		move.w	d0,(v_boundary_left).w			; set left boundary to half a screen to Sonic's left
		
	.dont_lock:
		rts	
