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
type_spike_updown:	equ id_Spike_UpDown			; x1 - moves up and down 32px
type_spike_leftright:	equ id_Spike_LeftRight			; x2 - moves side-to-side 32px
type_spike_doublekill:	equ $80					; classic pre-bugfix behaviour, kills Sonic after losing rings immediately

; Monitor
type_monitor_eggman:	equ id_Pow_Eggman			; Eggman, does nothing
type_monitor_1up:	equ id_Pow_Sonic			; Extra life
type_monitor_shoes:	equ id_Pow_Shoes			; speed shoes
type_monitor_shield:	equ id_Pow_Shield			; shield
type_monitor_invincible: equ id_Pow_Invincible			; invincibility
type_monitor_rings:	equ id_Pow_Rings			; 10 rings

; Button
type_button_pal3:	equ $10					; use palette line 3
type_button_flash:	equ $20					; flashing animation
type_button_hi:		equ $40					; use high bit in button pressed status
type_button_block:	equ $80					; can be activated by block

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

; BasicPlatform
type_plat_still:	equ id_Plat_Type_Still			; 0 - doesn't move
type_plat_sideways:	equ id_Plat_Type_Sideways		; 1 - moves side-to-side
type_plat_updown:	equ id_Plat_Type_UpDown			; 2 - moves up and down
type_plat_falls:	equ id_Plat_Type_Falls			; 3 - falls when stood on
type_plat_sideways_rev:	equ id_Plat_Type_Sideways_Rev		; 5 - moves side-to-side, reversed
type_plat_updown_rev:	equ id_Plat_Type_UpDown_Rev		; 6 - moves up and down, reversed
type_plat_rises:	equ id_Plat_Type_Rises			; 7 - rises 512 pixels 1 second after a button is pressed
type_plat_updown_large:	equ id_Plat_Type_UpDown_Large+(id_frame_plat_large<<4) ; $A - moves up and down, large column-shaped platform
type_plat_updown_slow:	equ id_Plat_Type_UpDown_Slow		; $B - moves up and down, slow
type_plat_updown_slow_rev: equ id_Plat_Type_UpDown_Slow_Rev	; $C - moves up and down, slow reversed
type_plat_syz:		equ id_frame_plat_syz<<4		; +$20
type_plat_slz:		equ id_frame_plat_slz<<4		; +$30

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

; LargeGrass
type_grass_wide:	equ 0							; $0x - wide platform
type_grass_sloped:	equ $10							; $1x - sloped platform, usually sinks and catches fire
type_grass_narrow:	equ $20							; $2x - narrow platform
type_grass_still:	equ id_LGrass_Type00					; $x0 - doesn't move
type_grass_1:		equ id_LGrass_Type01					; $x1 - moves up and down 32 pixels
type_grass_2:		equ id_LGrass_Type02					; $x2 - moves up and down 48 pixels
type_grass_3:		equ id_LGrass_Type03					; $x3 - moves up and down 64 pixels
type_grass_4:		equ id_LGrass_Type04					; $x4 - moves up and down 96 pixels
type_grass_sinks:	equ id_LGrass_Type05					; $x5 - sinks and catches fire when stood on
type_grass_rev:		equ 8							; +8 - reverse movement direction

; ChainStomp
type_cstomp_wide:	equ 0							; $0x - wide stomper
type_cstomp_medium:	equ $10							; $1x - medium stomper
type_cstomp_small:	equ $20							; $2x - small stomper, no spikes
type_cstomp_proximity:	equ $40							; +$40 - activates when Sonic is near
type_cstomp_controlled:	equ $80							; +$80 - controlled by button 0
type_cstomp_0:		equ 0							; $x0 - chain length $70
type_cstomp_1:		equ 1							; $x1 - chain length $A0
type_cstomp_2:		equ 2							; $x2 - chain length $50
type_cstomp_3:		equ 3							; $x3 - chain length $78
type_cstomp_4:		equ 4							; $x4 - chain length $38
type_cstomp_5:		equ 5							; $x5 - chain length $58
type_cstomp_6:		equ 6							; $x6 - chain length $B8

; MarbleBrick
type_brick_still:	equ id_Brick_Still		; 0 - doesn't move
type_brick_wobbles:	equ id_Brick_Wobbles		; 1 - wobbles but doesn't fall
type_brick_falls:	equ id_Brick_Falls		; 2 - falls when Sonic is near
type_brick_rev:		equ 8				; +8 - reverse wobble direction

; GlassBlock
type_glass_still:	equ id_Glass_Still		; 0 - doesn't move
type_glass_updown:	equ id_Glass_UpDown		; 1 - moves up and down
type_glass_updown_rev:	equ id_Glass_UpDown_Rev		; 2 - moves up and down, reversed
type_glass_drop_jump:	equ id_Glass_Drop_Jump		; 3 - drops each time it's jumped on
type_glass_drop_button:	equ id_Glass_Drop_Button	; 4 - drops when button is pressed
type_glass_button_0:	equ 0				; $0x - button 0
type_glass_button_1:	equ $10				; $1x - button 1

; MovingBlock
type_mblock_1:		equ ((MBlock_Var_0-MBlock_Var)/sizeof_MBlock_Var)<<4	; $0x - single block
type_mblock_2:		equ ((MBlock_Var_1-MBlock_Var)/sizeof_MBlock_Var)<<4	; $1x - double block
type_mblock_sbz:	equ ((MBlock_Var_2-MBlock_Var)/sizeof_MBlock_Var)<<4	; $2x - SBZ black & yellow platform
type_mblock_sbzwide:	equ ((MBlock_Var_3-MBlock_Var)/sizeof_MBlock_Var)<<4	; $3x - SBZ red horizontal door
type_mblock_3:		equ ((MBlock_Var_4-MBlock_Var)/sizeof_MBlock_Var)<<4	; $4x - triple block
type_mblock_still:	equ id_MBlock_Still					; $x0 - doesn't move
type_mblock_leftright:	equ id_MBlock_LeftRight					; $x1 - moves side to side
type_mblock_right:	equ id_MBlock_Right					; $x2 - moves right when stood on, stops at wall
type_mblock_rightdrop:	equ id_MBlock_RightDrop					; $x4 - moves right when stood on, stops at wall and drops
type_mblock_rightdrop_button: equ id_MBlock_RightDrop_Button			; $x7 - appears when button 2 is pressed; moves right when stood on, stops at wall and drops
type_mblock_updown:	equ id_MBlock_UpDown					; $x8 - moves up and down
type_mblock_slide:	equ id_MBlock_Slide					; $x9 - quickly slides right when stood on

; PushBlock
type_pblock_single:	equ (PushB_Var_0-PushB_Var)/sizeof_PushB_Var		; 0 - single block
type_pblock_four:	equ (PushB_Var_1-PushB_Var)/sizeof_PushB_Var		; 1 - four blocks in a row
type_pblock_nograv:	equ $80							; +$80 - no gravity

; CollapseFloor
type_cfloor_slz:	equ id_frame_cfloor_slz<<3				; +$10 - SLZ mappings
type_cfloor_sided:	equ $80							; +$80 - collapse pattern depends on which side was touched

; FloatingBlock
type_fblock_syz1x1:	equ id_frame_fblock_syz1x1<<4		; $0x - single 32x32 square
type_fblock_syz2x2:	equ id_frame_fblock_syz2x2<<4		; $1x - 2x2 32x32 squares
type_fblock_syz1x2:	equ id_frame_fblock_syz1x2<<4		; $2x - 1x2 32x32 squares
type_fblock_syzrect2x2:	equ id_frame_fblock_syzrect2x2<<4	; $3x - 2x2 32x26 squares
type_fblock_syzrect1x3:	equ id_frame_fblock_syzrect1x3<<4	; $4x - 1x3 32x26 squares
type_fblock_slz:	equ id_frame_fblock_slz<<4		; $5x - 32x32 square
type_fblock_still:	equ id_FBlock_Still			; $x0 - doesn't move
type_fblock_leftright:	equ id_FBlock_LeftRight			; $x1 - moves side to side
type_fblock_leftrightwide: equ id_FBlock_LeftRightWide		; $x2 - moves side to side, larger distance
type_fblock_updown:	equ id_FBlock_UpDown			; $x3 - moves up and down
type_fblock_updownwide:	equ id_FBlock_UpDownWide		; $x4 - moves up and down, larger distance
type_fblock_upbutton:	equ id_FBlock_UpButton			; $x5 - moves up when button is pressed
type_fblock_downbutton:	equ id_FBlock_DownButton		; $x6 - moves down when button is pressed
type_fblock_farrightbutton: equ id_FBlock_FarRightButton	; $x7 - moves far right when button $F is pressed
type_fblock_squaresmall: equ id_FBlock_SquareSmall		; $x8 - moves in a small square
type_fblock_squaremedium: equ id_FBlock_SquareMedium		; $x9 - moves in a medium square
type_fblock_squarebig:	equ id_FBlock_SquareBig			; $xA - moves in a big square
type_fblock_squarebiggest: equ id_FBlock_SquareBiggest		; $xB - moves in a bigger square
type_fblock_leftbutton:	equ id_FBlock_LeftButton		; $xC - moves left when button is pressed
type_fblock_rightbutton: equ id_FBlock_RightButton		; $xD - moves right when button is pressed
type_fblock_button:	equ $80					; +$80 - links block to button and forces it to be type_fblock_upbutton or type_fblock_leftbutton

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
type_wfall_splash:	equ id_frame_wfall_splash1		; 9 - splash
type_wfall_splash_match: equ id_frame_wfall_splash1+$40		; $49 - splash, matches y position to water surface
type_wfall_splash_low:	equ id_frame_wfall_splash1+$20		; $29 - splash, low priority sprite on specific level tile
type_wfall_hi:		equ $80					; +$80 - high priority sprite

; Staircase
type_stair_above:	equ id_Stair_Type00		; 0 - forms a staircase when stood on
type_stair_below:	equ id_Stair_Type02		; 2 - forms a staircase when hit from below

; Fan
type_fan_left_onoff:	equ 0				; 0 - blows left, turns on/off every 3 seconds
type_fan_right_onoff:	equ 1				; 1 - blows right, turns on/off every 3 seconds
type_fan_left_on:	equ 2				; 2 - blows left, always on
type_fan_right_on:	equ 3				; 3 - blows right, always on

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
type_saw_pizza_still:	equ id_Saw_Pizza_Still	 	; 0 - pizza cutter, doesn't move
type_saw_pizza_sideways: equ id_Saw_Pizza_Sideways 	; 1 - pizza cutter, moves side-to-side
type_saw_pizza_updown:	equ id_Saw_Pizza_UpDown	 	; 2 - pizza cutter, moves up and down
type_saw_ground_right:	equ id_Saw_Ground_Right	 	; 3 - ground saw, moves right
type_saw_ground_left:	equ id_Saw_Ground_Left	 	; 4 - ground saw, moves left

; ScrapStomp
type_stomp_slow:	equ 0				; stomper, drops quickly and rises slowly
type_stomp_fast_short:	equ 1				; stomper, drops quickly and rises quickly (64px)
type_stomp_fast_long:	equ 2				; stomper, drops quickly and rises quickly (96px)