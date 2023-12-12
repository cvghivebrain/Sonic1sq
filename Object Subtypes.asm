; ---------------------------------------------------------------------------
; Object subtypes
; ---------------------------------------------------------------------------

; Springs
type_spring_red:	equ 0				; x0 - red
type_spring_yellow:	equ 2				; x2 - yellow
type_spring_up:		equ 0				; $0x - facing up
type_spring_right:	equ $10				; $1x - facing right (or left if xflipped)
type_spring_down:	equ $20				; $2x - facing down (must also be yflipped)

; Spikes
type_spike_3up:		equ ((Spike_Var_0-Spike_Var)/4)<<4	; $0x - 3 facing up (or down if yflipped)
type_spike_3left:	equ ((Spike_Var_1-Spike_Var)/4)<<4	; $1x - 3 facing left (or right if xflipped)
type_spike_1up:		equ ((Spike_Var_2-Spike_Var)/4)<<4	; $2x - 1 facing up (or down if yflipped)
type_spike_3upwide:	equ ((Spike_Var_3-Spike_Var)/4)<<4	; $3x - 3 facing up (or down if yflipped), wide spacing
type_spike_6upwide:	equ ((Spike_Var_4-Spike_Var)/4)<<4	; $4x - 6 facing up (or down if yflipped), wide spacing
type_spike_1left:	equ ((Spike_Var_5-Spike_Var)/4)<<4	; $5x - 1 facing left (or right if xflipped)
type_spike_still:	equ id_Spike_Still			; x0 - doesn't move
type_spike_updown:	equ id_Spike_UpDown			; x2 - moves up and down 32px
type_spike_leftright:	equ id_Spike_LeftRight			; x4 - moves side-to-side 32px
type_spike_doublekill:	equ $80					; classic pre-bugfix behaviour, kills Sonic after losing rings immediately

; Monitor
type_monitor_eggman:	equ id_Pow_Eggman			; Eggman, does nothing
type_monitor_1up:	equ id_Pow_Sonic			; Extra life
type_monitor_shoes:	equ id_Pow_Shoes			; speed shoes
type_monitor_shield:	equ id_Pow_Shield			; shield
type_monitor_invincible: equ id_Pow_Invincible			; invincibility
type_monitor_rings:	equ id_Pow_Rings			; 10 rings

; HiddenBonus
type_bonus_10k:		equ (Bonus_Points_1-Bonus_Points)/2	; 1 - 10000 points
type_bonus_1k:		equ (Bonus_Points_2-Bonus_Points)/2	; 2 - 1000 points
type_bonus_100:		equ (Bonus_Points_3-Bonus_Points)/2	; 3 - 10 points (should be 100)

; Scenery
type_scen_cannon:	equ (Scen_Values_0-Scen_Values)/(Scen_Values_1-Scen_Values_0)	; 0 - SLZ cannon
type_scen_stump:	equ (Scen_Values_3-Scen_Values)/(Scen_Values_1-Scen_Values_0)	; 3 - GHZ bridge stump

; EdgeWalls
type_edge_shadow:	equ id_frame_edge_shadow	; 0
type_edge_light:	equ id_frame_edge_light		; 1
type_edge_dark:		equ id_frame_edge_dark		; 2

; CollapseLedge
type_ledge_left:	equ id_frame_ledge_left		; 0 - facing left
type_ledge_right:	equ id_frame_ledge_right	; 1 - also facing left, but always xflipped to face right

; FireMaker
type_fire_rate30:	equ (30/30)<<3				; every 0.5 seconds
type_fire_rate60:	equ (60/30)<<3				; every 1 second
type_fire_rate90:	equ (90/30)<<3				; every 1.5 seconds
type_fire_rate120:	equ (120/30)<<3				; every 2 seconds
type_fire_rate150:	equ (150/30)<<3				; every 2.5 seconds
type_fire_rate180:	equ (180/30)<<3				; every 3 seconds
type_fire_vertical:	equ 0
type_fire_horizontal:	equ $40
type_fire_gravity:	equ $80

; FloatingBlock
type_fblock_syz1x1:	equ ((FBlock_Var_0-FBlock_Var)/sizeof_FBlock_Var)<<4	; $0x - single 32x32 square
type_fblock_syz2x2:	equ ((FBlock_Var_1-FBlock_Var)/sizeof_FBlock_Var)<<4	; $1x - 2x2 32x32 squares
type_fblock_syz1x2:	equ ((FBlock_Var_2-FBlock_Var)/sizeof_FBlock_Var)<<4	; $2x - 1x2 32x32 squares
type_fblock_syzrect2x2:	equ ((FBlock_Var_3-FBlock_Var)/sizeof_FBlock_Var)<<4	; $3x - 2x2 32x26 squares
type_fblock_syzrect1x3:	equ ((FBlock_Var_4-FBlock_Var)/sizeof_FBlock_Var)<<4	; $4x - 1x3 32x26 squares
type_fblock_still:	equ id_FBlock_Still					; $x0 - doesn't move
type_fblock_leftright:	equ id_FBlock_LeftRight					; $x1 - moves side to side
type_fblock_leftrightwide: equ id_FBlock_LeftRightWide				; $x2 - moves side to side, larger distance
type_fblock_updown:	equ id_FBlock_UpDown					; $x3 - moves up and down
type_fblock_updownwide:	equ id_FBlock_UpDownWide				; $x4 - moves up and down, larger distance

; BigSpikeBall
type_bball_still:	equ id_BBall_Still		; 0 - doesn't move
type_bball_sideways:	equ id_BBall_Sideways		; 1 - moves side-to-side
type_bball_updown:	equ id_BBall_UpDown		; 2 - moves up and down
type_bball_circle:	equ id_BBall_Circle		; 3 - moves in a circle

; Harpoon
type_harp_h:		equ id_ani_harp_h_extending	; 0 - horizontal
type_harp_v:		equ id_ani_harp_v_extending	; 2 - vertical
type_harp_sync:		equ 8				; synchronised animation

; LabyrinthBlock
type_lblock_solid:	equ 0				; doesn't move
type_lblock_sink:	equ 1				; sinks when stood on

; Waterfall
type_wfall_vert:	equ id_frame_wfall_vertnarrow		; 0 - vertical narrow
type_wfall_cornermedium: equ id_frame_wfall_cornermedium	; 2 - corner
type_wfall_cornernarrow: equ id_frame_wfall_cornernarrow	; 3 - corner narrow
type_wfall_cornermedium2: equ id_frame_wfall_cornermedium2	; 4 - corner
type_wfall_cornernarrow2: equ id_frame_wfall_cornernarrow2	; 5 - corner narrow
type_wfall_cornernarrow3: equ id_frame_wfall_cornernarrow3	; 6 - corner narrow
type_wfall_vertwide:	equ id_frame_wfall_vertwide		; 7 - vertical wide
type_wfall_diagonal:	equ id_frame_wfall_diagonal		; 8 - diagonal
type_wfall_hi:		equ $80					; +$80 - high priority sprite

; WaterfallSplash
type_wfallsp_float:	equ 1					; matches y position to water surface
type_wfallsp_hide:	equ 2					; hide until level is updated by button

; Staircase
type_stair_above:	equ $10				; 0 - forms a staircase when stood on
type_stair_below:	equ $21				; 1 - forms a staircase when hit from below

; Fan
type_fan_left_onoff:	equ 0				; 0 - turns on/off every 3 seconds
type_fan_right_onoff:	equ 0
type_fan_left_on:	equ 1				; 1 - always on
type_fan_right_on:	equ 1

; Elevator
type_elev_up_short:	equ id_Elev_Up+$10		; rises 128px when stood on
type_elev_up_medium:	equ id_Elev_Up+$20		; rises 256px when stood on
type_elev_down_short:	equ id_Elev_Down+$10		; falls 128px when stood on
type_elev_upright:	equ id_Elev_UpRight+$20		; rises diagonally right when stood on
type_elev_up_vanish:	equ id_Elev_UpVanish+$30	; rises when stood on and vanishes

; SpinPlatform
type_spin_platform:	equ $80				; $8x - small spinning platform
type_spin_platform_alt:	equ $90				; $9x - small spinning platform, longer delay between spins

; Saws
type_saw_pizza_still:	equ 0			 	; 0 - pizza cutter, doesn't move
type_saw_pizza_sideways: equ 1			 	; 1 - pizza cutter, moves side-to-side
type_saw_pizza_updown:	equ 2			 	; 2 - pizza cutter, moves up and down
type_saw_ground_right:	equ 3			 	; 3 - ground saw, moves right
type_saw_ground_left:	equ 4			 	; 4 - ground saw, moves left

; ScrapStomp
type_stomp_slow:	equ 0				; stomper, drops quickly and rises slowly
type_stomp_fast_short:	equ 1				; stomper, drops quickly and rises quickly (64px)
type_stomp_fast_long:	equ 2				; stomper, drops quickly and rises quickly (96px)

; AnimalsEnd
type_animal_end_flicky:		equ 0
type_animal_end_flicky_onspot:	equ 1
type_animal_end_rabbit:		equ 2
type_animal_end_rabbit_onspot:	equ 3
type_animal_end_penguin:	equ 4
type_animal_end_penguin_onspot:	equ 5
type_animal_end_seal:		equ 6
type_animal_end_pig_onspot:	equ 7
type_animal_end_chicken:	equ 8
type_animal_end_squirrel:	equ 9
