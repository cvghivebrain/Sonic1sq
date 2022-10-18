; ---------------------------------------------------------------------------
; Animation script - Bosses (ship, Eggman and flame)
; ---------------------------------------------------------------------------

Ani_Bosses:	index *
		ptr ani_boss_ship				; 0
		ptr ani_boss_face1				; 1
		ptr ani_boss_face2				; 2
		ptr ani_boss_face3				; 3
		ptr ani_boss_laugh				; 4
		ptr ani_boss_hit				; 5
		ptr ani_boss_panic				; 6
		ptr ani_boss_blank				; 7
		ptr ani_boss_flame1				; 8
		ptr ani_boss_flame2				; 9
		ptr ani_boss_defeat				; $A
		ptr ani_boss_bigflame				; $B
		
ani_boss_ship:
		dc.w $F
		dc.w id_frame_boss_ship
		dc.w id_Anim_Flag_Restart
		even

ani_boss_face1:
		dc.w 5
		dc.w id_frame_boss_face1
		dc.w id_frame_boss_face2
		dc.w id_Anim_Flag_Restart
		even

ani_boss_face2:
		dc.w 3
		dc.w id_frame_boss_face1
		dc.w id_frame_boss_face2
		dc.w id_Anim_Flag_Restart
		even

ani_boss_face3:
		dc.w 1
		dc.w id_frame_boss_face1
		dc.w id_frame_boss_face2
		dc.w id_Anim_Flag_Restart
		even

ani_boss_laugh:
		dc.w 4
		dc.w id_frame_boss_laugh1
		dc.w id_frame_boss_laugh2
		dc.w id_Anim_Flag_Restart
		even

ani_boss_hit:
		dc.w $1F
		dc.w id_frame_boss_hit
		dc.w id_frame_boss_face1
		dc.w id_Anim_Flag_Restart
		even

ani_boss_panic:
		dc.w 3
		dc.w id_frame_boss_panic
		dc.w id_frame_boss_face1
		dc.w id_Anim_Flag_Restart
		even

ani_boss_blank:
		dc.w $F
		dc.w id_frame_boss_blank
		dc.w id_Anim_Flag_Restart
		even

ani_boss_flame1:
		dc.w 3
		dc.w id_frame_boss_flame1
		dc.w id_frame_boss_flame2
		dc.w id_Anim_Flag_Restart
		even

ani_boss_flame2:
		dc.w 1
		dc.w id_frame_boss_flame1
		dc.w id_frame_boss_flame2
		dc.w id_Anim_Flag_Restart
		even

ani_boss_defeat:
		dc.w $F
		dc.w id_frame_boss_defeat
		dc.w id_Anim_Flag_Restart
		even

ani_boss_bigflame:
		dc.w 2
		dc.w id_frame_boss_flame2
		dc.w id_frame_boss_flame1
		dc.w id_frame_boss_bigflame1
		dc.w id_frame_boss_bigflame2
		dc.w id_frame_boss_bigflame1
		dc.w id_frame_boss_bigflame2
		dc.w id_frame_boss_flame2
		dc.w id_frame_boss_flame1
		dc.w id_Anim_Flag_Back, 2
		even
