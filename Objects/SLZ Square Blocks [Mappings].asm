; ---------------------------------------------------------------------------
; Sprite mappings - square floating blocks (SLZ)
; ---------------------------------------------------------------------------
Map_SBlock:	index *
		ptr frame_sblock_slz
		
frame_sblock_slz:
		spritemap					; SLZ - 1x1 square block
		piece	-$10, -$10, 4x4, $21
		endsprite
