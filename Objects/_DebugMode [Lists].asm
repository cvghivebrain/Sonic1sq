; ---------------------------------------------------------------------------
; Debug	mode item lists
; ---------------------------------------------------------------------------

sizeof_dbitem:	equ 18

dbheader:	macros
		dc.w .end-*-sizeof_dbitem-2
		
dbitem:		macro object,mappings,subtype,xyflip,frame,vramsetting,vrammod
		dc.l object, mappings
		dc.b subtype, xyflip
		dc.w frame
		dc.l vramsetting
		dc.w vrammod
		endm

DebugList_GHZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		;dbitem	HiddenBonus, Map_Bonus, type_bonus_10k, 0, id_frame_bonus_10000, vram_bonus/sizeof_cell, 0
		dbitem	Boss, Map_Bosses, $80, 0, id_frame_boss_ship, tile_Art_Eggman, 0
		dbitem	Crabmeat, Map_Crab, 0, 0, id_frame_crab_stand, v_tile_crabmeat, 0
		dbitem	BuzzBomber, Map_Buzz, 0, 0, id_frame_buzz_fly1, v_tile_buzzbomber, 0
		dbitem	Chopper, Map_Chop, 0, 0, id_frame_chopper_shut, v_tile_chopper, 0
		dbitem	MotoBug, Map_Moto, 0, 0, id_frame_moto_0, v_tile_motobug, 0
		dbitem	Newtron, Map_Newt, type_newt_blue+$20, 0, id_frame_newt_norm, v_tile_newtron, 0
		dbitem	Newtron, Map_Newt, type_newt_green+$20, 0, id_frame_newt_norm, v_tile_newtron, tile_pal2
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	PurpleRock, Map_PRock, 0, 0, id_frame_rock_0, tile_Kos_PurpleRock, tile_pal4
		dbitem	EdgeWalls, Map_Edge, type_edge_shadow, 0, id_frame_edge_shadow, tile_Kos_GhzEdgeWall, tile_pal3
		dbitem	BasicPlatform, Map_Platform, type_plat_still, 0, id_frame_plat_small, 0, tile_pal3
	.end:
DebugList_MZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Boss, Map_Bosses, $81, 0, id_frame_boss_ship, tile_Art_Eggman, 0
		dbitem	FireMakerBoss, Map_Fire, 0, 0, id_frame_fire_vertical1, v_tile_fireball, 0
		dbitem	BuzzBomber, Map_Buzz, 0, 0, id_frame_buzz_fly1, v_tile_buzzbomber, 0
		dbitem	Batbrain, Map_Bat, 0, 0, id_frame_bat_hanging, v_tile_batbrain, 0
		dbitem	Caterkiller, Map_Cat, 0, 0, id_frame_cat_head1, v_tile_caterkiller, tile_pal2
		dbitem	Splats, Map_Splats, 0, 0, id_frame_splats_fall, v_tile_splats, tile_pal2
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	SideStomp, Map_SStom, 0, 0, id_frame_mash_wallbracket, tile_Kos_MzMetal, 0
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	MarbleBrick, Map_Brick, type_brick_still, 0, id_frame_brick_0, 0, tile_pal3
		dbitem	PushBlock, Map_Push, type_pblock_single, 0, id_frame_pblock_single, tile_Kos_MzBlock, tile_pal3
		dbitem	SmashBlock, Map_Smab, 0, 0, id_frame_smash_two, tile_Kos_MzBlock, tile_pal3
		dbitem	CollapseFloor, Map_CFlo, 0, 0, id_frame_cfloor_mz, tile_Kos_MzBlock, tile_pal3
		dbitem	GlassBlock, Map_Glass, type_glass_drop_jump, 0, id_frame_glass_short, tile_Kos_MzGlass, tile_pal3
		dbitem	MovingBlock, Map_MBlock, type_mblock_3+type_mblock_leftright, 0, id_frame_mblock_mz3, tile_Kos_MzBlock, tile_pal3
	.end:
DebugList_SYZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Roller, Map_Roll, 0, 0, id_frame_roll_stand, v_tile_roller, 0
		dbitem	Crabmeat, Map_Crab, 0, 0, id_frame_crab_stand, v_tile_crabmeat, 0
		dbitem	BuzzBomber, Map_Buzz, 0, 0, id_frame_buzz_fly1, v_tile_buzzbomber, 0
		dbitem	Yadrin, Map_Yad, 0, 0, id_frame_yadrin_walk0, v_tile_yadrin, tile_pal2
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	Springs, Map_Spring, type_spring_yellow+type_spring_down, status_yflip, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	SpinningLight, Map_Light, 0, 0, id_frame_light_0, 0, 0
		dbitem	Bumper, Map_Bump, 0, 0, id_frame_bump_normal, v_tile_bumper, 0
		dbitem	Button, Map_But, 0, 0, id_frame_button_up, v_tile_button, 0
		dbitem	BasicPlatform, Map_Platform, type_plat_syz+type_plat_still, 0, id_frame_plat_syz, 0, tile_pal3
		dbitem	Boss, Map_Bosses, $82, 0, 0, tile_Art_Eggman, 0
		dbitem	CheeseBlock, Map_Cheese, 0, 0, id_frame_cheese_wholeblock, 0, tile_pal3
	.end:
DebugList_LZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Jaws, Map_Jaws, 8, 0, id_frame_jaws_open1, v_tile_jaws, tile_pal2
		dbitem	Burrobot, Map_Burro, 0, 0, id_frame_burro_walk1, v_tile_burrobot, tile_hi
		dbitem	Orbinaut, Map_Orb, 0, 0, id_frame_orb_normal, v_tile_orbinaut, 0
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Harpoon, Map_Harp, type_harp_h, 0, id_frame_harp_h_extended, tile_Kos_Harpoon, 0
		dbitem	Harpoon, Map_Harp, type_harp_v, 0, id_frame_harp_v_extended, tile_Kos_Harpoon, 0
		dbitem	Gargoyle, Map_Gar, 0, 0, id_frame_gargoyle_head, tile_Kos_Gargoyle, tile_pal3
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	Button, Map_But, 0, 0, id_frame_button_up, v_tile_button, 0
		dbitem	Bubble, Map_Bub, 0, 0, id_frame_bubble_bubmaker1, v_tile_bubbles, tile_hi
		dbitem	Cork, Map_Cork, 0, 0, id_frame_cork_0, tile_Kos_Cork, tile_pal3
		dbitem	LabyrinthBlock, Map_LBlock, type_lblock_sink, 0, id_frame_lblock_sinkblock, tile_Kos_LzDoorH, tile_pal3
		dbitem	LabyrinthBlock, Map_LBlock, type_lblock_solid, 0, id_frame_lblock_block, tile_Kos_LzBlock, tile_pal3
		dbitem	LabyrinthPlatform, Map_LPlat, 0, 0, id_frame_lplat_0, tile_Kos_LzPlatform, tile_pal3
		dbitem	HalfBlock, Map_MBlockLZ, $10, 0, id_frame_mblocklz_0, tile_Kos_LzHalfBlock, tile_pal3
		dbitem	Wheel, Map_LConv, 0, 0, id_frame_lcon_wheel1, tile_Kos_LzWheel, 0
		dbitem	Pole, Map_Pole, 0, 0, id_frame_pole_normal, tile_Kos_LzPole, tile_pal3
		dbitem	FlapDoor, Map_Flap, 2, 0, id_frame_flap_closed, tile_Kos_FlapDoor, tile_pal3
	.end:
DebugList_SLZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Orbinaut, Map_Orb, 3, 0, id_frame_orb_normal, v_tile_orbinaut, tile_pal2
		dbitem	Bomb, Map_Bomb, 0, 0, id_frame_bomb_stand1, v_tile_bomb, 0
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	Seesaw, Map_Seesaw, 0, 0, id_frame_seesaw_sloping_leftup, tile_Kos_Seesaw, 0
		dbitem	Fan, Map_Fan, type_fan_onoff, 0, id_frame_fan_0, tile_Kos_Fan, tile_pal3
		dbitem	BasicPlatform, Map_Platform, type_plat_slz+type_plat_still, 0, id_frame_plat_slz, 0, tile_pal3
		dbitem	CollapseFloor, Map_CFlo, type_cfloor_slz+type_cfloor_sided+1, 0, id_frame_cfloor_slz, tile_Kos_SlzBlock, tile_pal3
		dbitem	Elevator, Map_Elev, type_elev_up_short, 0, id_frame_elev_0, 0, tile_pal3
		dbitem	SquareBlock, Map_SBlock, 4, 0, id_frame_sblock_slz, 0, tile_pal3
	.end:
DebugList_SBZ:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Bomb, Map_Bomb, 0, 0, id_frame_bomb_stand1, v_tile_bomb, 0
		dbitem	ScrapEggman, Map_SEgg, 0, 0, id_frame_eggman_stand, tile_Art_Sbz2Eggman, 0
		dbitem	FalseFloor, Map_FFloor, 0, 0, id_frame_ffloor_wholeblock, tile_Kos_SbzBlock, tile_pal3
		dbitem	Caterkiller, Map_Cat, 0, 0, id_frame_cat_head1, v_tile_caterkiller, tile_pal2
		dbitem	BallHog, Map_Hog, $34, 0, id_frame_hog_standing, v_tile_ballhog, tile_pal2
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Saws, Map_Saw, type_saw_pizza_updown, 0, id_frame_saw_pizzacutter1, tile_Kos_Cutter, tile_pal3
		dbitem	Saws, Map_Saw, type_saw_ground_left, 0, id_frame_saw_groundsaw1, tile_Kos_Cutter, tile_pal3
		dbitem	Electro, Map_Elec, 4, 0, id_frame_electro_normal, tile_Kos_Electric, 0
		dbitem	ScrapStomp, Map_Stomp, type_stomp_slow, 0, id_frame_stomp_0, tile_Kos_Stomper, tile_pal2
		dbitem	Flamethrower, Map_Flame, $64, 0, id_frame_flame_pipe1, tile_Kos_FlamePipe, tile_hi
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
		dbitem	Button, Map_But, 0, 0, id_frame_button_up, v_tile_button, 0
		dbitem	AutoDoor, Map_ADoor, type_autodoor_left, 0, id_frame_autodoor_closed, tile_Kos_SbzDoorV, tile_pal3
		dbitem	AutoDoor, Map_ADoor, type_autodoor_right, status_xflip, id_frame_autodoor_closed, tile_Kos_SbzDoorV, tile_pal3
		dbitem	ScrapDoorH, Map_SDoorH, 0, 0, id_frame_sdoorh_0, tile_Kos_SbzDoorH, tile_pal3
		dbitem	Trapdoor, Map_Trap, 3, 0, id_frame_trap_closed, tile_Kos_TrapDoor, tile_pal3
		dbitem	Girder, Map_Gird, 0, 0, id_frame_girder_0, tile_Kos_Girder, tile_pal3
		dbitem	SlideBlock, Map_Slide, 0, 0, id_frame_slide_0, tile_Kos_SlideFloor, tile_pal3
		dbitem	YellowPlatform, Map_YPlat, 0, 0, id_frame_yplat_thin, tile_Kos_Stomper, tile_pal2
		dbitem	YellowPlatform, Map_YPlat, 1, 0, id_frame_yplat_fat, tile_Kos_Stomper, tile_pal2
	.end:
DebugList_Ending:
		dbheader
		dbitem	Rings, Map_Ring, 0, 0, id_frame_ring_front, v_tile_rings, tile_pal2
		dbitem	Monitor, Map_Monitor, type_monitor_rings, 0, id_frame_monitor_static0, tile_Art_Monitors, 0
		dbitem	Spikes, Map_Spike, type_spike_3up, 0, id_frame_spike_3up, v_tile_spikes, 0
		dbitem	Lamppost, Map_Lamp, 1, 0, id_frame_lamp_blue, v_tile_lamppost, 0
		dbitem	Springs, Map_Spring, type_spring_red, 0, id_frame_spring_up, v_tile_hspring, 0
		dbitem	Springs, Map_Spring, type_spring_yellow, 0, id_frame_spring_up, v_tile_hspring, tile_pal2
	.end:
