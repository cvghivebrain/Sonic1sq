; ---------------------------------------------------------------------------
; Sprite mappings - monitors
; ---------------------------------------------------------------------------
Map_Monitor:	index *
		ptr frame_monitor_0
		ptr frame_monitor_1
		ptr frame_monitor_2
		ptr frame_monitor_3
		ptr frame_monitor_4
		ptr frame_monitor_5
		ptr frame_monitor_6
		ptr frame_monitor_7
		ptr frame_monitor_static0
		ptr frame_monitor_static1
		ptr frame_monitor_static2
		ptr frame_monitor_sonic
		ptr frame_monitor_broken
		
frame_monitor_static0:
		spritemap					; static monitor
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_static1:
		spritemap					; static monitor
		piece	-8, -$B, 2x2, $10
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_static2:
		spritemap					; static monitor
		piece	-8, -$B, 2x2, $14
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_sonic:
		spritemap					; Sonic	monitor
		piece	-8, -$B, 2x2, (vram_lifeicon-vram_monitors)/sizeof_cell
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_0:
		spritemap
		piece	-8, -$B, 2x2, $20
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_1:
		spritemap
		piece	-8, -$B, 2x2, $24
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_2:
		spritemap
		piece	-8, -$B, 2x2, $28
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_3:
		spritemap
		piece	-8, -$B, 2x2, $2C
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_4:
		spritemap
		piece	-8, -$B, 2x2, $30
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_5:
		spritemap
		piece	-8, -$B, 2x2, $34
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_6:
		spritemap
		piece	-8, -$B, 2x2, $38
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_7:
		spritemap
		piece	-8, -$B, 2x2, $3C
		piece	-$10, -$11, 4x4, 0
		endsprite
		
frame_monitor_broken:
		spritemap					; broken monitor
		piece	-$10, -1, 4x2, $18
		endsprite
