; ---------------------------------------------------------------------------
; Animation script - Bosses
; ---------------------------------------------------------------------------

Ani_Bosses:	index *
		ptr ani_boss_ship
		
ani_boss_ship:
		dc.w $F
		dc.w id_frame_boss_ship
		dc.w id_Anim_Flag_Restart
		even
