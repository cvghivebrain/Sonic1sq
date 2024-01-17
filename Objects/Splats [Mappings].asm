; ---------------------------------------------------------------------------
; Sprite mappings - Splats enemy
; ---------------------------------------------------------------------------
Map_Splats:	index *
		ptr frame_splats_fall
		ptr frame_splats_jump

frame_splats_fall:
		spritemap
		piece	-$C, -$14, 3x4, 0
		piece	-$C, $C, 3x1, $C
		endsprite

frame_splats_jump:
		spritemap
		piece	-$C, -$14, 3x4, $F
		piece	-5, $C, 2x1, $1B
		endsprite
