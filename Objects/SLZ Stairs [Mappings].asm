; ---------------------------------------------------------------------------
; Sprite mappings - blocks that	form a staircase (SLZ)
; ---------------------------------------------------------------------------
Map_Stair:	index *
		ptr frame_stair_all
		ptr frame_stair_jiggle1
		ptr frame_stair_jiggle2
		ptr frame_stair_block
		
frame_stair_all:
		spritemap
		piece	-64, -$10, 4x4, $21
		piece	-32, -$10, 4x4, $21
		piece	0, -$10, 4x4, $21
		piece	32, -$10, 4x4, $21
		endsprite
		
frame_stair_jiggle1:
		spritemap
		piece	-64, -$10, 4x4, $21
		piece	-32, -$F, 4x4, $21
		piece	0, -$10, 4x4, $21
		piece	32, -$F, 4x4, $21
		endsprite
		
frame_stair_jiggle2:
		spritemap
		piece	-64, -$F, 4x4, $21
		piece	-32, -$10, 4x4, $21
		piece	0, -$F, 4x4, $21
		piece	32, -$10, 4x4, $21
		endsprite
		
frame_stair_block:
		spritemap
		piece	-$10, -$10, 4x4, $21
		endsprite
