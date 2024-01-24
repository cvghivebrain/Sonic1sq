; ---------------------------------------------------------------------------
; Sprite mappings - lamp (SYZ)
; ---------------------------------------------------------------------------
Map_Light:	index *
		ptr frame_light_0
		ptr frame_light_1
		ptr frame_light_2
		ptr frame_light_3
		ptr frame_light_4
		ptr frame_light_5
		
frame_light_0:
		spritemap
		piece	-$10, -8, 4x1, $11
		piece	-$10, 0, 4x1, $11, yflip
		endsprite
		
frame_light_1:
		spritemap
		piece	-$10, -8, 4x1, $15
		piece	-$10, 0, 4x1, $15, yflip
		endsprite
		
frame_light_2:
		spritemap
		piece	-$10, -8, 4x1, $19
		piece	-$10, 0, 4x1, $19, yflip
		endsprite
		
frame_light_3:
		spritemap
		piece	-$10, -8, 4x1, $1D
		piece	-$10, 0, 4x1, $1D, yflip
		endsprite
		
frame_light_4:
		spritemap
		piece	-$10, -8, 4x1, $21
		piece	-$10, 0, 4x1, $21, yflip
		endsprite
		
frame_light_5:
		spritemap
		piece	-$10, -8, 4x1, $25
		piece	-$10, 0, 4x1, $25, yflip
		endsprite
