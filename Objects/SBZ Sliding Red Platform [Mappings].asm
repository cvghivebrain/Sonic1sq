; ---------------------------------------------------------------------------
; Sprite mappings - moving platform blocks (MZ, LZ, SBZ)
; ---------------------------------------------------------------------------

Map_Slide:	index *
		ptr frame_slide_0
		
frame_slide_0:
		spritemap
		piece	-$40, -8, 4x3, 0
		piece	-$20, -8, 4x3, 3
		piece	0, -8, 4x3, 3
		piece	$20, -8, 4x3, 0, xflip
		endsprite
