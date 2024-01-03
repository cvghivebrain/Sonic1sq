# Sonic 1-squared

_Sonic 1-squared_ is an enhanced version of the original _Sonic the Hedgehog_ game engine. Various changes are planned to make editing the game easier.

# Features
* The player's Chaos Emerald count is stored as a bitfield instead of a list. It's a longword, so there can be up to 32 Emeralds.
* `LoadPerZone` subroutine consolidates all pointers and parameters for zones and acts. This simplifies the process of adding levels. (incomplete)
* `LoadPerCharacter` subroutine does the same for the Sonic object, palette and life icon, allowing for extra characters.
* `LoadPerDemo` loads the level number, demo data, character and start position for all demos, including those during the credits.
* Rewritten level select routine to be more customisable. It now uses standard ASCII, and supports multiple columns (which are automatically generated based on the lines-per-column setting).
* The hidden Japanese credits, "try again" and "end" screens have been given their own gamemodes, which are accessible through the level select.
* The HUD has new debug features, including a CPU cycle usage counter (displayed as a decimal percentage), sprite counter ($50 is max) and camera x/y position.
* 6 button support. `v_joypad_hold_actual_xyz` contains the status of the X/Y/Z/Mode buttons.

## Graphics
* `KosPLC` subroutine loads Kosinski-compressed graphics at the beginning of a level.
* `UncPLC` subroutine load uncompressed graphics at any time. This complements `KosPLC` by loading graphics during a level. Both this and `KosPLC` use the DMA queue.
* DMA queue system for loading uncompressed graphics.
* Animated level graphics use a script instead of being hard-coded. The exception is Marble Zone's magma, which works somewhat differently to other animations.
* Palette cycling uses a script.
* Water palettes are generated in-game by the `WaterFilter` subroutine, instead of being hardcoded.
* Fading to black/white is controlled by a brightness variable, and no longer requires a "next" palette. This simplifies loading new palettes.

## Objects
* Modified the way animation works to save 2 bytes in RAM per object. The high bit of `ost_anim` now serves as an update flag instead of `ost_anim_restart`.
* Object scratch RAM is assigned automatically with `rsobj` macro. If you attempt to use more RAM than is available ($40 bytes), assembly will fail.
* `ost_id` is now a longword pointer instead of a single byte (as is the case in _Sonic 3 & Knuckles_). This allows for unlimited object types, and slightly improves performance.
* `ost_frame` extended to a word (`ost_frame_hi`), allowing objects to have up to 8,192 distinct frames of animation.
* Sprite mappings use 6 bytes per piece instead of 5, and the piece count is a word instead of a byte. This ensures the data is always aligned to even.
* `ost_parent` contains the parent object's OST address (shortened to a word), if the `saveparent` was useded when the child object was created. `getparent` will set the parent object as `a1`. Calling `DeleteFamily` will delete an object as well as any objects which have it set as their parent.
* `ost_linked` is similar to `ost_parent`. `getlinked` will set the linked object as `a1`. `DeleteFamily` won't delete linked objects.
* `ost_col_width` and `ost_col_height` set an object's hitbox for `ReactToItem` instead of using a table.
* `ost_status` now includes `status_pointy_bit` for spikes and similar objects. It causes a different sound to play when Sonic is harmed by the object.
* `ost_subsprite` contains the address of a subsprite table. Subsprites are additional sprite pieces that are not part of the object's mappings. Call `FindFreeSub` to assign a subsprite table to the current object, and `getsubsprite` to set that table as `a2`. Subsprites use the same format as sprite mappings, except the VRAM setting is absolute instead of relative to `ost_tile`.
* Monitor icons load only as needed, allowing for up to 256 unique monitor types (with a maximum of 8 loaded at any one time).
* Each title card has its own PLC, so only letters that are used need to be loaded. Title cards are automatically centered by the `autocard` macro. Title card mappings are also automated, and can use sprite mappings more efficiently by joining two letters together as a single sprite.
* GHZ/SLZ loops use an object instead of being hard-coded. The object reads Sonic's position within the loop and updates the level layout accordingly.
* Debug mode has been rewritten with more features, including info overlays for Sonic and the nearest object (similar to those in the [Sonic Physics Guide](http://info.sonicretro.org/Sonic_Physics_Guide)). The controls are as follows:
  * B - Toggle between Sonic and object.
  * C (as object) - Place an object.
  * Hold A (as object) - Select an object with left/right. The previous and next objects are now visible.
  * X - Target overlay to current nearest object. This is not automatically updated until the targeted object despawns.
  * Y - Toggle between displaying x/y position, x/y speed and angle/routine numbers.
  * Z - Toggle between displaying actual width/height and hitbox width/height.
  * Mode - Toggle hide all overlays. Overlays use approximately 5% of available CPU cycles, so hiding them provides a more accurate reading of CPU usage.

## Bugfixes
* Spikes no longer kill Sonic immediately after losing rings. Add $80 to the subtype to restore the original lethal behaviour.
* Mirrored sprites are no longer misaligned by 1 pixel. This was most obvious when pushing a wall to the left.

# Credits
* [flamewing](https://github.com/flamewing) for [mdcomp](https://github.com/flamewing/mdcomp).
* [vladikcomper](https://github.com/vladikcomper) for the advanced error handler.
* [Devon](https://github.com/Ralakimus) for the optimised CalcAngle routine.