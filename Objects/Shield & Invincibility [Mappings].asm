; ---------------------------------------------------------------------------
; Sprite mappings - shield and invincibility stars
; ---------------------------------------------------------------------------
Map_Shield:	index *
		ptr frame_shield_blank
		ptr frame_shield_1
		ptr frame_shield_2
		ptr frame_shield_3
		ptr frame_stars1
		ptr frame_stars2
		ptr frame_stars3
		ptr frame_stars4
		
frame_shield_blank:
		spritemap
		endsprite
frame_shield_1:	spritemap
		piece	-$18, -$18, 3x3, 0
		piece	0, -$18, 3x3, 9
		piece	-$18, 0, 3x3, 0, yflip
		piece	0, 0, 3x3, 9, yflip
		endsprite
		
		dplcinit Art_Shield				; address of ball gfx
		dplc 0,18					; offset, size (in tiles)
		
frame_shield_2:	spritemap
		piece	-$17, -$18, 3x3, 0, xflip
		piece	0, -$18, 3x3, 0
		piece	-$17, 0, 3x3, 0, xflip, yflip
		piece	0, 0, 3x3, 0, yflip
		endsprite
		
		dplc 18,9
		
frame_shield_3:	spritemap
		piece	-$18, -$18, 3x3, 9, xflip
		piece	0, -$18, 3x3, 0, xflip
		piece	-$18, 0, 3x3, 9, xflip, yflip
		piece	0, 0, 3x3, 0, xflip, yflip
		endsprite
		
		dplc 0,18

frame_stars1:	spritemap
		piece	-$18, -$18, 3x3, 0
		piece	0, -$18, 3x3, 9
		piece	-$18, 0, 3x3, 9, xflip, yflip
		piece	0, 0, 3x3, 0, xflip, yflip
		endsprite
		
frame_stars2:	spritemap
		piece	-$18, -$18, 3x3, 9, xflip
		piece	0, -$18, 3x3, 0, xflip
		piece	-$18, 0, 3x3, 0, yflip
		piece	0, 0, 3x3, 9, yflip
		endsprite
		
frame_stars3:	spritemap
		piece	-$18, -$18, 3x3, $12
		piece	0, -$18, 3x3, $1B
		piece	-$18, 0, 3x3, $1B, xflip, yflip
		piece	0, 0, 3x3, $12, xflip, yflip
		endsprite
		
frame_stars4:	spritemap
		piece	-$18, -$18, 3x3, $1B, xflip
		piece	0, -$18, 3x3, $12, xflip
		piece	-$18, 0, 3x3, $12, yflip
		piece	0, 0, 3x3, $1B, yflip
		endsprite
		even
