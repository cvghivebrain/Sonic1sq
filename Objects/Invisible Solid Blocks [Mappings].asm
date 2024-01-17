; ---------------------------------------------------------------------------
; Sprite mappings - invisible solid blocks (visible in debug mode)
; ---------------------------------------------------------------------------
Map_Invis:	index *
		ptr frame_invis_solid
		
frame_invis_solid:
		spritemap
		piece	-$10, -$10, 2x2, 0
		piece	0, -$10, 2x2, 0
		piece	-$10, 0, 2x2, 0
		piece	0, 0, 2x2, 0
		endsprite
