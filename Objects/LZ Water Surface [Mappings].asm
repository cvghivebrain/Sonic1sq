; ---------------------------------------------------------------------------
; Sprite mappings - water surface (LZ)
; ---------------------------------------------------------------------------
Map_Surf:	index *
		ptr frame_surf_normal1
		ptr frame_surf_normal2
		ptr frame_surf_normal3
		ptr frame_surf_paused1
		
frame_surf_normal1:
		spritemap
		piece	0, -3, 4x2, 0
		piece	$40, -3, 4x2, 0
		piece	$80, -3, 4x2, 0
		piece	$C0, -3, 4x2, 0
		piece	$100, -3, 4x2, 0
		piece	$140, -3, 4x2, 0
		endsprite
		
frame_surf_normal2:
		spritemap
		piece	0, -3, 4x2, 8
		piece	$40, -3, 4x2, 8
		piece	$80, -3, 4x2, 8
		piece	$C0, -3, 4x2, 8
		piece	$100, -3, 4x2, 8
		piece	$140, -3, 4x2, 8
		endsprite
		
frame_surf_normal3:
		spritemap
		piece	0, -3, 4x2, 0, xflip
		piece	$40, -3, 4x2, 0, xflip
		piece	$80, -3, 4x2, 0, xflip
		piece	$C0, -3, 4x2, 0, xflip
		piece	$100, -3, 4x2, 0, xflip
		piece	$140, -3, 4x2, 0, xflip
		endsprite
		
frame_surf_paused1:
		spritemap
		piece	0, -3, 4x2, 0
		piece	$20, -3, 4x2, 0
		piece	$40, -3, 4x2, 0
		piece	$60, -3, 4x2, 0
		piece	$80, -3, 4x2, 0
		piece	$A0, -3, 4x2, 0
		piece	$C0, -3, 4x2, 0
		piece	$E0, -3, 4x2, 0
		piece	$100, -3, 4x2, 0
		piece	$120, -3, 4x2, 0
		endsprite
