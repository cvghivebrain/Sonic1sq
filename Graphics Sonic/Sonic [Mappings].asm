; Sprite mappings - Sonic
Map_Sonic:	index *,,
		ptr frame_Blank
		ptr frame_Stand
		ptr frame_Wait1
		ptr frame_Wait2
		ptr frame_Wait3
		ptr frame_LookUp
		ptr frame_Walk11
		ptr frame_Walk12
		ptr frame_Walk13
		ptr frame_Walk14
		ptr frame_Walk15
		ptr frame_Walk16
		ptr frame_Walk21
		ptr frame_Walk22
		ptr frame_Walk23
		ptr frame_Walk24
		ptr frame_Walk25
		ptr frame_Walk26
		ptr frame_Walk31
		ptr frame_Walk32
		ptr frame_Walk33
		ptr frame_Walk34
		ptr frame_Walk35
		ptr frame_Walk36
		ptr frame_Walk41
		ptr frame_Walk42
		ptr frame_Walk43
		ptr frame_Walk44
		ptr frame_Walk45
		ptr frame_Walk46
		ptr frame_Run11
		ptr frame_Run12
		ptr frame_Run13
		ptr frame_Run14
		ptr frame_Run21
		ptr frame_Run22
		ptr frame_Run23
		ptr frame_Run24
		ptr frame_Run31
		ptr frame_Run32
		ptr frame_Run33
		ptr frame_Run34
		ptr frame_Run41
		ptr frame_Run42
		ptr frame_Run43
		ptr frame_Run44
		ptr frame_Roll1
		ptr frame_Roll2
		ptr frame_Roll3
		ptr frame_Roll4
		ptr frame_Roll5
		ptr frame_Warp1
		ptr frame_Warp2
		ptr frame_Warp3
		ptr frame_Warp4
		ptr frame_Stop1
		ptr frame_Stop2
		ptr frame_Duck
		ptr frame_Balance1
		ptr frame_Balance2
		ptr frame_Float1
		ptr frame_Float2
		ptr frame_Float3
		ptr frame_Float4
		ptr frame_Spring
		ptr frame_Hang1
		ptr frame_Hang2
		ptr frame_Leap1
		ptr frame_Leap2
		ptr frame_Push1
		ptr frame_Push2
		ptr frame_Push3
		ptr frame_Push4
		ptr frame_Surf
		ptr frame_BubStand
		ptr frame_Burnt
		ptr frame_Drown
		ptr frame_Death
		ptr frame_Shrink1
		ptr frame_Shrink2
		ptr frame_Shrink3
		ptr frame_Shrink4
		ptr frame_Shrink5
		ptr frame_Float5
		ptr frame_Float6
		ptr frame_Injury
		ptr frame_GetAir
		ptr frame_WaterSlide

frame_Blank:
		spritemap
		endsprite

		dplcinit Art_Sonic_Blank
		dplc 0,0

frame_Stand:
		spritemap
		piece -16, -19, 3x4, 0&$FF
		piece 8, -7, 1x1, 12&$FF
		piece -9, 13, 3x1, 13&$FF
		endsprite

		dplcinit Art_Sonic_Stand
		dplc 0,16




frame_Wait1:
		spritemap
		piece -15, -18, 3x4, 0&$FF
		piece -8, 14, 3x1, 12&$FF
		endsprite

		dplcinit Art_Sonic_Wait1
		dplc 0,15



frame_Wait2:
		spritemap
		piece -15, -18, 3x4, 0&$FF
		piece -8, 14, 3x1, 12&$FF
		endsprite

		dplcinit Art_Sonic_Wait2
		dplc 0,15



frame_Wait3:
		spritemap
		piece -15, -18, 3x4, 0&$FF
		piece -8, 14, 3x1, 12&$FF
		endsprite

		dplcinit Art_Sonic_Wait3
		dplc 0,15



frame_LookUp:
		spritemap
		piece -16, -18, 3x4, 0&$FF
		piece -8, 14, 3x1, 12&$FF
		endsprite

		dplcinit Art_Sonic_LookUp
		dplc 0,15



frame_Walk11:
		spritemap
		piece -17, -19, 4x4, 0&$FF
		piece -17, 13, 1x1, 16&$FF
		piece 10, 2, 2x2, 17&$FF
		endsprite

		dplcinit Art_Sonic_Walk11
		dplc 0,21




frame_Walk12:
		spritemap
		piece -12, -18, 4x2, 0&$FF
		piece -12, -2, 3x3, 8&$FF
		piece 12, 11, 1x1, 17&$FF
		endsprite

		dplcinit Art_Sonic_Walk12
		dplc 0,18




frame_Walk13:
		spritemap
		piece -13, -17, 3x4, 0&$FF
		piece -10, 15, 2x1, 12&$FF
		endsprite

		dplcinit Art_Sonic_Walk13
		dplc 0,14



frame_Walk14:
		spritemap
		piece -12, -19, 3x1, 0&$FF
		piece -12, -11, 4x4, 3&$FF
		piece -20, 0, 1x3, 19&$FF
		endsprite

		dplcinit Art_Sonic_Walk14
		dplc 0,22




frame_Walk15:
		spritemap
		piece -13, -18, 3x4, 0&$FF
		piece -21, 0, 1x2, 12&$FF
		piece -3, 14, 2x1, 14&$FF
		endsprite

		dplcinit Art_Sonic_Walk15
		dplc 0,16




frame_Walk16:
		spritemap
		piece -13, -17, 4x2, 0&$FF
		piece -12, -1, 3x3, 8&$FF
		endsprite

		dplcinit Art_Sonic_Walk16
		dplc 0,17



frame_Walk21:
		spritemap
		piece -19, -19, 4x3, 0&$FF
		piece -9, 5, 2x3, 12&$FF
		piece 13, -13, 1x2, 18&$FF
		endsprite

		dplcinit Art_Sonic_Walk21
		dplc 0,20




frame_Walk22:
		spritemap
		piece -18, -18, 4x3, 0&$FF
		piece 13, -5, 2x2, 12&$FF
		piece -7, 6, 2x1, 16&$FF
		piece -1, 14, 2x1, 18&$FF
		endsprite

		dplcinit Art_Sonic_Walk22
		dplc 0,20





frame_Walk23:
		spritemap
		piece -15, -19, 3x2, 0&$FF
		piece -11, -3, 4x2, 6&$FF
		piece 1, 13, 2x1, 14&$FF
		endsprite

		dplcinit Art_Sonic_Walk23
		dplc 0,16




frame_Walk24:
		spritemap
		piece -17, -21, 3x1, 0&$FF
		piece -17, -13, 4x3, 3&$FF
		piece -11, 11, 2x2, 15&$FF
		piece 15, -11, 1x2, 19&$FF
		endsprite

		dplcinit Art_Sonic_Walk24
		dplc 0,21





frame_Walk25:
		spritemap
		piece -16, -20, 3x2, 0&$FF
		piece -12, -4, 4x2, 6&$FF
		piece -3, 12, 1x1, 14&$FF
		piece 12, 12, 1x1, 15&$FF
		endsprite

		dplcinit Art_Sonic_Walk25
		dplc 0,16





frame_Walk26:
		spritemap
		piece -17, -17, 4x3, 0&$FF
		piece -6, 7, 3x2, 12&$FF
		piece 15, -1, 1x1, 18&$FF
		endsprite

		dplcinit Art_Sonic_Walk26
		dplc 0,19




frame_Walk31:
		spritemap
		piece -19, -14, 4x4, 0&$FF
		piece 2, -20, 2x2, 16&$FF
		piece 13, 9, 1x1, 20&$FF
		endsprite

		dplcinit Art_Sonic_Walk31
		dplc 0,21




frame_Walk32:
		spritemap
		piece -18, -14, 4x4, 0&$FF
		piece 11, -19, 2x2, 16&$FF
		piece 14, 2, 1x1, 20&$FF
		endsprite

		dplcinit Art_Sonic_Walk32
		dplc 0,21




frame_Walk33:
		spritemap
		piece -17, -12, 4x3, 0&$FF
		piece 15, -3, 1x2, 12&$FF
		endsprite

		dplcinit Art_Sonic_Walk33
		dplc 0,14



frame_Walk34:
		spritemap
		piece -19, -13, 1x3, 0&$FF
		piece -11, -13, 4x4, 3&$FF
		piece 2, -20, 2x1, 19&$FF
		endsprite

		dplcinit Art_Sonic_Walk34
		dplc 0,21




frame_Walk35:
		spritemap
		piece -18, -12, 2x3, 0&$FF
		piece -2, -11, 2x3, 6&$FF
		piece 8, 13, 1x1, 12&$FF
		piece 14, -10, 1x2, 13&$FF
		endsprite

		dplcinit Art_Sonic_Walk35
		dplc 0,15





frame_Walk36:
		spritemap
		piece -17, -12, 1x3, 0&$FF
		piece -9, -14, 4x4, 3&$FF
		endsprite

		dplcinit Art_Sonic_Walk36
		dplc 0,19



frame_Walk41:
		spritemap
		piece -19, -11, 3x4, 0&$FF
		piece 5, -5, 2x2, 12&$FF
		piece 21, -5, 1x1, 16&$FF
		piece -13, -19, 2x1, 17&$FF
		endsprite

		dplcinit Art_Sonic_Walk41
		dplc 0,19





frame_Walk42:
		spritemap
		piece -18, -8, 3x3, 0&$FF
		piece 6, -10, 2x3, 9&$FF
		piece -5, -23, 2x2, 15&$FF
		piece -8, 16, 1x1, 19&$FF
		endsprite

		dplcinit Art_Sonic_Walk42
		dplc 0,20





frame_Walk43:
		spritemap
		piece -19, -9, 3x3, 0&$FF
		piece 2, -19, 2x3, 9&$FF
		piece 5, 5, 1x1, 15&$FF
		endsprite

		dplcinit Art_Sonic_Walk43
		dplc 0,16




frame_Walk44:
		spritemap
		piece -21, -11, 2x4, 0&$FF
		piece -5, -11, 3x3, 8&$FF
		piece 19, -6, 1x1, 17&$FF
		piece -10, -19, 2x1, 18&$FF
		endsprite

		dplcinit Art_Sonic_Walk44
		dplc 0,20





frame_Walk45:
		spritemap
		piece -20, -8, 2x3, 0&$FF
		piece -4, -12, 2x3, 6&$FF
		piece 12, -5, 1x1, 12&$FF
		piece -2, -19, 2x1, 13&$FF
		endsprite

		dplcinit Art_Sonic_Walk45
		dplc 0,15





frame_Walk46:
		spritemap
		piece -17, -10, 2x4, 0&$FF
		piece -2, -21, 3x3, 8&$FF
		piece -1, 3, 2x2, 17&$FF
		endsprite

		dplcinit Art_Sonic_Walk46
		dplc 0,21




frame_Run11:
		spritemap
		piece -12, -15, 3x2, 0&$FF
		piece -19, 0, 4x3, 6&$FF
		endsprite

		dplcinit Art_Sonic_Run11
		dplc 0,18



frame_Run12:
		spritemap
		piece -12, -16, 3x2, 0&$FF
		piece -19, 0, 4x3, 6&$FF
		endsprite

		dplcinit Art_Sonic_Run12
		dplc 0,18



frame_Run13:
		spritemap
		piece -12, -15, 3x2, 0&$FF
		piece -18, 0, 4x3, 6&$FF
		endsprite

		dplcinit Art_Sonic_Run13
		dplc 0,18



frame_Run14:
		spritemap
		piece -12, -16, 3x2, 0&$FF
		piece -19, 0, 4x3, 6&$FF
		endsprite

		dplcinit Art_Sonic_Run14
		dplc 0,18



frame_Run21:
		spritemap
		piece -16, -17, 4x3, 0&$FF
		piece -5, 7, 3x2, 12&$FF
		piece 16, -2, 1x2, 18&$FF
		endsprite

		dplcinit Art_Sonic_Run21
		dplc 0,20




frame_Run22:
		spritemap
		piece -15, -18, 4x3, 0&$FF
		piece -5, 6, 3x2, 12&$FF
		piece 17, -1, 1x2, 18&$FF
		endsprite

		dplcinit Art_Sonic_Run22
		dplc 0,20




frame_Run23:
		spritemap
		piece -16, -17, 4x3, 0&$FF
		piece -5, 7, 3x2, 12&$FF
		piece 16, -2, 1x2, 18&$FF
		endsprite

		dplcinit Art_Sonic_Run23
		dplc 0,20




frame_Run24:
		spritemap
		piece -15, -18, 4x3, 0&$FF
		piece -5, 6, 3x2, 12&$FF
		piece 17, -1, 1x2, 18&$FF
		endsprite

		dplcinit Art_Sonic_Run24
		dplc 0,20




frame_Run31:
		spritemap
		piece -15, -12, 2x3, 0&$FF
		piece 0, -11, 3x4, 6&$FF
		endsprite

		dplcinit Art_Sonic_Run31
		dplc 0,18



frame_Run32:
		spritemap
		piece -16, -12, 2x3, 0&$FF
		piece 0, -10, 3x4, 6&$FF
		endsprite

		dplcinit Art_Sonic_Run32
		dplc 0,18



frame_Run33:
		spritemap
		piece -15, -12, 2x3, 0&$FF
		piece 0, -10, 3x4, 6&$FF
		endsprite

		dplcinit Art_Sonic_Run33
		dplc 0,18



frame_Run34:
		spritemap
		piece -16, -12, 2x3, 0&$FF
		piece 0, -10, 3x4, 6&$FF
		endsprite

		dplcinit Art_Sonic_Run34
		dplc 0,18



frame_Run41:
		spritemap
		piece -17, -14, 3x4, 0&$FF
		piece -2, -21, 2x1, 12&$FF
		piece 7, -17, 2x3, 14&$FF
		endsprite

		dplcinit Art_Sonic_Run41
		dplc 0,20




frame_Run42:
		spritemap
		piece -18, -12, 3x4, 0&$FF
		piece -2, -21, 3x1, 12&$FF
		piece 6, -13, 2x3, 15&$FF
		endsprite

		dplcinit Art_Sonic_Run42
		dplc 0,21




frame_Run43:
		spritemap
		piece -17, -10, 2x4, 0&$FF
		piece -3, -20, 2x4, 8&$FF
		piece 13, -18, 2x3, 16&$FF
		endsprite

		dplcinit Art_Sonic_Run43
		dplc 0,22




frame_Run44:
		spritemap
		piece -18, -12, 2x4, 0&$FF
		piece -2, -21, 3x4, 8&$FF
		endsprite

		dplcinit Art_Sonic_Run44
		dplc 0,20



frame_Roll1:
		spritemap
		piece -16, -16, 4x4, 0&$FF
		endsprite

		dplcinit Art_Sonic_Roll1
		dplc 0,16


frame_Roll2:
		spritemap
		piece -16, -16, 4x4, 0&$FF
		endsprite

		dplcinit Art_Sonic_Roll2
		dplc 0,16


frame_Roll3:
		spritemap
		piece -16, -16, 4x4, 0&$FF
		endsprite

		dplcinit Art_Sonic_Roll3
		dplc 0,16


frame_Roll4:
		spritemap
		piece -16, -16, 4x4, 0&$FF
		endsprite

		dplcinit Art_Sonic_Roll4
		dplc 0,16


frame_Roll5:
		spritemap
		piece -16, -16, 4x4, 0&$FF
		endsprite

		dplcinit Art_Sonic_Roll5
		dplc 0,16


frame_Warp1:
		spritemap
		piece -20, -11, 4x3, 0&$FF
		piece 12, -11, 1x3, 12&$FF
		endsprite

		dplcinit Art_Sonic_Warp1
		dplc 0,15



frame_Warp2:
		spritemap
		piece -16, -16, 4x4, 0&$FF
		endsprite

		dplcinit Art_Sonic_Warp2
		dplc 0,16


frame_Warp3:
		spritemap
		piece -11, -20, 3x4, 0&$FF
		piece -11, 12, 3x1, 12&$FF
		endsprite

		dplcinit Art_Sonic_Warp3
		dplc 0,15



frame_Warp4:
		spritemap
		piece -16, -16, 4x4, 0&$FF
		endsprite

		dplcinit Art_Sonic_Warp4
		dplc 0,16


frame_Stop1:
		spritemap
		piece -14, -16, 3x4, 0&$FF
		piece 10, -2, 1x3, 12&$FF
		piece 2, 16, 1x1, 15&$FF
		endsprite

		dplcinit Art_Sonic_Stop1
		dplc 0,16




frame_Stop2:
		spritemap
		piece -13, -16, 3x4, 0&$FF
		piece 11, -2, 1x3, 12&$FF
		piece 3, 16, 1x1, 15&$FF
		piece -21, 4, 1x1, 16&$FF
		endsprite

		dplcinit Art_Sonic_Stop2
		dplc 0,17





frame_Duck:
		spritemap
		piece -15, -6, 4x4, 0&$FF
		endsprite

		dplcinit Art_Sonic_Duck
		dplc 0,16


frame_Balance1:
		spritemap
		piece -32, -5, 4x3, 0&$FF
		piece -21, -20, 3x2, 12&$FF
		piece 0, 2, 1x1, 18&$FF
		piece -11, 19, 1x1, 19&$FF
		endsprite

		dplcinit Art_Sonic_Balance1
		dplc 0,20





frame_Balance2:
		spritemap
		piece -30, -19, 4x4, 0&$FF
		piece 2, -11, 1x1, 16&$FF
		piece -16, 13, 2x1, 17&$FF
		endsprite

		dplcinit Art_Sonic_Balance2
		dplc 0,19




frame_Float1:
		spritemap
		piece -17, -12, 4x3, 0&$FF
		piece 15, -12, 2x3, 12&$FF
		endsprite

		dplcinit Art_Sonic_Float1
		dplc 0,18



frame_Float2:
		spritemap
		piece -22, -12, 4x3, 0&$FF
		piece 10, -7, 2x2, 12&$FF
		endsprite

		dplcinit Art_Sonic_Float2
		dplc 0,16



frame_Float3:
		spritemap
		piece -27, -12, 4x3, 0&$FF
		piece 5, -3, 1x2, 12&$FF
		endsprite

		dplcinit Art_Sonic_Float3
		dplc 0,14



frame_Float4:
		spritemap
		piece -16, -11, 4x3, 0&$FF
		piece 16, -10, 2x3, 12&$FF
		endsprite

		dplcinit Art_Sonic_Float4
		dplc 0,18



frame_Spring:
		spritemap
		piece -16, -22, 3x4, 0&$FF
		piece -7, 10, 1x2, 12&$FF
		endsprite

		dplcinit Art_Sonic_Spring
		dplc 0,14



frame_Hang1:
		spritemap
		piece -24, -10, 4x3, 0&$FF
		piece 8, -4, 2x3, 12&$FF
		endsprite

		dplcinit Art_Sonic_Hang1
		dplc 0,18



frame_Hang2:
		spritemap
		piece -24, -10, 4x3, 0&$FF
		piece 8, -3, 2x3, 12&$FF
		endsprite

		dplcinit Art_Sonic_Hang2
		dplc 0,18



frame_Leap1:
		spritemap
		piece -16, -24, 4x4, 0&$FF
		piece -7, 8, 3x2, 16&$FF
		piece 16, -10, 1x1, 22&$FF
		endsprite

		dplcinit Art_Sonic_Leap1
		dplc 0,23




frame_Leap2:
		spritemap
		piece -16, -24, 4x4, 0&$FF
		piece 16, -23, 1x1, 16&$FF
		piece -7, 8, 3x2, 17&$FF
		endsprite

		dplcinit Art_Sonic_Leap2
		dplc 0,23




frame_Push1:
		spritemap
		piece -11, -16, 3x4, 0&$FF
		piece -18, 10, 4x2, 12&$FF
		endsprite

		dplcinit Art_Sonic_Push1
		dplc 0,20



frame_Push2:
		spritemap
		piece -11, -17, 3x4, 0&$FF
		piece -13, 11, 2x2, 12&$FF
		endsprite

		dplcinit Art_Sonic_Push2
		dplc 0,16



frame_Push3:
		spritemap
		piece -11, -16, 3x4, 0&$FF
		piece -17, 11, 3x2, 12&$FF
		endsprite

		dplcinit Art_Sonic_Push3
		dplc 0,18



frame_Push4:
		spritemap
		piece -11, -17, 3x4, 0&$FF
		piece -13, 11, 2x2, 12&$FF
		endsprite

		dplcinit Art_Sonic_Push4
		dplc 0,16



frame_Surf:
		spritemap
		piece -16, -19, 3x2, 0&$FF
		piece -15, -3, 4x3, 6&$FF
		endsprite

		dplcinit Art_Sonic_Surf
		dplc 0,18



frame_BubStand:
		spritemap
		piece -14, -21, 3x4, 0&$FF
		piece -8, 11, 2x2, 12&$FF
		endsprite

		dplcinit Art_Sonic_BubStand
		dplc 0,16



frame_Burnt:
		spritemap
		piece -14, -24, 4x4, 0&$FF
		piece -8, 8, 3x2, 16&$FF
		piece 18, -19, 1x1, 22&$FF
		endsprite

		dplcinit Art_Sonic_Burnt
		dplc 0,23




frame_Drown:
		spritemap
		piece -14, -21, 4x4, 0&$FF
		piece -9, 11, 4x1, 16&$FF
		piece 18, -18, 1x1, 20&$FF
		endsprite

		dplcinit Art_Sonic_Drown
		dplc 0,21




frame_Death:
		spritemap
		piece -14, -24, 4x4, 0&$FF
		piece -9, 8, 4x1, 16&$FF
		piece 18, -18, 1x1, 20&$FF
		piece -9, 16, 1x1, 21&$FF
		endsprite

		dplcinit Art_Sonic_Death
		dplc 0,22





frame_Shrink1:
		spritemap
		piece -16, -20, 4x4, 0&$FF
		piece -10, 12, 3x1, 16&$FF
		endsprite

		dplcinit Art_Sonic_Shrink1
		dplc 0,19



frame_Shrink2:
		spritemap
		piece -14, -18, 3x1, 0&$FF
		piece -14, -10, 4x4, 3&$FF
		endsprite

		dplcinit Art_Sonic_Shrink2
		dplc 0,19



frame_Shrink3:
		spritemap
		piece -11, -14, 3x4, 0&$FF
		endsprite

		dplcinit Art_Sonic_Shrink3
		dplc 0,12


frame_Shrink4:
		spritemap
		piece -7, -9, 2x3, 0&$FF
		endsprite

		dplcinit Art_Sonic_Shrink4
		dplc 0,6


frame_Shrink5:
		spritemap
		piece -4, -5, 1x2, 0&$FF
		endsprite

		dplcinit Art_Sonic_Shrink5
		dplc 0,2


frame_Float5:
		spritemap
		piece -28, -12, 4x3, 0&$FF
		piece 4, -3, 2x2, 12&$FF
		endsprite

		dplcinit Art_Sonic_Float5
		dplc 0,16



frame_Float6:
		spritemap
		piece -12, -12, 4x3, 0&$FF
		piece 20, -7, 1x1, 12&$FF
		endsprite

		dplcinit Art_Sonic_Float6
		dplc 0,13



frame_Injury:
		spritemap
		piece -20, -12, 4x4, 0&$FF
		piece 12, -6, 1x3, 16&$FF
		endsprite

		dplcinit Art_Sonic_Injury
		dplc 0,19



frame_GetAir:
		spritemap
		piece -18, -18, 4x4, 0&$FF
		piece -15, 14, 4x1, 16&$FF
		piece 14, 4, 1x1, 20&$FF
		endsprite

		dplcinit Art_Sonic_GetAir
		dplc 0,21




frame_WaterSlide:
		spritemap
		piece -20, -12, 4x4, 0&$FF
		piece 12, -8, 1x3, 16&$FF
		endsprite

		dplcinit Art_Sonic_WaterSlide
		dplc 0,19



