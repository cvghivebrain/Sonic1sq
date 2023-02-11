; ---------------------------------------------------------------------------
; Sprite mappings - stomper (SBZ)
; ---------------------------------------------------------------------------
Map_Stomp:	index *
		ptr frame_stomp_0
		
frame_stomp_0:
		spritemap					; stomper block with yellow/black stripes
		piece	-$1C, -$20, 4x1, $C
		piece	4, -$20, 3x1, $10
		piece	-$1C, -$18, 4x3, $13, pal2
		piece	4, -$18, 3x3, $1F, pal2
		piece	-$1C, 0, 4x3, $13, pal2
		piece	4, 0, 3x3, $1F, pal2
		piece	-$1C, $18, 4x1, $C
		piece	4, $18, 3x1, $10
		endsprite
