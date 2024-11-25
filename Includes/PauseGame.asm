; ---------------------------------------------------------------------------
; Subroutine to	pause the game
; ---------------------------------------------------------------------------

PauseGame:
		nop
		tst.b	(f_pause).w
		bne.s	.paused					; branch if already paused
		btst	#bitStart,(v_joypad_press_actual).w
		bne.s	.pause_now				; branch if Start is pressed
		rts

	.pause_now:
		move.b	#1,(f_pause).w				; set pause flag (also stops palette/gfx animations, time)
		
	.paused:
		move.b	#1,(v_snddriver_ram+f_pause_sound).w	; pause music

Pause_Loop:
		move.b	#id_VBlank_Pause,(v_vblank_routine).w
		bsr.w	WaitForVBlank_Paused			; wait for next frame
		move.b	(v_joypad_press_actual).w,d0		; read joypad presses
		tst.b	(f_debug_cheat).w
		beq.s	.chk_start				; branch if debug mode is off
		
		btst	#bitA,d0				; is button A pressed?
		beq.s	.chk_bc					; if not, branch

		move.b	#id_Title,(v_gamemode).w		; set game mode to 4 (title screen)
		nop	
		bra.s	Unpause
; ===========================================================================

	.chk_bc:
		btst	#bitB,(v_joypad_hold_actual).w		; is button B held?
		bne.s	Pause_SlowMo				; if yes, branch
		btst	#bitC,d0				; is button C pressed?
		bne.s	Pause_SlowMo				; if yes, branch
		btst	#bitM,(v_joypad_press_actual_xyz).w	; is Mode pressed?
		bne.s	Pause_Debug				; if yes, branch

	.chk_start:
		btst	#bitStart,d0				; is Start button pressed?
		beq.s	Pause_Loop				; if not, branch

Unpause:
		clr.b	(f_pause).w				; unpause the game
		move.b	#$80,(v_snddriver_ram+f_pause_sound).w	; unpause the music
		rts	

; ---------------------------------------------------------------------------
; Run the game for 1 frame and immediately pause again
; ---------------------------------------------------------------------------

Pause_SlowMo:
		move.b	#$80,(v_snddriver_ram+f_pause_sound).w	; unpause the music
		move.b	#$81,(f_pause).w			; set slow motion flag
		rts	

; ---------------------------------------------------------------------------
; Pause debug menu
; ---------------------------------------------------------------------------

Pause_Debug:
		bsr.w	ClearVRAM_Tiles				; clear fg/bg
		bsr.w	ClearVRAM_HScroll			; clear hscroll table
		bsr.w	ClearRAM_Sprites			; clear sprites
		clr.w	(v_fg_y_pos_vsram).w
		moveq	#id_UPLC_PauseDebug,d0
		jsr	UncPLC					; load debug text gfx on top of HUD gfx
		move.w	#cYellow,(v_pal_dry_line2+12).w		; replace white with yellow in palette line 2
		
Pause_Debug_Main:
		clr.w	(v_debugmenu_item).w			; highlight first object in list
		moveq	#1,d0					; x pos
		moveq	#1,d1					; y pos
		moveq	#0,d2					; tile setting
		lea	(vdp_data_port).l,a1			; data port
		lea	Str_DebugMenu(pc),a2			; address of string
		bsr.w	DrawString
		addq.b	#2,d1
		lea	Str_DebugBtns(pc),a2
		bsr.w	DrawString
		bsr.w	Pause_Debug_DrawMain
		
	Pause_Debug_Loop:
		move.b	#id_VBlank_PauseDebug,(v_vblank_routine).w
		bsr.w	WaitForVBlank_Paused			; wait for next frame
		btst	#bitM,(v_joypad_press_actual_xyz).w
		bne.s	Pause_Debug_Exit			; branch if Mode is pressed
		lea	(v_debugmenu_item).w,a1
		btst	#bitC,(v_joypad_press_actual).w
		beq.s	.not_c					; branch if C isn't pressed
		cmpi.w	#0,(a1)
		beq.s	Pause_Debug_Obj				; branch if object viewer is selected
		
	.not_c:
		moveq	#3,d0					; number of items in menu
		moveq	#3,d1					; number of items per column
		bsr.w	NavigateMenu				; read control inputs
		beq.s	Pause_Debug_Loop			; branch if no inputs
		bsr.w	Pause_Debug_DrawMain			; redraw menu
		bra.s	Pause_Debug_Loop		

Pause_Debug_Exit:
		moveq	#id_UPLC_HUD,d0
		jsr	UncPLC					; load HUD gfx
		jsr	DrawTilesAtStart			; redraw bg/fg
		bsr.w	ExecuteObjects_DisplayOnly		; read all objects for display
		bsr.w	BuildSprites				; redraw sprites
		move.w	#cWhite,(v_pal_dry_line2+12).w
		move.w	(v_camera_y_pos).w,(v_fg_y_pos_vsram).w
		bra.w	Pause_Loop				; return to regular pause

; ---------------------------------------------------------------------------
; Pause debug menu - object selector
; ---------------------------------------------------------------------------

Pause_Debug_Obj:
		clr.w	(v_debugmenu_item).w			; highlight first object in list
		
Pause_Debug_Obj_KeepPos:
		bsr.w	ClearVRAM_Tiles_FG			; clear fg
		moveq	#1,d0					; x pos
		moveq	#1,d1					; y pos
		moveq	#0,d2					; tile setting
		lea	(vdp_data_port).l,a1			; data port
		lea	Str_ObjMenu(pc),a2			; address of string
		bsr.w	DrawString
		addq.b	#2,d1
		lea	Str_ObjBtns(pc),a2
		bsr.w	DrawString
		bsr.w	Pause_Debug_DrawObj
		
	Pause_Debug_Obj_Loop:
		move.b	#id_VBlank_PauseDebug,(v_vblank_routine).w
		bsr.w	WaitForVBlank_Paused			; wait for next frame
		btst	#bitM,(v_joypad_press_actual_xyz).w
		bne.w	Pause_Debug_Exit			; branch if Mode is pressed
		move.w	#countof_ost,d0				; number of items in menu
		moveq	#24,d1					; number of items per column
		lea	(v_debugmenu_item).w,a1
		btst	#bitA,(v_joypad_press_actual).w
		bne.s	.delete					; branch if A is pressed
		btst	#bitB,(v_joypad_press_actual).w
		bne.s	.back					; branch if B is pressed
		btst	#bitC,(v_joypad_press_actual).w
		bne.s	Pause_Debug_ObjView			; branch if C is pressed
		bsr.w	NavigateMenu				; read control inputs
		beq.s	Pause_Debug_Obj_Loop			; branch if no inputs
		bsr.w	Pause_Debug_DrawObj			; redraw menu
		bra.s	Pause_Debug_Obj_Loop
		
	.delete:
		move.w	(a1),d0
		mulu.w	#sizeof_ost,d0
		addi.w	#v_ost_all&$FFFF,d0
		move.w	d0,a0					; a0 = address of selected object
		jsr	DeleteFamilyAll				; delete object and children
		bsr.w	Pause_Debug_DrawObj			; redraw menu
		bra.s	Pause_Debug_Obj_Loop
		
	.back:
		bsr.w	ClearVRAM_Tiles_FG			; clear fg
		clr.w	(v_debugmenu_item).w			; highlight first object in list
		bra.w	Pause_Debug_Main			; return to main menu
		
Str_ObjMenu:	dc.b "OBJECT VIEWER",0
Str_ObjBtns:	dc.b "A@ DELETE  B@ BACK  C@ SELECT",0
Str_ObjBtns2:	dc.b "B@ BACK  C@ GOTO PARENT",0
		even
		
; ---------------------------------------------------------------------------
; Pause debug menu - object viewer
; ---------------------------------------------------------------------------

Pause_Debug_ObjView:
		bsr.w	ClearVRAM_Tiles_FG			; clear fg
		move.w	(v_debugmenu_item).w,d0			; get selected item num
		mulu.w	#sizeof_ost,d0
		addi.w	#v_ost_all&$FFFF,d0
		move.w	d0,a0					; a0 = address of selected object
		
		moveq	#1,d0					; x pos
		moveq	#1,d1					; y pos
		moveq	#0,d2
		lea	(vdp_data_port).l,a1			; data port
		lea	Str_ObjMenu(pc),a2			; address of string
		bsr.w	DrawString
		addq.b	#2,d1
		lea	Str_ObjBtns2(pc),a2
		bsr.w	DrawString
		addq.b	#3,d1
		lea	Str_ObjName(pc),a2
		bsr.w	DrawString
		moveq	#0,d3
		move.b	ost_name(a0),d3				; get name of object
		lsl.w	#3,d3					; multiply by 8
		lea	Str_Names,a2
		lea	(a2,d3.w),a2				; address of string in table
		bsr.w	DrawString8_SkipVDP			; draw name of object
		addq.b	#1,d1
		lea	Pause_Debug_ObjView_Script(pc),a4
		
	.loop:
		movea.l	(a4)+,a2				; get string pointer
		bsr.w	DrawString				; draw on screen
		moveq	#0,d3
		moveq	#0,d6
		move.b	(a4)+,d3				; get OST variable offset
		move.b	(a4)+,d6				; get length
		tst.b	d3
		bmi.s	.special				; branch if not an offset
		move.b	(a0,d3.w),d5				; read byte
		cmpi.b	#2,d6
		beq.s	.readok					; branch if 2 digits (1 byte) should be read
		move.l	(a0,d3.w),d5				; read longword
		cmpi.b	#6,d6
		bcc.s	.readok					; branch if 6-8 digits (4 bytes) should be read
		swap	d5					; read word
		
	.readok:
		bsr.w	DrawHexString_SkipVDP			; draw hex value
		add.b	(a4)+,d1				; get line break
		move.b	(a4)+,d3				; get flags
		bmi.w	Pause_Debug_ObjView_Loop		; branch if high bit is set
		btst	#0,d3
		beq.s	.loop					; branch if bit 0 is clear
		moveq	#21,d0					; x pos (second column)
		moveq	#6,d1					; y pos
		bra.s	.loop
		
	.special:
		addq.b	#1,d3
		bmi.s	.special2				; branch if not -1
		move.w	a0,d5
		bra.s	.readok
		
	.special2:
		moveq	#0,d5
		lea	(v_ost_all).w,a3			; address of first OST
		move.w	a0,d4					; address of selected OST
		
	.childloop:
		cmp.w	ost_parent(a3),d4
		bne.s	.childnext				; branch if object isn't a child of selected object
		addq.w	#1,d5					; increment child counter
		
	.childnext:
		lea	sizeof_ost(a3),a3			; goto next OST slot
		cmpa.w	#v_ost_end&$FFFF,a3
		bne.s	.childloop				; repeat if not at end of OSTs
		bra.s	.readok
		
show_ost:	macro str,ost,len,line,flags
		dc.l str
		dc.b ost,len,line,flags
		endm
		
Pause_Debug_ObjView_Script:
		show_ost Str_ObjPtr,ost_id,6,2,0
		show_ost Str_ObjMap,ost_mappings,6,1,0
		show_ost Str_ObjTile,ost_tile,4,1,0
		show_ost Str_ObjFrame,ost_frame_hi,4,1,0
		show_ost Str_ObjAnim,ost_anim,2,1,0
		show_ost Str_ObjAnim2,ost_anim_frame,2,1,0
		show_ost Str_ObjAnim3,ost_anim_time,2,1,0
		show_ost Str_ObjSubsp,ost_subsprite,4,1,0
		show_ost Str_ObjPri,ost_priority,4,1,0
		show_ost Str_ObjDispw,ost_displaywidth_hi,4,1,0
		show_ost Str_ObjRender,ost_render,2,2,0
		show_ost Str_ObjX,ost_x_pos,8,1,0
		show_ost Str_ObjY,ost_y_pos,8,1,0
		show_ost Str_ObjXvel,ost_x_vel,4,1,0
		show_ost Str_ObjYvel,ost_y_vel,4,1,0
		show_ost Str_ObjInertia,ost_inertia,4,1,0
		show_ost Str_ObjAngle,ost_angle,4,0,1		; new column after this
		
		show_ost Str_ObjRout,ost_routine,2,1,0
		show_ost Str_ObjMode,ost_mode,2,1,0
		show_ost Str_ObjStatus,ost_status,2,1,0
		show_ost Str_ObjRespawn,ost_respawn,2,1,0
		show_ost Str_ObjType,ost_subtype,2,2,0
		show_ost Str_ObjW,ost_width_hi,4,1,0
		show_ost Str_ObjH,ost_height_hi,4,1,0
		show_ost Str_ObjCol,ost_col_type,4,1,0
		show_ost Str_ObjColw,ost_col_width,2,1,0
		show_ost Str_ObjColh,ost_col_height,2,2,0
		show_ost Str_ObjSlot,-1,4,1,0			; -1 reads OST slot address
		show_ost Str_ObjParent,ost_parent,4,1,0
		show_ost Str_ObjLinked,ost_linked,4,1,0
		show_ost Str_ObjChild,-2,2,1,$80		; -2 reads child count; $80 for last item in list
		
	Pause_Debug_ObjView_Loop:
		move.b	#id_VBlank_PauseDebug,(v_vblank_routine).w
		bsr.w	WaitForVBlank_Paused			; wait for next frame
		btst	#bitM,(v_joypad_press_actual_xyz).w
		bne.w	Pause_Debug_Exit			; branch if Mode is pressed
		btst	#bitB,(v_joypad_press_actual).w
		bne.s	.back					; branch if B is pressed
		btst	#bitC,(v_joypad_press_actual).w
		bne.s	.parent					; branch if C is pressed
		bra.s	Pause_Debug_ObjView_Loop
		
	.back:
		bra.w	Pause_Debug_Obj_KeepPos
		
	.parent:
		move.w	ost_parent(a0),d0
		beq.s	Pause_Debug_ObjView_Loop		; branch if no parent set
		subi.w	#v_ost_all&$FFFF,d0
		divu.w	#sizeof_ost,d0				; get OST number for parent
		move.w	d0,(v_debugmenu_item).w			; goto parent next
		bra.w	Pause_Debug_ObjView			; redraw screen
		
Str_ObjName:	dc.b "NAME@ ",0
Str_ObjPtr:	dc.b "POINTER@ ",0
Str_ObjMap:	dc.b "MAPPINGS@ ",0
Str_ObjTile:	dc.b "TILE@ ",0
Str_ObjFrame:	dc.b "FRAME@ ",0
Str_ObjAnim:	dc.b "ANIM ID@ ",0
Str_ObjAnim2:	dc.b "ANIM FRAME@ ",0
Str_ObjAnim3:	dc.b "ANIM TIME@ ",0
Str_ObjSubsp:	dc.b "SUBSPRITES@ ",0
Str_ObjPri:	dc.b "PRIORITY@ ",0
Str_ObjDispw:	dc.b "DISP WIDTH@ ",0
Str_ObjRender:	dc.b "RENDER@ ",0
Str_ObjX:	dc.b "X POS@ ",0
Str_ObjY:	dc.b "Y POS@ ",0
Str_ObjXvel:	dc.b "X VEL@ ",0
Str_ObjYvel:	dc.b "Y VEL@ ",0
Str_ObjInertia:	dc.b "INERTIA@ ",0
Str_ObjAngle:	dc.b "ANGLE@ ",0
Str_ObjRout:	dc.b "ROUTINE@ ",0
Str_ObjMode:	dc.b "MODE@ ",0
Str_ObjStatus:	dc.b "STATUS@ ",0
Str_ObjRespawn:	dc.b "RESPAWN@ ",0
Str_ObjType:	dc.b "TYPE@ ",0
Str_ObjW:	dc.b "WIDTH@ ",0
Str_ObjH:	dc.b "HEIGHT@ ",0
Str_ObjCol:	dc.b "COL TYPE@ ",0
Str_ObjColw:	dc.b "COL WIDTH@ ",0
Str_ObjColh:	dc.b "COL HEIGHT@ ",0
Str_ObjSlot:	dc.b "SLOT@ ",0
Str_ObjParent:	dc.b "PARENT@ ",0
Str_ObjLinked:	dc.b "LINKED@ ",0
Str_ObjChild:	dc.b "CHILDREN@ ",0
		even
		
; ---------------------------------------------------------------------------
; Draw main menu
; ---------------------------------------------------------------------------

Pause_Debug_DrawMain:
		moveq	#1,d0					; x pos
		moveq	#6,d1					; y pos
		moveq	#0,d5
		moveq	#3-1,d6					; number of lines
		lea	Str_Main1(pc),a2			; address of string
		lea	(vdp_data_port).l,a1			; data port
		
	.loop:
		moveq	#0,d2
		cmp.w	(v_debugmenu_item).w,d5
		bne.s	.no_highlight				; branch if current line shouldn't be highlighted
		move.w	#tile_pal2,d2				; use palette line 2
		
	.no_highlight:
		bsr.w	DrawString
		addq.b	#2,d1					; down 2 rows
		addq.w	#1,d5					; next line
		dbf	d6,.loop
		rts

Str_DebugMenu:	dc.b "DEBUG MENU",0
Str_DebugBtns:	dc.b "MODE@ BACK  C@ SELECT",0
Str_Main1:	dc.b "OBJECT VIEWER",0
Str_Main2:	dc.b "VRAM VIEWER",0
Str_Main3:	dc.b "SOMETHING ELSE",0
		even

; ---------------------------------------------------------------------------
; Draw object selector
; ---------------------------------------------------------------------------

Pause_Debug_DrawObj:
		moveq	#0,d0					; x pos
		moveq	#4,d1					; y pos
		moveq	#0,d5
		moveq	#countof_ost-1,d6
		lea	(vdp_data_port).l,a1			; data port
		lea	(v_ost_all).w,a0
		
	.loop:
		tst.l	ost_id(a0)
		bne.s	.obj_found				; branch if object is present
		lea	Str_None(pc),a2
		bra.s	.skip_name
		
	.obj_found:
		moveq	#0,d2
		move.b	ost_name(a0),d2				; get name of object
		lsl.w	#3,d2					; multiply by 8
		lea	Str_Names(pc,d2.w),a2			; address of string in table
		
	.skip_name:
		moveq	#0,d2
		cmp.w	(v_debugmenu_item).w,d5
		bne.s	.no_highlight				; branch if current line shouldn't be highlighted
		move.w	#tile_pal2,d2				; use palette line 2
		
	.no_highlight:
		bsr.w	DrawString8
		addq.b	#1,d1					; down 1 row
		addq.w	#1,d5					; next line
		move.w	d5,d2
		beq.s	.no_wrap
		divu.w	#24,d2
		swap	d2
		tst.w	d2
		bne.s	.no_wrap				; branch if d5 isn't a multiple of 24
		addq.b	#8,d0					; next column
		moveq	#4,d1					; return to top
		
	.no_wrap:
		lea	sizeof_ost(a0),a0			; next object
		dbf	d6,.loop
		rts

Str_None:	dc.b "[       "
