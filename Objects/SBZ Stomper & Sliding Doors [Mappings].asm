; ---------------------------------------------------------------------------
; Sprite mappings - stomper and	sliding doors (SBZ)
; ---------------------------------------------------------------------------
Map_Stomp:	index *
		ptr frame_stomp_door
		ptr frame_stomp_stomper
		ptr frame_stomp_stomper
		ptr frame_stomp_stomper
		
frame_stomp_door:
		spritemap					; horizontal sliding door
		piece	-$40, -$C, 4x3, 0, pal2
		piece	-$20, -$C, 4x3, 3, pal2
		piece	0, -$C, 4x3, 3, pal2
		piece	$20, -$C, 4x3, 0, pal2, xflip
		endsprite
		
frame_stomp_stomper:
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
