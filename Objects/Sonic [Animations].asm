; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------

Ani_Sonic:	index *
		ptr Walk
		ptr Walk2
		ptr Walk3
		ptr Walk4
		ptr Run
		ptr Run2
		ptr Run3
		ptr Run4
		ptr Roll
		ptr Roll2
		ptr Pushing
		ptr Wait
		ptr Balance
		ptr LookUp
		ptr Duck
		ptr Warp1
		ptr Warp2
		ptr Warp3
		ptr Warp4
		ptr Stop
		ptr Float1
		ptr Float2
		ptr Spring
		ptr Hang
		ptr Leap1
		ptr Leap2
		ptr Surf
		ptr GetAir
		ptr Burnt
		ptr Drown
		ptr Death
		ptr Shrink
		ptr Hurt
		ptr WaterSlide
		ptr Blank
		ptr Float3
		ptr Float4

Walk:		dc.w id_Anim_Flag_WalkRun
		dc.w id_frame_walk13
		dc.w id_frame_walk14
		dc.w id_frame_walk15
		dc.w id_frame_walk16
		dc.w id_frame_walk11
		dc.w id_frame_walk12
		dc.w id_Anim_Flag_Restart_Sonic

Walk2:		dc.w id_Anim_Flag_WalkRun
		dc.w id_frame_walk23
		dc.w id_frame_walk24
		dc.w id_frame_walk25
		dc.w id_frame_walk26
		dc.w id_frame_walk21
		dc.w id_frame_walk22
		dc.w id_Anim_Flag_Restart_Sonic

Walk3:		dc.w id_Anim_Flag_WalkRun
		dc.w id_frame_walk33
		dc.w id_frame_walk34
		dc.w id_frame_walk35
		dc.w id_frame_walk36
		dc.w id_frame_walk31
		dc.w id_frame_walk32
		dc.w id_Anim_Flag_Restart_Sonic

Walk4:		dc.w id_Anim_Flag_WalkRun
		dc.w id_frame_walk43
		dc.w id_frame_walk44
		dc.w id_frame_walk45
		dc.w id_frame_walk46
		dc.w id_frame_walk41
		dc.w id_frame_walk42
		dc.w id_Anim_Flag_Restart_Sonic

Run:		dc.w id_Anim_Flag_WalkRun
		dc.w id_frame_run11
		dc.w id_frame_run12
		dc.w id_frame_run13
		dc.w id_frame_run14
		dc.w id_Anim_Flag_Restart_Sonic
		dc.w id_Anim_Flag_Restart_Sonic
		dc.w id_Anim_Flag_Restart_Sonic

Run2:		dc.w id_Anim_Flag_WalkRun
		dc.w id_frame_run21
		dc.w id_frame_run22
		dc.w id_frame_run23
		dc.w id_frame_run24
		dc.w id_Anim_Flag_Restart_Sonic
		dc.w id_Anim_Flag_Restart_Sonic
		dc.w id_Anim_Flag_Restart_Sonic

Run3:		dc.w id_Anim_Flag_WalkRun
		dc.w id_frame_run31
		dc.w id_frame_run32
		dc.w id_frame_run33
		dc.w id_frame_run34
		dc.w id_Anim_Flag_Restart_Sonic
		dc.w id_Anim_Flag_Restart_Sonic
		dc.w id_Anim_Flag_Restart_Sonic

Run4:		dc.w id_Anim_Flag_WalkRun
		dc.w id_frame_run41
		dc.w id_frame_run42
		dc.w id_frame_run43
		dc.w id_frame_run44
		dc.w id_Anim_Flag_Restart_Sonic
		dc.w id_Anim_Flag_Restart_Sonic
		dc.w id_Anim_Flag_Restart_Sonic

Roll:		dc.w id_Anim_Flag_Roll
		dc.w id_frame_Roll1
		dc.w id_frame_Roll2
		dc.w id_frame_Roll3
		dc.w id_frame_Roll4
		dc.w id_frame_Roll5
		dc.w id_Anim_Flag_Restart_Sonic
		dc.w id_Anim_Flag_Restart_Sonic

Roll2:		dc.w id_Anim_Flag_Roll
		dc.w id_frame_Roll1
		dc.w id_frame_Roll2
		dc.w id_frame_Roll5
		dc.w id_frame_Roll3
		dc.w id_frame_Roll4
		dc.w id_frame_Roll5
		dc.w id_Anim_Flag_Restart_Sonic

Pushing:	dc.w id_Anim_Flag_Push
		dc.w id_frame_push1
		dc.w id_frame_push2
		dc.w id_frame_push3
		dc.w id_frame_push4
		dc.w id_Anim_Flag_Restart_Sonic
		dc.w id_Anim_Flag_Restart_Sonic
		dc.w id_Anim_Flag_Restart_Sonic

Wait:		dc.w $17
		dc.w id_frame_stand
		dc.w id_frame_stand
		dc.w id_frame_stand
		dc.w id_frame_stand
		dc.w id_frame_stand
		dc.w id_frame_stand
		dc.w id_frame_stand
		dc.w id_frame_stand
		dc.w id_frame_stand
		dc.w id_frame_stand
		dc.w id_frame_stand
		dc.w id_frame_stand
		dc.w id_frame_wait2
		dc.w id_frame_wait1
		dc.w id_frame_wait1
		dc.w id_frame_wait1
		dc.w id_frame_wait2
		dc.w id_frame_wait3
		dc.w id_Anim_Flag_Back, 2

Balance:	dc.w $1F
		dc.w id_frame_balance1
		dc.w id_frame_balance2
		dc.w id_Anim_Flag_Restart

LookUp:		dc.w $3F
		dc.w id_frame_lookup
		dc.w id_Anim_Flag_Restart

Duck:		dc.w $3F
		dc.w id_frame_duck
		dc.w id_Anim_Flag_Restart

Warp1:		dc.w $3F
		dc.w id_frame_warp1
		dc.w id_Anim_Flag_Restart

Warp2:		dc.w $3F
		dc.w id_frame_warp2
		dc.w id_Anim_Flag_Restart

Warp3:		dc.w $3F
		dc.w id_frame_warp3
		dc.w id_Anim_Flag_Restart

Warp4:		dc.w $3F
		dc.w id_frame_warp4
		dc.w id_Anim_Flag_Restart

Stop:		dc.w 7
		dc.w id_frame_stop1
		dc.w id_frame_stop2
		dc.w id_Anim_Flag_Restart

Float1:		dc.w 7
		dc.w id_frame_float1
		dc.w id_frame_float4
		dc.w id_Anim_Flag_Restart

Float2:		dc.w 7
		dc.w id_frame_float1
		dc.w id_frame_float2
		dc.w id_frame_float5
		dc.w id_frame_float3
		dc.w id_frame_float6
		dc.w id_Anim_Flag_Restart

Spring:		dc.w $2F
		dc.w id_frame_spring
		dc.w id_Anim_Flag_Change, id_Walk

Hang:		dc.w 4
		dc.w id_frame_hang1
		dc.w id_frame_hang2
		dc.w id_Anim_Flag_Restart

Leap1:		dc.w $F
		dc.w id_frame_leap1
		dc.w id_frame_leap1
		dc.w id_frame_leap1
		dc.w id_Anim_Flag_Stop

Leap2:		dc.w $F
		dc.w id_frame_leap1
		dc.w id_frame_leap2
		dc.w id_Anim_Flag_Stop

Surf:		dc.w $3F
		dc.w id_frame_surf
		dc.w id_Anim_Flag_Restart

GetAir:		dc.w $B
		dc.w id_frame_getair
		dc.w id_frame_getair
		dc.w id_frame_walk15
		dc.w id_frame_walk16
		dc.w id_Anim_Flag_Change, id_Walk

Burnt:		dc.w $20
		dc.w id_frame_burnt
		dc.w id_Anim_Flag_Restart

Drown:		dc.w $2F
		dc.w id_frame_drown
		dc.w id_Anim_Flag_Restart

Death:		dc.w 3
		dc.w id_frame_death
		dc.w id_Anim_Flag_Restart

Shrink:		dc.w 3
		dc.w id_frame_shrink1
		dc.w id_frame_shrink2
		dc.w id_frame_shrink3
		dc.w id_frame_shrink4
		dc.w id_frame_shrink5
		dc.w id_frame_blank
		dc.w id_Anim_Flag_Stop

Hurt:		dc.w 3
		dc.w id_frame_injury
		dc.w id_Anim_Flag_Restart

WaterSlide:	dc.w 7
		dc.w id_frame_injury
		dc.w id_frame_waterslide
		dc.w id_Anim_Flag_Restart

Blank:		dc.w $77
		dc.w id_frame_blank
		dc.w id_Anim_Flag_Change, id_Walk

Float3:		dc.w 3
		dc.w id_frame_float1
		dc.w id_frame_float2
		dc.w id_frame_float5
		dc.w id_frame_float3
		dc.w id_frame_float6
		dc.w id_Anim_Flag_Restart

Float4:		dc.w 3
		dc.w id_frame_float1
		dc.w id_Anim_Flag_Change, id_Walk
