; ---------------------------------------------------------------------------
; Sprite mappings - giant ring
; ---------------------------------------------------------------------------
Map_GRing:	index *
		ptr frame_bigring_front
		ptr frame_bigring_45_1
		ptr frame_bigring_side
		ptr frame_bigring_45_2
		
frame_bigring_front:
		spritemap					; ring front
		piece	-$18, -$20, 3x1, 0
		piece	0, -$20, 3x1, 3
		piece	-$20, -$18, 4x1, 6
		piece	0, -$18, 4x1, $A
		piece	-$20, -$10, 2x4, $E
		piece	$10, -$10, 2x4, $16
		piece	-$20, $10, 4x1, $1E
		piece	0, $10, 4x1, $22
		piece	-$18, $18, 3x1, $26
		piece	0, $18, 3x1, $29
		endsprite
		
		dplcinit Art_BigRing				; address of giant ring gfx
		dplc 0,$2C					; offset, size (in tiles)
		
frame_bigring_45_1:
		spritemap					; ring angle
		piece	-$10, -$20, 4x1, 0
		piece	-$18, -$18, 3x1, 4
		piece	0, -$18, 3x2, 7
		piece	-$18, -$10, 2x4, $D
		piece	8, -8, 2x2, $15
		piece	0, 8, 3x2, $19
		piece	-$18, $10, 3x1, $1F
		piece	-$10, $18, 4x1, $22
		endsprite
		
		dplc $2C,$26
		
frame_bigring_side:
		spritemap					; ring perpendicular
		piece	-$C, -$20, 2x4, 0
		piece	4, -$20, 1x4, 0, xflip
		piece	-$C, 0, 2x4, 8
		piece	4, 0, 1x4, 8, xflip
		endsprite
		
		dplc $52,$10
		
frame_bigring_45_2:
		spritemap					; ring angle
		piece	-$10, -$20, 4x1, 0, xflip
		piece	0, -$18, 3x1, 4, xflip
		piece	-$18, -$18, 3x2, 7, xflip
		piece	8, -$10, 2x4, $D, xflip
		piece	-$18, -8, 2x2, $15, xflip
		piece	-$18, 8, 3x2, $19, xflip
		piece	0, $10, 3x1, $1F, xflip
		piece	-$10, $18, 4x1, $22, xflip
		endsprite
		
		dplc $2C,$26
