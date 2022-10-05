; ---------------------------------------------------------------------------
; Sprite mappings - rising platform (LZ)
; ---------------------------------------------------------------------------
Map_LPlat:	index *
		ptr frame_lplat_0
		
frame_lplat_0:
		spritemap
		piece	-$20, -$C, 4x3, 0
		piece	0, -$C, 4x3, $C
		endsprite
		