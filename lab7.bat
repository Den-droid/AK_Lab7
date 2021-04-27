@echo off

set arg1=%lab7
tasm %arg1%.asm
pause
tlink %arg1%.obj
pause
td %arg1%.exe
pause
%arg1%.exe