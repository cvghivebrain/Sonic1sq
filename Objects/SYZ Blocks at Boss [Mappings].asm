; ---------------------------------------------------------------------------
; Sprite mappings - blocks that	Robotnik picks up (SYZ)
; ---------------------------------------------------------------------------
Map_BossBlock:	index *
		ptr frame_bblock_wholeblock
		ptr frame_bblock_topleft
		ptr frame_bblock_topright
		ptr frame_bblock_bottomleft
		ptr frame_bblock_bottomright
		
frame_bblock_wholeblock:
		spritemap
		piece	-$10, -$10, 4x2, $51
		piece	-$10, 0, 4x2, $59
		endsprite
		
frame_bblock_topleft:
		spritemap
		piece	-8, -8, 2x2, $51
		endsprite
		
frame_bblock_topright:
		spritemap
		piece	-8, -8, 2x2, $55
		endsprite
		
frame_bblock_bottomleft:
		spritemap
		piece	-8, -8, 2x2, $59
		endsprite
		
frame_bblock_bottomright:
		spritemap
		piece	-8, -8, 2x2, $5D
		endsprite
