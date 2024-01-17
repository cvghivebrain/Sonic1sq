; ---------------------------------------------------------------------------
; Sprite mappings - horizontal door (LZ)
; ---------------------------------------------------------------------------
Map_DoorH:	index *
		ptr frame_doorh_0
		
frame_doorh_0:
		spritemap					; LZ - large horizontal door
		piece	-$40, -$10, 4x4, 0
		piece	-$20, -$10, 4x4, 0
		piece	0, -$10, 4x4, 0
		piece	$20, -$10, 4x4, 0
		endsprite
