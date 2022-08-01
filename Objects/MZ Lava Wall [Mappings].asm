; ---------------------------------------------------------------------------
; Sprite mappings - advancing wall of lava (MZ)
; ---------------------------------------------------------------------------
Map_LWall:	index *
		ptr frame_lavawall_0
		ptr frame_lavawall_1
		ptr frame_lavawall_2
		ptr frame_lavawall_3
		ptr frame_lavawall_back

tile_magma_diff:	equ ($53A0/sizeof_cell)-tile_Kos_Lava	; location of animated magma relative to object lava gfx

frame_lavawall_0:
		spritemap
		piece	$20, -$20, 4x4, $60
		piece	$3C, 0, 4x4, $70
		piece	$20, 0, 4x4, tile_magma_diff
		piece	0, -$20, 4x4, tile_magma_diff
		piece	0, 0, 4x4, tile_magma_diff
		piece	-$20, -$20, 4x4, tile_magma_diff
		piece	-$20, 0, 4x4, tile_magma_diff
		piece	-$40, -$20, 4x4, tile_magma_diff
		piece	-$40, 0, 4x4, tile_magma_diff
		endsprite
		
frame_lavawall_1:
		spritemap
		piece	$20, -$20, 4x4, $70
		piece	$3C, 0, 4x4, $80
		piece	$20, 0, 4x4, tile_magma_diff
		piece	0, -$20, 4x4, tile_magma_diff
		piece	0, 0, 4x4, tile_magma_diff
		piece	-$20, -$20, 4x4, tile_magma_diff
		piece	-$20, 0, 4x4, tile_magma_diff
		piece	-$40, -$20, 4x4, tile_magma_diff
		piece	-$40, 0, 4x4, tile_magma_diff
		endsprite
		
frame_lavawall_2:
		spritemap
		piece	$20, -$20, 4x4, $80
		piece	$3C, 0, 4x4, $70
		piece	$20, 0, 4x4, tile_magma_diff
		piece	0, -$20, 4x4, tile_magma_diff
		piece	0, 0, 4x4, tile_magma_diff
		piece	-$20, -$20, 4x4, tile_magma_diff
		piece	-$20, 0, 4x4, tile_magma_diff
		piece	-$40, -$20, 4x4, tile_magma_diff
		piece	-$40, 0, 4x4, tile_magma_diff
		endsprite
		
frame_lavawall_3:
		spritemap
		piece	$20, -$20, 4x4, $70
		piece	$3C, 0, 4x4, $60
		piece	$20, 0, 4x4, tile_magma_diff
		piece	0, -$20, 4x4, tile_magma_diff
		piece	0, 0, 4x4, tile_magma_diff
		piece	-$20, -$20, 4x4, tile_magma_diff
		piece	-$20, 0, 4x4, tile_magma_diff
		piece	-$40, -$20, 4x4, tile_magma_diff
		piece	-$40, 0, 4x4, tile_magma_diff
		endsprite
		
frame_lavawall_back:
		spritemap
		piece	$20, -$20, 4x4, tile_magma_diff
		piece	$20, 0, 4x4, tile_magma_diff
		piece	0, -$20, 4x4, tile_magma_diff
		piece	0, 0, 4x4, tile_magma_diff
		piece	-$20, -$20, 4x4, tile_magma_diff
		piece	-$20, 0, 4x4, tile_magma_diff
		piece	-$40, -$20, 4x4, tile_magma_diff
		piece	-$40, 0, 4x4, tile_magma_diff
		endsprite
		even
