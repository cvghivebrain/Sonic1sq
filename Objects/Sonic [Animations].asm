; ---------------------------------------------------------------------------
; Animation script - Sonic
; ---------------------------------------------------------------------------

Ani_Sonic:	index *
		ptr Walk
		ptr Run
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

Walk:		dc.w $FFFF
		dc.w id_frame_walk13
		dc.w id_frame_walk14
		dc.w id_frame_walk15
		dc.w id_frame_walk16
		dc.w id_frame_walk11
		dc.w id_frame_walk12
		dc.w afEnd
		even

Run:		dc.w $FFFF
		dc.w id_frame_run11
		dc.w id_frame_run12
		dc.w id_frame_run13
		dc.w id_frame_run14
		dc.w afEnd
		dc.w afEnd
		dc.w afEnd
		even

Roll:		dc.w $FFFE
		dc.w id_frame_Roll1
		dc.w id_frame_Roll2
		dc.w id_frame_Roll3
		dc.w id_frame_Roll4
		dc.w id_frame_Roll5
		dc.w afEnd
		dc.w afEnd
		even

Roll2:		dc.w $FFFE
		dc.w id_frame_Roll1
		dc.w id_frame_Roll2
		dc.w id_frame_Roll5
		dc.w id_frame_Roll3
		dc.w id_frame_Roll4
		dc.w id_frame_Roll5
		dc.w afEnd
		even

Pushing:	dc.w $FFFD
		dc.w id_frame_push1
		dc.w id_frame_push2
		dc.w id_frame_push3
		dc.w id_frame_push4
		dc.w afEnd
		dc.w afEnd
		dc.w afEnd
		even

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
		dc.w afBack, 2*2
		even

Balance:	dc.w $1F
		dc.w id_frame_balance1
		dc.w id_frame_balance2
		dc.w afEnd
		even

LookUp:		dc.w $3F
		dc.w id_frame_lookup
		dc.w afEnd
		even

Duck:		dc.w $3F
		dc.w id_frame_duck
		dc.w afEnd
		even

Warp1:		dc.w $3F
		dc.w id_frame_warp1
		dc.w afEnd
		even

Warp2:		dc.w $3F
		dc.w id_frame_warp2
		dc.w afEnd
		even

Warp3:		dc.w $3F
		dc.w id_frame_warp3
		dc.w afEnd
		even

Warp4:		dc.w $3F
		dc.w id_frame_warp4
		dc.w afEnd
		even

Stop:		dc.w 7
		dc.w id_frame_stop1
		dc.w id_frame_stop2
		dc.w afEnd
		even

Float1:		dc.w 7
		dc.w id_frame_float1
		dc.w id_frame_float4
		dc.w afEnd
		even

Float2:		dc.w 7
		dc.w id_frame_float1
		dc.w id_frame_float2
		dc.w id_frame_float5
		dc.w id_frame_float3
		dc.w id_frame_float6
		dc.w afEnd
		even

Spring:		dc.w $2F
		dc.w id_frame_spring
		dc.w afChange, id_Walk
		even

Hang:		dc.w 4
		dc.w id_frame_hang1
		dc.w id_frame_hang2
		dc.w afEnd
		even

Leap1:		dc.w $F
		dc.w id_frame_leap1
		dc.w id_frame_leap1
		dc.w id_frame_leap1
		dc.w afBack, 1*2
		even

Leap2:		dc.w $F
		dc.w id_frame_leap1
		dc.w id_frame_leap2
		dc.w afBack, 1*2
		even

Surf:		dc.w $3F
		dc.w id_frame_surf
		dc.w afEnd
		even

GetAir:		dc.w $B
		dc.w id_frame_getair
		dc.w id_frame_getair
		dc.w id_frame_walk15
		dc.w id_frame_walk16
		dc.w afChange, id_Walk
		even

Burnt:		dc.w $20
		dc.w id_frame_burnt
		dc.w afEnd
		even

Drown:		dc.w $2F
		dc.w id_frame_drown
		dc.w afEnd
		even

Death:		dc.w 3
		dc.w id_frame_death
		dc.w afEnd
		even

Shrink:		dc.w 3
		dc.w id_frame_shrink1
		dc.w id_frame_shrink2
		dc.w id_frame_shrink3
		dc.w id_frame_shrink4
		dc.w id_frame_shrink5
		dc.w id_frame_blank
		dc.w afBack, 1*2
		even

Hurt:		dc.w 3
		dc.w id_frame_injury
		dc.w afEnd
		even

WaterSlide:	dc.w 7
		dc.w id_frame_injury
		dc.w id_frame_waterslide
		dc.w afEnd
		even

Blank:		dc.w $77
		dc.w id_frame_blank
		dc.w afChange, id_Walk
		even

Float3:		dc.w 3
		dc.w id_frame_float1
		dc.w id_frame_float2
		dc.w id_frame_float5
		dc.w id_frame_float3
		dc.w id_frame_float6
		dc.w afEnd
		even

Float4:		dc.w 3
		dc.w id_frame_float1
		dc.w afChange, id_Walk
		even
