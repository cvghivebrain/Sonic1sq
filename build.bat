@echo off

rem assemble Z80 sound driver
axm68k /m /k /p "sound\DAC Driver.asm", "sound\DAC Driver.unc" >"sound\errors.txt", , "sound\DAC Driver.lst"
type "sound\errors.txt"
IF NOT EXIST "sound\DAC Driver.unc" PAUSE & EXIT 2

rem compress kosinski files
for %%f in ("256x256 Mappings\*.unc") do "mdcomp\koscmp" "%%f" "256x256 Mappings\%%~nf.kos"
"mdcomp\koscmp" "sound\DAC Driver.unc" "sound\DAC Driver.kos"

rem assemble final rom
IF EXIST s1built.bin move /Y s1built.bin s1built.prev.bin >NUL
axm68k /m /k /p sonic.asm, s1built.bin >errors.txt, sonic1.sym, sonic.lst
type errors.txt

IF NOT EXIST s1built.bin PAUSE & EXIT 2
ConvSym sonic1.sym sonic1.symcmp
copy /b s1built.bin+sonic1.symcmp s1built.bin /y

fixheadr.exe s1built.bin
exit 0
