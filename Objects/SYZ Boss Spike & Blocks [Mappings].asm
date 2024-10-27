; ---------------------------------------------------------------------------
; Sprite mappings - blocks that	Robotnik picks up (SYZ)
; ---------------------------------------------------------------------------
Map_Cheese:	index *
		ptr frame_cheese_wholeblock
		ptr frame_cheese_broken
		
frame_cheese_wholeblock:
		spritemap
		piece	-$10, -$10, 4x2, $51
		piece	-$10, 0, 4x2, $59
		endsprite
		
frame_cheese_broken:
		spritemap
		piece	-16, -16, 2x2, $51
		piece	0, -16, 2x2, $55
		piece	-16, 0, 2x2, $59
		piece	0, 0, 2x2, $5D
		endsprite
