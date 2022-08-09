; ---------------------------------------------------------------------------
; Sprite mappings - swinging ball on a chain from GHZ boss
; ---------------------------------------------------------------------------
Map_GBall:	index *
		ptr frame_ball_shiny
		ptr frame_ball_check1
		ptr frame_ball_check2
		ptr frame_ball_check3
		
frame_ball_shiny:
		spritemap
		piece	-$10, -$10, 2x1, 0
		piece	-$10, -8, 2x1, 0, yflip
		piece	-$18, -$18, 3x3, 2
		piece	0, -$18, 3x3, 2, xflip
		piece	-$18, 0, 3x3, 2, yflip
		piece	0, 0, 3x3, 2, xflip, yflip
		endsprite
		
		dplcinit Art_Ball				; address of ball gfx
		dplc 0,11					; offset, size (in tiles)
		
frame_ball_check1:
		spritemap
		piece	-$18, -$18, 3x3, 0
		piece	0, -$18, 3x3, 0, xflip
		piece	-$18, 0, 3x3, 0, yflip
		piece	0, 0, 3x3, 0, xflip, yflip
		endsprite
		
		dplc 11,9
		
frame_ball_check2:
		spritemap
		piece	-$18, -$18, 3x3, 0
		piece	0, -$18, 3x3, 9
		piece	-$18, 0, 3x3, 9, xflip, yflip
		piece	0, 0, 3x3, 0, xflip, yflip
		endsprite
		
		dplc 20,18
		
frame_ball_check3:
		spritemap
		piece	-$18, -$18, 3x3, 9, xflip
		piece	0, -$18, 3x3, 0, xflip
		piece	-$18, 0, 3x3, 0, yflip
		piece	0, 0, 3x3, 9, yflip
		endsprite
		
		dplc 20,18
