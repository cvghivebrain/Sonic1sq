; ---------------------------------------------------------------------------
; Sprite mappings - vertical door (LZ)
; ---------------------------------------------------------------------------
Map_DoorV:	index *
		ptr frame_doorv_0
		
frame_doorv_0:
		spritemap					; LZ - small vertical door
		piece	-8, -$20, 2x4, 0
		piece	-8, 0, 2x4, 0, yflip
		endsprite
