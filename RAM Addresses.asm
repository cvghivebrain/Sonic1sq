; ---------------------------------------------------------------------------
; RAM Addresses - Variables (v) and Flags (f)
; ---------------------------------------------------------------------------

		pusho		; save options
		opt	ae+	; enable auto evens

; Error trap variables:

v_reg_buffer:			equ $FFFFFC00 ; stores registers d0-a7 during an error event ($40 bytes) - v_respawn_list uses same space
v_sp_buffer:			equ $FFFFFC40 ; stores most recent sp address (4 bytes) - v_respawn_list uses same space
v_error_type:			equ $FFFFFC44 ; error type - v_respawn_list uses same space

; Major data blocks:

v_256x256_tiles:		equ   $FF0000 ; 256x256 tile mappings ($A400 bytes)
				rsset $FFFF0000+sizeof_256x256_all
v_level_layout:			rs.b sizeof_level ; $FFFFA400 ; level and background layouts ($400 bytes)
v_bgscroll_buffer:		rs.b $200 ; $FFFFA800 ; background scroll buffer
v_kosplc_buffer_end:		equ __rs ; KosPLC shouldn't overwrite the sprite queue or it'll cause problems
v_sprite_queue:			rs.b sizeof_priority*8 ; $FFFFAC00 ; sprite display queue, first section is highest priority ($400 bytes; 8 sections of $80 bytes)
v_sonic_gfx_buffer:		rs.b sizeof_vram_sonic ; $FFFFC800 ; buffered Sonic graphics ($17 cells) ($2E0 bytes)
v_sonic_pos_tracker:		rs.l $40 ; $FFFFCB00 ; earlier position tracking list for Sonic, used by invincibility stars ($100 bytes)
				rsblock hscroll
v_hscroll_buffer:		rs.b sizeof_vram_hscroll ; $FFFFCC00 ; scrolling table data ($380 bytes)
				rsblockend hscroll
v_hscroll_buffer_padding:	rs.b sizeof_vram_hscroll_padded-sizeof_vram_hscroll ; $FFFFCF80 ; not needed but cleared by ClearScreen ($80 bytes)

				rsblock ost ; $D000-$EFFF cleared by GM_Title, GM_Level, GM_Special, GM_Continue, GM_Credits, GM_Ending
v_ost_all:			rs.b sizeof_ost*countof_ost ; $FFFFD000 ; object variable space ($40 bytes per object; $80 objects) ($2000 bytes)
	v_ost_player:		equ v_ost_all ; object variable space for Sonic ($40 bytes)
	v_ost_level_obj:	equ v_ost_all+(sizeof_ost*countof_ost_inert) ; level object variable space ($1800 bytes)
v_ost_end:			equ v_ost_all+(sizeof_ost*countof_ost) ; $FFFFF000
				rsblockend ost

v_snddriver_ram:		rs.b v_snddriver_size ; $FFFFF000 ; start of RAM for the sound driver data ($5C0 bytes)
								; sound driver equates are now defined in "sound/Sound Equates.asm"

; General variables:

v_gamemode:			rs.b 1 ; $FFFFF600 ; gamemode: 00=Sega; 04=Title; 08=Demo; 0C=Level; 10=SS; 14=Cont; 18=End; 1C=Credit; 8C=PreLevel
v_joypad_hold:			rs.w 1 ; $FFFFF602 ; joypad input - held, can be overridden by demos
v_joypad_press:			equ __rs-1 ; $FFFFF603 ; joypad input - pressed, can be overridden by demos
v_joypad_hold_actual:		rs.w 1 ; $FFFFF604 ; joypad input - held, actual
v_joypad_press_actual:		equ __rs-1 ; $FFFFF605 ; joypad input - pressed, actual
v_joypad2_hold_actual:		rs.w 1 ; $FFFFF606 ; joypad 2 input - held, actual - unused
v_joypad2_press_actual:		equ __rs-1 ; $FFFFF607 ; joypad 2 input - pressed, actual - unused
v_vdp_mode_buffer:		rs.w 1 ; $FFFFF60C ; VDP register $81 buffer - contains $8134 which is sent to vdp_control_port
v_countdown:			rs.w 1 ; $FFFFF614 ; decrements every time VBlank runs, used as a general purpose timer
v_fg_y_pos_vsram:		rs.l 1 ; $FFFFF616 ; foreground y position, sent to VSRAM during VBlank
v_bg_y_pos_vsram:		equ __rs-2 ; $FFFFF618 ; background y position, sent to VSRAM during VBlank
v_vdp_hint_counter:		rs.w 1 ; $FFFFF624 ; VDP register $8A buffer - horizontal interrupt counter ($8Axx)
v_vdp_hint_line:		equ __rs-1 ; screen line where water starts and palette is changed by HBlank

				rsblock vblankstuff ; $F628-$F67F cleared by GM_Level, GM_Ending
v_vblank_routine:		rs.b 1 ; $FFFFF62A ; VBlank routine counter
v_spritecount:			rs.b 1 ; $FFFFF62C ; number of sprites on-screen
v_palcycle_num:			rs.w 1 ; $FFFFF632 ; palette cycling - current index number
v_palcycle_time:		rs.w 1 ; $FFFFF634 ; palette cycling - time until the next change
f_sega_pal_next:		equ __rs-1 ; $FFFFF635 ; flag set when Sega stripe animation is complete
v_random:			rs.l 1 ; $FFFFF636 ; pseudo random number generator result
f_pause:			rs.w 1 ; $FFFFF63A ; flag set to pause the game
v_vdp_dma_buffer:		rs.w 1 ; $FFFFF640 ; VDP DMA command buffer
f_hblank_pal_change:		rs.w 1 ; $FFFFF644 ; flag set to change palette during HBlank (0000 = no; 0001 = change)
v_water_height_actual:		rs.w 1 ; $FFFFF646 ; water height, actual
v_water_height_normal:		rs.w 1 ; $FFFFF648 ; water height, ignoring wobble
v_water_height_next:		rs.w 1 ; $FFFFF64A ; water height, next target
v_water_direction:		rs.b 1 ; $FFFFF64C ; water setting - 0 = no water; 1 = water moves down; -1 = water moves up
v_water_routine:		rs.b 1 ; $FFFFF64D ; water event routine counter
f_water_pal_full:		rs.b 1 ; $FFFFF64E ; flag set when water covers the entire screen (00 = partly/all dry; 01 = all underwater)
f_hblank_run_snd:		rs.b 1 ; $FFFFF64F ; flag set when sound driver should be run from HBlank
v_palcycle_buffer:		rs.w $20 ; $FFFFF650 ; palette data buffer (used for palette cycling)
				rsblockend vblankstuff

v_dma_queue:			rs.w (sizeof_dma/2)*countof_dma ; ROM/RAM to VRAM DMA transfer queue ($140 bytes)

				rsblock levelinfo ; $F700-$F7FF cleared by GM_Level, GM_Special, GM_Ending
v_camera_x_pos:			rs.l 1 ; $FFFFF700 ; foreground camera x position
v_camera_y_pos:			rs.l 1 ; $FFFFF704 ; foreground camera y position
v_bg1_x_pos:			rs.l 1 ; $FFFFF708 ; background x position
v_bg1_y_pos:			rs.l 1 ; $FFFFF70C ; background y position
v_bg2_x_pos:			rs.l 1 ; $FFFFF710 ; background 2 x position (e.g. GHZ treeline)
v_bg2_y_pos:			rs.l 1 ; $FFFFF714 ; background 2 y position
v_bg3_x_pos:			rs.l 1 ; $FFFFF718 ; background 3 x position (e.g. GHZ mountains)
v_bg3_y_pos:			rs.l 1 ; $FFFFF71C ; background 3 y position
v_boundary_left_next:		rs.l 1 ; $FFFFF720 ; left level boundary, next (actual boundary shifts to match this)
v_boundary_right_next:		equ __rs-2 ; $FFFFF722 ; right level boundary, next
v_boundary_top_next:		rs.l 1 ; $FFFFF724 ; top level boundary, next
v_boundary_bottom_next:		equ __rs-2 ; $FFFFF726 ; bottom level boundary, next
v_boundary_left:		rs.l 1 ; $FFFFF728 ; left level boundary
v_boundary_right:		equ __rs-2 ; $FFFFF72A ; right level boundary
v_boundary_top:			rs.l 1 ; $FFFFF72C ; top level boundary
v_boundary_bottom:		equ __rs-2 ; $FFFFF72E ; bottom level boundary
v_camera_x_diff:		rs.w 1 ; $FFFFF73A ; camera x position change since last frame * $100
v_camera_y_diff:		rs.w 1 ; $FFFFF73C ; camera y position change since last frame * $100
v_camera_y_shift:		rs.w 1 ; $FFFFF73E ; camera y position shift when Sonic looks up/down - $60 = default; $C8 = look up; 8 = look down
v_dle_routine:			rs.b 1 ; $FFFFF742 ; dynamic level event - routine counter
f_disable_scrolling:		rs.b 1 ; $FFFFF744 ; flag set to disable all scrolling and LZ water features
v_fg_x_redraw_flag:		rs.w 1 ; $FFFFF74A ; $10 when foreground camera x has moved 16 pixels and needs redrawing
v_fg_y_redraw_flag:		equ __rs-1 ; $10 when foreground camera y has moved 16 pixels and needs redrawing
v_bg1_x_redraw_flag:		rs.b 1 ; $FFFFF74C ; $10 when background x has moved 16 pixels and needs redrawing
v_bg1_y_redraw_flag:		rs.b 1 ; $FFFFF74D ; $10 when background y has moved 16 pixels and needs redrawing
v_bg2_x_redraw_flag:		rs.b 1 ; $FFFFF74E ; $10 when background 2 x has moved 16 pixels and needs redrawing
v_bg2_y_redraw_flag:		rs.b 1 ; $FFFFF74F ; $10 when background 2 y has moved 16 pixels and needs redrawing - unused
v_bg3_x_redraw_flag:		rs.b 1 ; $FFFFF750 ; $10 when background 3 x has moved 16 pixels and needs redrawing
v_bg3_y_redraw_flag:		rs.b 1 ; $FFFFF751 ; $10 when background 3 y has moved 16 pixels and needs redrawing - unused
v_fg_redraw_direction:		rs.w 1 ; $FFFFF754 ; 16x16 row redraw flag bitfield for foreground - high byte: 0 = top; 1 = bottom; 2 = left; 3 = right; 4 = top (all); 5 = bottom (all)
v_bg1_redraw_direction:		rs.w 1 ; $FFFFF756 ; 16x16 row redraw flag bitfield for background 1
v_bg2_redraw_direction:		rs.w 1 ; $FFFFF758 ; 16x16 row redraw flag bitfield for background 2
v_bg3_redraw_direction:		rs.w 1 ; $FFFFF75A ; 16x16 row redraw flag bitfield for background 3
f_boundary_bottom_change:	rs.b 1 ; $FFFFF75C ; flag set when bottom level boundary is changing
v_sonic_max_speed:		rs.w 1 ; $FFFFF760 ; Sonic's maximum speed
v_sonic_acceleration:		rs.w 1 ; $FFFFF762 ; Sonic's acceleration
v_sonic_deceleration:		rs.w 1 ; $FFFFF764 ; Sonic's deceleration
v_sonic_last_frame_id:		rs.b 1 ; $FFFFF766 ; Sonic's last frame id, compared with current frame to determine if graphics need updating
v_angle_right:			rs.b 1 ; $FFFFF768 ; angle of floor on Sonic's right side
v_angle_left:			rs.b 1 ; $FFFFF76A ; angle of floor on Sonic's left side
v_opl_routine:			rs.b 1 ; $FFFFF76C ; ObjPosLoad - routine counter
v_opl_screen_x_pos:		rs.w 1 ; $FFFFF76E ; ObjPosLoad - screen x position, rounded down to nearest $80
v_opl_ptr_right:		rs.l 1 ; $FFFFF770 ; ObjPosLoad - pointer to objpos data for 320px right of screen
v_opl_ptr_left:			rs.l 1 ; $FFFFF774 ; ObjPosLoad - pointer to objpos data for 128px left of screen
v_opl_ptr_alt_right:		rs.l 1 ; $FFFFF778 ; ObjPosLoad - pointer to secondary objpos data
v_opl_ptr_alt_left:		rs.l 1 ; $FFFFF77C ; ObjPosLoad - pointer to secondary objpos data
v_ss_angle:			rs.w 1 ; $FFFFF780 ; Special Stage angle
v_ss_rotation_speed:		rs.w 1 ; $FFFFF782 ; Special Stage rotation speed
v_demo_input_counter:		rs.w 1 ; $FFFFF790 ; tracks progress in the demo input data, increases by 2 when input changes
v_demo_input_time:		rs.b 1 ; $FFFFF792 ; time remaining for current demo "button press"
v_palfade_time:			rs.w 1 ; $FFFFF794 ; palette fading - time until next change
v_collision_index_ptr:		rs.l 1 ; $FFFFF796 ; ROM address for collision index of current level
v_16x16_ptr:			rs.l 1 ; pointer to 16x16 mappings
v_opl_data_ptr:			rs.l 1 ; pointer to start of OPL data
v_aniart_ptr:			rs.l 1 ; pointer to animated level art routine
v_debug_ptr:			rs.l 1 ; pointer to debug list
v_palcycle_ptr:			rs.l 1 ; pointer to palette cycling routine
v_dle_ptr:			rs.l 1 ; pointer to dynamic level event routine
v_deformlayer_ptr:		rs.l 1 ; pointer to bg deformation routine
v_debug_count:			rs.w 1 ; number of items in debug list
f_water_enable:			rs.b 1 ; flag set to enable water
v_waterfilter_id:		rs.b 1 ; water palette filter id
v_bgm:				rs.b 1 ; music track id for current zone
v_titlecard_zone:		rs.w 1 ; frame id of title card (zone name)
v_titlecard_act:		rs.w 1 ; frame id of title card (act number)
v_titlecard_uplc:		rs.w 1 ; UPLC id of title card
v_titlecard_loaded:		rs.b 1 ; count of title card objects (+1 for each object)
v_titlecard_state:		rs.b 1 ; state of title card objects (+1 for each object when it stops on screen)
v_haspassed_state:		rs.b 1 ; state of "Sonic Has Passed" title card (1 = loaded; 2 = move off screen on SBZ2)
v_tile_hud:			rs.w 1
v_tile_swing:			rs.w 1
v_tile_wall:			rs.w 1
v_tile_crabmeat			rs.w 1
v_tile_buzzbomber		rs.w 1
v_tile_chopper			rs.w 1
v_tile_newtron			rs.w 1
v_tile_motobug			rs.w 1
v_tile_spikes			rs.w 1
v_tile_hspring			rs.w 1
v_tile_vspring			rs.w 1
v_tile_fireball			rs.w 1
v_tile_batbrain			rs.w 1
v_tile_caterkiller		rs.w 1
v_tile_splats			rs.w 1
v_tile_button			rs.w 1
v_tile_bumper			rs.w 1
v_tile_spikechain		rs.w 1
v_tile_spikeball		rs.w 1
v_tile_yadrin			rs.w 1
v_tile_roller			rs.w 1
v_tile_orbinaut			rs.w 1
v_tile_jaws			rs.w 1
v_tile_burrobot			rs.w 1
v_tile_bomb			rs.w 1
v_tile_ballhog			rs.w 1
v_tile_emeralds			rs.w 1
v_tile_lamppost			rs.w 1
v_tile_points			rs.w 1
v_tile_rings			rs.w 1
v_tile_animal1			rs.w 1
v_tile_animal2			rs.w 1
v_tile_credits			rs.w 1
v_tile_titlecard		rs.w 1
v_tile_act			rs.w 1
v_tile_a			rs.w 1
v_tile_b			rs.w 1
v_tile_c			rs.w 1
v_tile_d			rs.w 1
v_tile_e			rs.w 1
v_tile_f			rs.w 1
v_tile_g			rs.w 1
v_tile_h			rs.w 1
v_tile_i			rs.w 1
v_tile_j			rs.w 1
v_tile_k			rs.w 1
v_tile_l			rs.w 1
v_tile_m			rs.w 1
v_tile_n			rs.w 1
v_tile_o			rs.w 1
v_tile_p			rs.w 1
v_tile_q			rs.w 1
v_tile_r			rs.w 1
v_tile_s			rs.w 1
v_tile_t			rs.w 1
v_tile_u			rs.w 1
v_tile_v			rs.w 1
v_tile_w			rs.w 1
v_tile_x			rs.w 1
v_tile_y			rs.w 1
v_tile_z			rs.w 1
v_palcycle_ss_num:		rs.w 1 ; $FFFFF79A ; palette cycling in Special Stage - current index number
v_palcycle_ss_time:		rs.w 1 ; $FFFFF79C ; palette cycling in Special Stage - time until next change
v_palcycle_ss_unused:		rs.w 1 ; $FFFFF79E ; palette cycling in Special Stage - unused offset value, always 0
v_ss_bg_mode:			rs.w 1 ; $FFFFF7A0 ; Special Stage fish/bird background animation mode
v_cstomp_y_pos:			rs.w 1 ; $FFFFF7A4 ; y position of MZ chain stomper, used for interaction with pushable green block
v_boss_status:			rs.b 1 ; $FFFFF7A7 ; status of boss and prison capsule - 01 = boss defeated; 02 = prison opened
v_sonic_pos_tracker_num:	rs.w 1 ; $FFFFF7A8 ; current location within position tracking data
v_sonic_pos_tracker_num_low:	equ __rs-1
f_boss_boundary:		rs.b 1 ; $FFFFF7AA ; flag set to stop Sonic moving off the right side of the screen at a boss
v_monitor_slots:		rs.b 1
v_lives_spriteindex:		rs.w 1 ; sprite mappings for lives counter
v_lives_spritecount:		rs.w 1
v_lives_sprite1:		rs.w 3
v_lives_sprite2:		rs.w 3
v_rings_spriteindex:		rs.w 1 ; sprite mappings for rings counter
v_rings_spritecount:		rs.w 1
v_rings_sprite1:		rs.w 3
v_rings_sprite2:		rs.w 3
v_rings_sprite3:		rs.w 3
v_256x256_with_loop_1:		rs.l 1 ; $FFFFF7AC ; 256x256 level tile which contains a loop (GHZ/SLZ)
v_256x256_with_loop_2:		equ __rs-3 ; $FFFFF7AD ; 256x256 level tile which contains a loop (GHZ/SLZ)
v_256x256_with_tunnel_1:	equ __rs-2 ; $FFFFF7AE ; 256x256 level tile which contains a roll tunnel (GHZ)
v_256x256_with_tunnel_2:	equ __rs-1 ; $FFFFF7AF ; 256x256 level tile which contains a roll tunnel (GHZ)
v_levelani_0_frame:		rs.w 1 ; $FFFFF7B0 ; level graphics animation 0 - current frame
v_levelani_0_time:		rs.w 1 ; $FFFFF7B1 ; level graphics animation 0 - time until next frame
v_levelani_1_frame:		rs.w 1 ; $FFFFF7B2 ; level graphics animation 1 - current frame
v_levelani_1_time:		rs.w 1 ; $FFFFF7B3 ; level graphics animation 1 - time until next frame
v_levelani_2_frame:		rs.w 1 ; $FFFFF7B4 ; level graphics animation 2 - current frame
v_levelani_2_time:		rs.w 1 ; $FFFFF7B5 ; level graphics animation 2 - time until next frame
v_levelani_3_frame:		rs.w 1 ; $FFFFF7B6 ; level graphics animation 3 - current frame
v_levelani_3_time:		rs.w 1 ; $FFFFF7B7 ; level graphics animation 3 - time until next frame
v_levelani_4_frame:		rs.w 1 ; $FFFFF7B8 ; level graphics animation 4 - current frame
v_levelani_4_time:		rs.w 1 ; $FFFFF7B9 ; level graphics animation 4 - time until next frame
v_levelani_5_frame:		rs.w 1 ; $FFFFF7BA ; level graphics animation 5 - current frame
v_levelani_5_time:		rs.w 1 ; $FFFFF7BB ; level graphics animation 5 - time until next frame
f_convey_reverse:		rs.b 1 ; $FFFFF7C0 ; flag set to reverse conveyor belts in LZ/SBZ
v_convey_init_list:		rs.b 6 ; $FFFFF7C1 ; LZ/SBZ conveyor belt platform flags set when the parent object is loaded - 1 byte per conveyor set
f_water_tunnel_now:		rs.b 1 ; $FFFFF7C7 ; flag set when Sonic is in a LZ water tunnel
v_lock_multi:			rs.b 1 ; $FFFFF7C8 ; +1 = lock controls, lock Sonic's position & animation; +$80 = no collision with objects
f_water_tunnel_disable:		rs.b 1 ; $FFFFF7C9 ; flag set to disable LZ water tunnels
f_jump_only:			rs.b 1 ; $FFFFF7CA ; flag set to lock controls except jumping
f_stomp_sbz3_init:		rs.b 1 ; $FFFFF7CB ; flag set when huge sliding platform in SBZ3 is loaded
f_lock_controls:		rs.b 1 ; $FFFFF7CC ; flag set to lock player controls
f_giantring_collected:		rs.b 1 ; $FFFFF7CD ; flag set when Sonic collects a giant ring
f_fblock_finish:		rs.b 1 ; $FFFFF7CE ; flag set when FloatingBlock subtype $37 reaches its destination (REV01 only)
v_enemy_combo:			rs.w 1 ; $FFFFF7D0 ; number of enemies/blocks broken in a row, times 2
v_time_bonus:			rs.w 1 ; $FFFFF7D2 ; time bonus at the end of an act
v_ring_bonus:			rs.w 1 ; $FFFFF7D4 ; ring bonus at the end of an act
f_pass_bonus_update:		rs.b 1 ; $FFFFF7D6 ; flag set to update time/ring bonus at the end of an act
v_end_sonic_routine:		rs.b 1 ; $FFFFF7D7 ; routine counter for Sonic in the ending sequence
v_water_ripple_y_pos:		rs.w 1 ; $FFFFF7D8 ; y position of bg/fg water ripple effects; $80 added every frame, meaning high byte increments every 2 frames
v_button_state:			rs.b $10 ; $FFFFF7E0 ; flags set when Sonic stands on a button
v_scroll_block_1_height:	rs.w 4 ; $FFFFF7F0 ; scroll block height - $70 for GHZ; $800 for all others
v_scroll_block_2_height:	equ __rs-6 ; $FFFFF7F2 ; scroll block height - always $100, unused
v_scroll_block_3_height:	equ __rs-4 ; $FFFFF7F4 ; scroll block height - always $100, unused
v_scroll_block_4_height:	equ __rs-2 ; $FFFFF7F6 ; scroll block height - $100 for GHZ; 0 for all others, unused
v_slzboss_seesaws:		rs.w 3 ; OST addresses of 3 seesaws at SLZ boss
				rsblockend levelinfo

				rsblock sprites
v_sprite_buffer:		rs.b sizeof_vram_sprites ; $FFFFF800 ; sprite table ($280 bytes)
				rsblockend sprites
				rsblock pal
v_pal_dry:			rs.w countof_color*4 ; $FFFFFB00 ; main palette
				rsblockend pal
v_pal_dry_line1:		equ v_pal_dry
v_pal_dry_line2:		equ v_pal_dry+sizeof_pal ; $FFFFFB20 ; 2nd palette line
v_pal_dry_line3:		equ v_pal_dry+(sizeof_pal*2) ; $FFFFFB40 ; 3rd palette line
v_pal_dry_line4:		equ v_pal_dry+(sizeof_pal*3) ; $FFFFFB60 ; 4th palette line
v_pal_water:			rs.w countof_color*4 ; $FFFFFA80 ; main underwater palette
v_pal_water_line1:		equ v_pal_water
v_pal_water_line2:		equ v_pal_water+sizeof_pal ; $FFFFFAA0 ; 2nd palette line
v_pal_water_line3:		equ v_pal_water+(sizeof_pal*2) ; $FFFFFAC0 ; 3rd palette line
v_pal_water_line4:		equ v_pal_water+(sizeof_pal*3) ; $FFFFFAE0 ; 4th palette line
v_pal_dry_final:		rs.w countof_color*countof_pal ; main palette after brightness change
v_pal_water_final:		rs.w countof_color*countof_pal ; underwater palette after brightness change
				rsalign 2
v_respawn_list:			rs.b $100 ; $FFFFFC00 ; object state list (2 bytes for counter; 1 byte each for up to $FE objects)

				rsalign 4
v_stack:			rs.l $40 ; $FFFFFD00 ; stack ($100 bytes)
v_stack_pointer:		rs.w 1 ; $FFFFFE00 ; initial stack pointer - items are added to the stack backwards from this address

v_keep_after_reset:		equ v_stack_pointer ; $FFFFFE00 ; everything after this address is kept in RAM after a soft reset

f_restart:			rs.w 1 ; $FFFFFE02 ; flag set to end/restart level
v_frame_counter:		rs.w 1 ; $FFFFFE04 ; frame counter, increments every frame
v_frame_counter_low:		equ __rs-1 ; $FFFFFE05 ; low byte for frame counter
v_debug_item_index:		rs.b 1 ; $FFFFFE06 ; debug item currently selected (NOT the object id of the item)
v_debug_active:			rs.w 1 ; $FFFFFE08 ; xx01 when debug mode is in use and Sonic is an item; 0 otherwise
v_debug_active_hi:		equ v_debug_active ; high byte of v_debug_active, routine counter for DebugMode (00/02)
v_debug_move_delay:		rs.b 1 ; $FFFFFE0A ; debug mode - horizontal speed
v_debug_move_speed:		rs.b 1 ; $FFFFFE0B ; debug mode - vertical speed
v_vblank_counter:		rs.l 1 ; $FFFFFE0C ; vertical interrupt counter, increments every VBlank
v_vblank_counter_word:		equ __rs-2 ; $FFFFFE0E ; low word for v_vblank_counter
v_vblank_counter_byte:		equ __rs-1 ; $FFFFFE0F ; low byte for v_vblank_counter
v_character1:			rs.w 1 ; player 1 character id
v_character2:			rs.w 1 ; player 2 character id
v_player1_ptr:			rs.l 1 ; player 1 object pointer
v_player2_ptr:			rs.l 1 ; player 2 object pointer
v_player1_width:		rs.b 1 ; player 1 half width, standing/running etc.
v_player1_height:		rs.b 1 ; player 1 half height, standing/running etc.
v_player1_width_roll:		rs.b 1 ; player 1 half width, rolling/jumping
v_player1_height_roll:		rs.b 1 ; player 1 half height, rolling/jumping
v_player1_height_diff:		rs.w 1 ; player 1 difference in height between standing and rolling
v_haspassed_character:		rs.w 1 ; mappings frame used for "Sonic has passed"
v_zone:				rs.w 1 ; $FFFFFE10 ; current zone number
v_act:				equ __rs-1 ; $FFFFFE11 ; current act number
v_zone_next:			rs.w 1 ; next zone number
v_act_next:			equ __rs-1 ; next act number
v_lives:			rs.b 1 ; $FFFFFE12 ; number of lives
v_air:				rs.w 1 ; $FFFFFE14 ; air remaining while underwater (2 bytes)
v_last_ss_levelid:		rs.b 1 ; $FFFFFE16 ; level id of most recent special stage played
v_continues:			rs.b 1 ; $FFFFFE18 ; number of continues
f_time_over:			rs.b 1 ; $FFFFFE1A ; time over flag
v_ring_reward:			rs.b 1 ; $FFFFFE1B ; tracks which rewards have been given for rings - bit 0 = 50 rings (Special Stage); bit 1 = 100 rings; bit 2 = 200 rings
f_hud_lives_update:		rs.b 1 ; $FFFFFE1C ; lives counter update flag
v_hud_rings_update:		rs.b 1 ; $FFFFFE1D ; ring counter update flag - 1 = general update; $80 = reset to 0
f_hud_time_update:		rs.b 1 ; $FFFFFE1E ; time counter update flag
f_hud_score_update:		rs.b 1 ; $FFFFFE1F ; score counter update flag
v_rings:			rs.w 1 ; $FFFFFE20 ; rings
v_time:				rs.l 1 ; $FFFFFE22 ; time
v_time_min:			equ __rs-3 ; $FFFFFE23 ; time - minutes
v_time_sec:			equ __rs-2 ; $FFFFFE24 ; time - seconds
v_time_frames:			equ __rs-1 ; $FFFFFE25 ; time - frames
v_score:			rs.l 1 ; $FFFFFE26 ; score
v_shield:			rs.b 1 ; $FFFFFE2C ; shield status - 00 = no; 01 = yes
v_invincibility:		rs.b 1 ; $FFFFFE2D ; invinciblity status - 00 = no; 01 = yes
v_shoes:			rs.b 1 ; $FFFFFE2E ; speed shoes status - 00 = no; 01 = yes

				rsblock lamppost ; written to as a block by GM_Credits
v_last_lamppost:		rs.b 1 ; $FFFFFE30 ; id of the last lamppost you hit

; Lamppost copied variables:

v_last_lamppost_lampcopy:	rs.b 1 ; $FFFFFE31 ; lamppost copy of v_last_lamppost
v_sonic_x_pos_lampcopy:		rs.w 1 ; $FFFFFE32 ; lamppost copy of Sonic's x position
v_sonic_y_pos_lampcopy:		rs.w 1 ; $FFFFFE34 ; lamppost copy of Sonic's y position
v_rings_lampcopy:		rs.w 1 ; $FFFFFE36 ; lamppost copy of v_rings
v_time_lampcopy:		rs.l 1 ; $FFFFFE38 ; lamppost copy of v_time
v_dle_routine_lampcopy:		rs.w 1 ; $FFFFFE3C ; lamppost copy of v_dle_routine
v_boundary_bottom_lampcopy:	rs.w 1 ; $FFFFFE3E ; lamppost copy of v_boundary_bottom
v_camera_x_pos_lampcopy:	rs.w 1 ; $FFFFFE40 ; lamppost copy of v_camera_x_pos
v_camera_y_pos_lampcopy:	rs.w 1 ; $FFFFFE42 ; lamppost copy of v_camera_y_pos
v_bg1_x_pos_lampcopy:		rs.w 1 ; $FFFFFE44 ; lamppost copy of v_bg1_x_pos
v_bg1_y_pos_lampcopy:		rs.w 1 ; $FFFFFE46 ; lamppost copy of v_bg1_y_pos
v_bg2_x_pos_lampcopy:		rs.w 1 ; $FFFFFE48 ; lamppost copy of v_bg2_x_pos
v_bg2_y_pos_lampcopy:		rs.w 1 ; $FFFFFE4A ; lamppost copy of v_bg2_y_pos
v_bg3_x_pos_lampcopy:		rs.w 1 ; $FFFFFE4C ; lamppost copy of v_bg3_x_pos
v_bg3_y_pos_lampcopy:		rs.w 1 ; $FFFFFE4E ; lamppost copy of v_bg3_y_pos
v_water_height_normal_lampcopy:	rs.w 1 ; $FFFFFE50 ; lamppost copy of v_water_height_normal
v_water_routine_lampcopy:	rs.b 1 ; $FFFFFE52 ; lamppost copy of v_water_routine
f_water_pal_full_lampcopy:	rs.b 1 ; $FFFFFE53 ; lamppost copy of f_water_pal_full
				rsblockend lamppost
v_ring_reward_lampcopy:		rs.b 1 ; $FFFFFE54 ; lamppost copy of v_ring_reward

v_emeralds:			rs.l 1 ; $FFFFFE57 ; number of chaos emeralds
v_oscillating_direction:	rs.w 1 ; $FFFFFE5E ; bitfield for the direction values in the table below are moving - 0 = up; 1 = down

				rsblock synctables ; $FE60-$FEFF cleared by GM_Special
				rsblock synctables2 ; $FE60-$FF7F cleared by GM_Level, GM_Ending
v_oscillating_table:		rs.l $10 ; $FFFFFE60 ; table of 16 oscillating values, for platform movement - 1 word for current value, 1 word for rate
v_oscillating_0_to_20:		equ v_oscillating_table
v_oscillating_0_to_30:		equ v_oscillating_table+4
v_oscillating_0_to_40:		equ v_oscillating_table+8
v_oscillating_0_to_60:		equ v_oscillating_table+$C
v_oscillating_0_to_40_fast:	equ v_oscillating_table+$10
v_oscillating_0_to_10:		equ v_oscillating_table+$14
v_oscillating_0_to_80_fast:	equ v_oscillating_table+$18
v_oscillating_0_to_80:		equ v_oscillating_table+$1C
v_oscillating_0_to_A0:		equ v_oscillating_table+$20
v_oscillating_0_to_A0_alt:	equ v_oscillating_table+$24
v_oscillating_0_to_40_alt:	equ v_oscillating_table+$28
v_oscillating_0_to_60_alt:	equ v_oscillating_table+$2C
v_oscillating_0_to_A0_fast:	equ v_oscillating_table+$30
v_oscillating_0_to_E0:		equ v_oscillating_table+$34
v_syncani_0_time:		rs.b 1 ; $FFFFFEC0 ; synchronised sprite animation 0 - time until next frame
v_syncani_0_frame:		rs.b 1 ; $FFFFFEC1 ; synchronised sprite animation 0 - current frame
v_syncani_1_time:		rs.b 1 ; $FFFFFEC2 ; synchronised sprite animation 1 - time until next frame
v_syncani_1_frame:		rs.b 1 ; $FFFFFEC3 ; synchronised sprite animation 1 - current frame
v_syncani_2_time:		rs.b 1 ; $FFFFFEC4 ; synchronised sprite animation 2 - time until next frame
v_syncani_2_frame:		rs.b 1 ; $FFFFFEC5 ; synchronised sprite animation 2 - current frame
v_syncani_3_time:		rs.b 1 ; $FFFFFEC6 ; synchronised sprite animation 3 - time until next frame
v_syncani_3_frame:		rs.b 1 ; $FFFFFEC7 ; synchronised sprite animation 3 - current frame
v_syncani_3_accumulator:	rs.w 1 ; $FFFFFEC8 ; synchronised sprite animation 3 - v_syncani_3_time added to this value every frame
v_boundary_top_debugcopy:	rs.w 1 ; $FFFFFEF0 ; top level boundary, buffered while debug mode is in use
v_boundary_bottom_debugcopy:	rs.w 1 ; $FFFFFEF2 ; bottom level boundary, buffered while debug mode is in use
				rsblockend synctables

; Variables copied during VBlank and used by DrawTilesWhenMoving:

v_camera_x_pos_copy:		rs.l 8 ; $FFFFFF10 ; copy of v_camera_x_pos
v_camera_y_pos_copy:		equ __rs-$1C ; $FFFFFF14 ; copy of v_camera_y_pos
v_bg1_x_pos_copy:		equ __rs-$18 ; $FFFFFF18 ; copy of v_bg1_x_pos
v_bg1_y_pos_copy:		equ __rs-$14 ; $FFFFFF1C ; copy of v_bg1_y_pos
v_bg2_x_pos_copy:		equ __rs-$10 ; $FFFFFF20 ; copy of v_bg2_x_pos
v_bg2_y_pos_copy:		equ __rs-$C ; $FFFFFF24 ; copy of v_bg2_y_pos
v_bg3_x_pos_copy:		equ __rs-8 ; $FFFFFF28 ; copy of v_bg3_x_pos
v_bg3_y_pos_copy:		equ __rs-4 ; $FFFFFF2C ; copy of v_bg3_y_pos
v_fg_redraw_direction_copy:	rs.w 4 ; $FFFFFF30 ; copy of v_fg_redraw_direction
v_bg1_redraw_direction_copy:	equ __rs-6 ; $FFFFFF32 ; copy of v_bg1_redraw_direction
v_bg2_redraw_direction_copy:	equ __rs-4 ; $FFFFFF34 ; copy of v_bg2_redraw_direction
v_bg3_redraw_direction_copy:	equ __rs-2 ; $FFFFFF36 ; copy of v_bg3_redraw_direction
				rsblockend synctables2

v_levelselect_hold_delay:	rs.w 1 ; $FFFFFF80 ; level select - time until change when up/down is held
v_levelselect_item:		rs.w 1 ; $FFFFFF82 ; level select - item selected
v_levelselect_sound:		rs.w 1 ; $FFFFFF84 ; level select - sound selected
v_highscore:			rs.l 1 ; $FFFFFFC0 ; highest score so far (REV00 only)
v_score_next_life:		equ v_highscore	; points required for next extra life (REV01 only)
f_levelselect_cheat:		rs.l 1 ; $FFFFFFE0 ; flag set when level select cheat has been entered
f_slowmotion_cheat:		equ __rs-3 ; $FFFFFFE1 ; flag set when slow motion & frame advance cheat has been entered
f_debug_cheat:			equ __rs-2 ; $FFFFFFE2 ; flag set when debug mode cheat has been entered
f_credits_cheat:		equ __rs-1 ; $FFFFFFE3 ; flag set when hidden credits & press start cheat has been entered
v_title_d_count:		rs.w 1 ; $FFFFFFE4 ; number of times the d-pad is pressed on title screen, but only in the order UDLR
v_demo_mode:			rs.w 1 ; $FFFFFFF0 ; demo mode flag - 0 = no; 1 = yes; $8001 = ending
v_demo_num:			rs.w 1 ; $FFFFFFF2 ; demo level number (not the same as the level number)
v_demo_ptr:			rs.l 1 ; pointer for demo data
v_demo_x_start:			rs.l 1 ; Sonic's starting x pos
v_demo_y_start:			equ __rs-2 ; Sonic's starting y pos
v_brightness:			rs.w 1 ; 0 = normal; -15 = black; 15 = white
f_brightness_update:		rs.b 1 ; flag set to update brightness
v_credits_num:			rs.w 1 ; $FFFFFFF4 ; credits index number
f_credits_started:		rs.b 1 ; flag set when credits have started
v_console_region:		rs.b 1 ; $FFFFFFF8 ; Mega Drive console type - 0 = JP; $80 = US/EU; +0 = NTSC; +$40 = PAL
f_debug_enable:			rs.w 1 ; $FFFFFFFA ; flag set when debug mode is enabled (high byte is set to 1, but it's read as a word)
v_checksum_pass:		rs.l 1 ; $FFFFFFFC ; set to the text string "init" when checksum is passed

; Show RAM usage and stop compilation if it overflows.

ram_used:			equ __rs
ram_final:			equ (ram_used-1)&$FFFF
		if ram_used > 0
		inform	3,"RAM usage exceeds maximum by $%h bytes.",ram_used
		else
		inform	0,"0-$%h bytes of RAM used with $%h bytes to spare.",ram_final,$FFFF-ram_final
		endc

; Special Stages

				rsset $FF0000
				rsblock sslayout
v_ss_layout:			rs.b $4000 ; special stage layout with space added to top and sides
				rsblockend sslayout
v_ss_layout_start:		equ v_ss_layout+sizeof_ss_padding_top+ss_width_padding_left ; $FF1020
v_ss_layout_buffer:		rs.b $1000 ; unprocessed special stage layout - overwritten later ($1000 bytes)
				rsset $FF4000
v_ss_sprite_info:		rs.b $278 ; sprite info for each item type - mappings pointer (4 bytes); frame id (2 bytes); tile id (2 bytes) (total $278 bytes)
				rsblock ssupdate
v_ss_sprite_update_list:	rs.b $100 ; list of items currently being updated - 8 bytes each ($100 bytes)
				rsblockend ssupdate
v_ss_sprite_grid_plot:		rs.b $400 ; x/y positions of cells in a 16x16 grid centered around Sonic, updates as it rotates ($400 bytes)
				rsblock ssbgpos
v_ss_bubble_x_pos:		rs.b $16 ; x position of background bubbles
v_ss_cloud_x_pos:		rs.b $1C ; x position of background clouds - 4 bytes per block, 7 blocks ($1C bytes)
				rsblockend ssbgpos

		popo		; restore options
