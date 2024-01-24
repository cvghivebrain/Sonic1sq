; ---------------------------------------------------------------------------
; Sprite mappings - platforms (GHZ, SYZ, SLZ)
; ---------------------------------------------------------------------------

Map_Platform:	index *
		ptr frame_plat_small
		ptr frame_plat_large
		ptr frame_plat_syz
		ptr frame_plat_slz
		
frame_plat_small:
		spritemap					; small platform
		piece	-$20, -$C, 3x4, $3B
		piece	-8, -$C, 2x4, $3F
		piece	8, -$C, 2x4, $3F
		piece	$18, -$C, 1x4, $47
		endsprite
		
frame_plat_large:
		spritemap					; large column platform
		piece	-$20, -$C, 4x4, $C5
		piece	-$20, 4, 4x4, $D5
		piece	-$20, $24, 4x4, $D5
		piece	-$20, $44, 4x4, $D5
		piece	-$20, $64, 4x4, $D5
		piece	0, -$C, 4x4, $C5, xflip
		piece	0, 4, 4x4, $D5, xflip
		piece	0, $24, 4x4, $D5, xflip
		piece	0, $44, 4x4, $D5, xflip
		piece	0, $64, 4x4, $D5, xflip
		endsprite

frame_plat_syz:	spritemap
		piece	-$20, -$A, 3x4, $29
		piece	-8, -$A, 2x4, $31
		piece	8, -$A, 3x4, $35
		endsprite

frame_plat_slz:	spritemap
		piece	-$20, -8, 4x4, $21
		piece	0, -8, 4x4, $21
		endsprite
