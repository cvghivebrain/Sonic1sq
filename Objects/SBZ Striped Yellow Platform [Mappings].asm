; ---------------------------------------------------------------------------
; Sprite mappings - striped yellow platform (SBZ)
; ---------------------------------------------------------------------------

Map_YPlat:	index *
		ptr frame_yplat_thin
		ptr frame_yplat_fat
		
frame_yplat_thin:
		spritemap
		piece	-$20, -8, 4x1, 0, pal2
		piece	-$20, 0, 4x2, 4
		piece	0, -8, 4x1, 0, pal2
		piece	0, 0, 4x2, 4
		endsprite
		
frame_yplat_fat:
		spritemap
		piece	-$20, -16, 4x1, 0, pal2
		piece	-$20, -8, 4x2, 4
		piece	-$20, 0, 4x2, 4
		piece	0, -16, 4x1, 0, pal2
		piece	0, -8, 4x2, 4
		piece	0, 0, 4x2, 4
		endsprite
