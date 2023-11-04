; ---------------------------------------------------------------------------
; Sprite mappings - floating blocks (SYZ/SLZ/LZ)
; ---------------------------------------------------------------------------
Map_FBlock:	index *
		ptr frame_fblock_syz1x1
		ptr frame_fblock_syz2x2
		ptr frame_fblock_syz1x2
		ptr frame_fblock_syzrect2x2
		ptr frame_fblock_syzrect1x3
		
frame_fblock_syz1x1:
		spritemap					; SYZ - 1x1 square block
		piece	-$10, -$10, 4x4, $61
		endsprite
		
frame_fblock_syz2x2:
		spritemap					; SYZ - 2x2 square blocks
		piece	-$20, -$20, 4x4, $61
		piece	0, -$20, 4x4, $61
		piece	-$20, 0, 4x4, $61
		piece	0, 0, 4x4, $61
		endsprite
		
frame_fblock_syz1x2:
		spritemap					; SYZ - 1x2 square blocks
		piece	-$10, -$20, 4x4, $61
		piece	-$10, 0, 4x4, $61
		endsprite
		
frame_fblock_syzrect2x2:
		spritemap					; SYZ - 2x2 rectangular blocks
		piece	-$20, -$1A, 4x4, $81
		piece	0, -$1A, 4x4, $81
		piece	-$20, 0, 4x4, $81
		piece	0, 0, 4x4, $81
		endsprite
		
frame_fblock_syzrect1x3:
		spritemap					; SYZ - 1x3 rectangular blocks (unused)
		piece	-$10, -$27, 4x4, $81
		piece	-$10, -$D, 4x4, $81
		piece	-$10, $D, 4x4, $81
		endsprite
