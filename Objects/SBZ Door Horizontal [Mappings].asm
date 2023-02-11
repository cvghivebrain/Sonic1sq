; ---------------------------------------------------------------------------
; Sprite mappings - horizontal sliding door (SBZ)
; ---------------------------------------------------------------------------
Map_SDoorH:	index *
		ptr frame_sdoorh_0
		
frame_sdoorh_0:
		spritemap					; horizontal sliding door
		piece	-$40, -$C, 4x3, 0
		piece	-$20, -$C, 4x3, 3
		piece	0, -$C, 4x3, 3
		piece	$20, -$C, 4x3, 0, xflip
		endsprite
