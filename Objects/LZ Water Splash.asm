; ---------------------------------------------------------------------------
; Object 08 - water splash (LZ)

; spawned by:
;	SonicPlayer
; ---------------------------------------------------------------------------

Splash:
		moveq	#0,d0
		move.b	ost_routine(a0),d0
		move.w	Spla_Index(pc,d0.w),d1
		jmp	Spla_Index(pc,d1.w)
; ===========================================================================
Spla_Index:	index *,,2
		ptr Spla_Main
		ptr Spla_Display
		ptr Spla_Delete
; ===========================================================================

Spla_Main:	; Routine 0
		addq.b	#2,ost_routine(a0)			; goto Spla_Display next
		move.l	#Map_Splash,ost_mappings(a0)
		ori.b	#render_rel,ost_render(a0)
		move.b	#priority_1,ost_priority(a0)
		move.b	#$10,ost_displaywidth(a0)
		move.w	#tile_Kos_Splash+tile_pal3,ost_tile(a0)
		getsonic					; a1 = OST of Sonic
		move.w	ost_x_pos(a1),ost_x_pos(a0)		; copy x position from Sonic

Spla_Display:	; Routine 2
		move.w	(v_water_height_actual).w,ost_y_pos(a0)	; copy y position from water height
		lea	Ani_Splash(pc),a1
		jsr	AnimateSprite				; animate and goto Spla_Delete when finished
		bra.w	DisplaySprite
; ===========================================================================

Spla_Delete:	; Routine 4
		clr.b	(f_splash).w				; allow future splashes
		bra.w	DeleteObject				; delete when animation	is complete

; ---------------------------------------------------------------------------
; Animation script
; ---------------------------------------------------------------------------

Ani_Splash:	index *
		ptr ani_splash_0
		
ani_splash_0:	dc.w 4
		dc.w id_frame_splash_0
		dc.w id_frame_splash_1
		dc.w id_frame_splash_2
		dc.w id_Anim_Flag_Routine
