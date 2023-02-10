; ---------------------------------------------------------------------------
; Sprite mappings - big pillar sliding door (SBZ)
; ---------------------------------------------------------------------------
Map_Pillar:	index *
		ptr frame_pillar_0
		
frame_pillar_0:
		spritemap					; huge diagonal sliding door from SBZ3
		piece	-$80, -$40, 4x4, 0
		piece	-$60, -$40, 4x4, $10
		piece	-$40, -$40, 4x4, $20
		piece	-$20, -$40, 4x4, $10
		piece	0, -$40, 4x4, $20
		piece	$20, -$40, 4x4, $10
		piece	$40, -$40, 4x4, $30
		piece	$60, -$40, 4x2, $40
		piece	-$80, -$20, 4x4, $48
		piece	-$40, -$20, 4x4, $48
		piece	0, -$20, 4x4, $58
		piece	-$80, 0, 4x4, $48
		piece	-$40, 0, 4x4, $58
		piece	-$80, $20, 4x4, $58
		endsprite
