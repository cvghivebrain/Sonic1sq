; ---------------------------------------------------------------------------
; Sprite mappings - prison capsule
; ---------------------------------------------------------------------------
Map_Pri:	index *
		ptr frame_prison_capsule
		ptr frame_prison_switch1
		ptr frame_prison_broken
		ptr frame_prison_switch2
		
frame_prison_capsule:
		spritemap
		piece	-$10, -$20, 4x1, 0, pal2
		piece	-$20, -$18, 4x2, 4, pal2
		piece	0, -$18, 4x2, $C, pal2
		piece	-$20, -8, 4x3, $14, pal2
		piece	0, -8, 4x3, $20, pal2
		piece	-$20, $10, 4x2, $2C, pal2
		piece	0, $10, 4x2, $34, pal2
		endsprite
		
frame_prison_switch1:
		spritemap
		piece	-$C, -8, 3x2, $3C
		endsprite
		
frame_prison_broken:
		spritemap
		piece	-$20, 0, 3x1, 0, pal2
		piece	-$20, 8, 4x1, 3, pal2
		piece	$10, 0, 2x1, 7, pal2
		piece	0, 8, 4x1, 9, pal2
		piece	-$20, $10, 4x2, $2C, pal2
		piece	0, $10, 4x2, $34, pal2
		endsprite
		
frame_prison_switch2:
		spritemap
		piece	-$C, -8, 3x2, $42
		endsprite
