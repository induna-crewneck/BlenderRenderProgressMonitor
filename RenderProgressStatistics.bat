@echo off
setlocal

REM ==== ENTER VARIABLES HERE ===============================================================================
REM Output path specified in Blender:
set renderpath=M:\blenderrender\
REM Number of frames to be rendered:
set totalframes=1935
REM File format
set extension=PNG
REM =========================================================================================================

title Render Progress Statistics

REM ==== Getting timestamp of first rendered frame ==========================================================

for /f "delims=" %%a in ('dir "%renderpath%" /o-d /b') do set oldestfile=%%a

del /s %renderpath%\tmp.txt >nul 2>&1
del /s %renderpath%\tmp2.txt >nul 2>&1

for /f "tokens=1" %%a in ('dir "%renderpath%\%oldestfile%" /t:c') do (echo %%~a>>"%renderpath%\tmp.txt")
for /f "tokens=2" %%a in ('dir "%renderpath%\%oldestfile%" /t:c') do (echo %%~a>>"%renderpath%\tmp.txt")
for /f "skip=3" %%a in ('type %renderpath%\tmp.txt') do (echo %%~a>>%renderpath%\tmp2.txt)
set /p oldestDate=< %renderpath%\tmp2.txt
del /s %renderpath%\tmp2.txt >nul 2>&1
for /f "skip=9" %%a in ('type %renderpath%\tmp.txt') do (echo %%~a>>%renderpath%\tmp2.txt)
set /p oldestTime=< %renderpath%\tmp2.txt
del /s %renderpath%\tmp.txt >nul 2>&1
del /s %renderpath%\tmp2.txt >nul 2>&1

REM ===== LOOP START =====
REM ======================

:loop

REM ==== Getting timestamp of last rendered frame ==========================================================

for /f "delims=" %%a in ('dir "%renderpath%" /od /b') do set newestfile=%%a

for /f "tokens=1" %%a in ('dir "%renderpath%\%newestfile%" /t:c') do (echo %%~a>>"%renderpath%\tmp.txt")
for /f "tokens=2" %%a in ('dir "%renderpath%\%newestfile%" /t:c') do (echo %%~a>>"%renderpath%\tmp.txt")
for /f "skip=3" %%a in ('type %renderpath%\tmp.txt') do (echo %%~a>>%renderpath%\tmp2.txt)
set /p newestDate=< %renderpath%\tmp2.txt
del %renderpath%\tmp2.txt
for /f "skip=9" %%a in ('type %renderpath%\tmp.txt') do (echo %%~a>>%renderpath%\tmp2.txt)
set /p newestTime=< %renderpath%\tmp2.txt
del %renderpath%\tmp.txt
del %renderpath%\tmp2.txt

REM ==== Calculating time passed =============================================================================

REM === Accommodating for newestTime hour being smaller than oldesttime hour ===========
set "oldestTimeReal=%OldestTime%"
set "newestTimeReal=%NewestTime%"

if %newesttime:~0,2% GEQ %oldesttime:~0,2% (goto continue)
REM Do this shit if the oldest hour is smaller than the newest hour

REM Setting the oldest and newest time relative to each other so Time Passed still works

set /a "newhourtmp=%newesttime:~0,2%+24"
set /a "newhourtmp2=%newhourtmp%-%oldesttime:~0,2%
echo %newhourtmp2%:%newesttime:~3,2%>>"%renderpath%\tmp.txt"
set /p newestTime=< %renderpath%\tmp.txt

echo 00:%oldesttime:~3,2%>>"%renderpath%\tmp2.txt"
set /p oldesttime=< %renderpath%\tmp2.txt

del %renderpath%\tmp.txt
del %renderpath%\tmp2.txt
REM === End of accommodation ============================================================

:continue

Set "Start=%oldestTime%"
Set "End=%newestTime%"
For /F "usebackqdelims=" %%A in (`
powershell -NoP -C "$TS=New-TimeSpan -Start ([datetime]'%Start%') -End ([datetime]'%End%');'{0}:{1:00}:{2:00}' -f [math]::Floor($TS.TotalHours),$TS.Minutes,$TS.Seconds"
`) Do Set "TimePassed=%%A" >nul 2>&1

Set TimePassed >nul 2>&1
set /a "dPassed=%newestDate:~0,2%-%oldestDate:~0,2%"
set "hPassed=%TimePassed:~0,2%"
set "hPassed=%hPassed::=%"%
set "mPassed=%TimePassed:~2,3%"
set "mPassed=%mPassed::=%"
set /a "minPassedtotal=%dPassed%*1440+%hPassed%*60+%mPassed%"

REM === Counting rendered frames ============================================================================

set renderedFrames=0
for %%a in (%renderpath%\*.%extension%) do set /a renderedFrames+=1
set /a "percentagedone=%renderedFrames%*100/%totalframes%"

REM === Calculating avg time to render a frame ==============================================================

set /a "avgRenderMins=%minPassedtotal%/%renderedFrames%"
set /a "avgRenderSecs=%minPassedtotal%*60/%renderedFrames%"
set /a "avgRenderSecsleft=%avgRenderSecs%-(%avgRenderMins%*60)"

REM === Calculating total render time =======================================================================

set /a "totalRenderSecs=%avgRenderSecs%*%totalframes%"
set /a "totalRenderMins=%totalRenderSecs%/60"
set /a "totalRenderHours=%totalRenderSecs%/3600"
set /a "totalRenderDays=%totalRenderSecs%/86400"

set /a "totalRenderHoursleft=%totalRenderHours%-%totalRenderDays%*24
set /a "totalRenderMinsleft=%totalRenderMins%-%totalRenderDays%*1440-%totalRenderHoursleft%*60"
set /a "totalRenderSecsleft=%totalRenderSecs%-%totalRenderDays%*86400-%totalRenderHoursleft%*3600-%totalRenderMinsleft%*60"

REM === Calculating time left ===============================================================================

REM = Calculating Seconds left ===================================
set /a "remainingSecstotal=%totalRenderSecs%-%minPassedtotal%*60"

REM = Converting Seconds left to d,h,min =========================
set /a "remainingDays=%remainingSecstotal%/86400
set /a "remainingHourstotal=%remainingSecstotal%/3600
set /a "remainingMinstotal=%remainingSecstotal%/60

set /a "remainingHours=%remainingHourstotal%-%remainingDays%*24
set /a "remainingMins=%remainingMinstotal%-%remainingDays%*1440-%remainingHours%*60

REM === Display info =========================================================================================

echo First render:		%oldestfile%	%oldestDate%	%oldestTimeReal%
echo Newest render:		%newestfile%	%newestDate%	%newestTimeReal%
echo Rendered frames:	%renderedFrames% / %totalframes% Frames (%percentagedone% %%)
echo Avg frame render time:	%avgRenderMins%min %avgRenderSecsleft%s
echo Time passed:		%dPassed%d %hPassed%h %mPassed%min
echo Total render time:	%totalRenderDays%d %totalRenderHoursleft%h %totalRenderMinsleft%min
echo Remaining time:		%remainingDays%d %remainingHours%h %remainingMins%min 

REM === IF not done, loop ====================================================================================

echo ==============================================================================

IF %renderedFrames% GEQ %totalframes% (goto done)

echo This window will refresh periodically until the render is done.

:check
set renderedFramesTMP=0
for %%a in (%renderpath%\*.%extension%) do set /a renderedFramesTMP+=1
if %renderedFramesTMP%==%renderedFrames% (
	timeout 5 > nul
	goto check
	)
cls
goto loop

:done
echo Render should be done
:question
set /P c=Save log? [Y/N]?
if /I "%c%" EQU "Y" (goto log)
if /I "%c%" EQU "N" (goto end)
goto question

:log
echo First render:		%oldestfile%	%oldestDate%	%oldestTimeReal%>>%renderpath%\log.txt
echo Newest render:		%newestfile%	%newestDate%	%newestTimeReal%>>%renderpath%\log.txt
echo Rendered frames:	%renderedFrames% / %totalframes% Frames (%percentagedone% %%)>>%renderpath%\log.txt
echo Avg frame render time:	%avgRenderMins%min %avgRenderSecsleft%s>>%renderpath%\log.txt
echo Time passed:		%dPassed%d %hPassed%h %mPassed%min>>%renderpath%\log.txt
echo Total render time:	%totalRenderDays%d %totalRenderHoursleft%h %totalRenderMinsleft%min>>%renderpath%\log.txt
echo Remaining time:		%remainingDays%d %remainingHours%h %remainingMins%min>>%renderpath%\log.txt
echo log saved in %renderpath%.

:end
echo Press any key to exit...
pause > nul