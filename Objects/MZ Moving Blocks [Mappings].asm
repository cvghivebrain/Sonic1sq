; ---------------------------------------------------------------------------
; Sprite mappings - moving platform blocks (MZ, LZ, SBZ)
; ---------------------------------------------------------------------------

Map_MBlock:	index *
		ptr frame_mblock_mz1
		ptr frame_mblock_mz2
		ptr frame_mblock_mz3
		
frame_mblock_mz1:
		spritemap
		piece	-$10, -8, 4x4, 8
		endsprite
		
frame_mblock_mz2:
		spritemap
		piece	-$20, -8, 4x4, 8
		piece	0, -8, 4x4, 8
		endsprite
		
frame_mblock_mz3:
		spritemap
		piece	-$30, -8, 4x4, 8
		piece	-$10, -8, 4x4, 8
		piece	$10, -8, 4x4, 8
		endsprite
