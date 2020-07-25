@echo off
setlocal

REM VARIABLES ------------------------
REM Time at which it finishes:
set endH=[INSERT HOUR HERE]
set endM=[INSERT MINUTE HERE]
REM Output path specified in Blender:
set renderpath=[INSERT TARGET PATH HERE]
REM Number of frames to be rendered:
set totalframes=[INSERT NUMBER OF FRAMES TO BE RENDERED HERE]
REM -----------------------------------

title RenderCountdown

:synchronize
for /F "tokens=1,2 delims=:" %%a in ("%time%") do set /A "minutes=(endH*60+endM)-(%%a*60+1%%b-100)-1, seconds=159, hours=(minutes/60), variable=(minutes-hours*60)"

:wait
setlocal enableextensions
set count=0
for %%x in (%renderpath%\*.png) do set /a count+=1
set /a percentage=%count% * 100 / %totalframes%
timeout /T 1 /NOBREAK > NUL
echo %count% / %totalframes% frames rendered (%percentage% %%)
endlocal
echo Time remaining:  %hours%h %variable%min %seconds:~-2%s
set /A seconds-=1
if %seconds% geq 100 goto wait
set /A minutes-=1, seconds=159, minMOD5=minutes %% 5
if %minutes% lss 0 goto :buzz
if %minMOD5% equ 0 goto synchronize
goto wait

:buzz
pause
