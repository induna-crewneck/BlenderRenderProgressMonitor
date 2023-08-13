@echo off
setlocal

REM ==== ENTER VARIABLES HERE ===============================================================================
REM Output path specified in Blender:
set renderpath=[INSERT TARGET PATH HERE]
REM Number of frames to be rendered:
set totalframes=[INSERT NUMBER OF FRAMES TO BE RENDERED HERE]
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
set "oldestTimeReal=%OldestTime%"

REM echo CHECKPOINT Pre-Loop

REM ===== LOOP START =====
REM ======================

:loop

del /s %renderpath%\tmp.txt >nul 2>&1
del /s %renderpath%\tmp2.txt >nul 2>&1

REM ==== Getting timestamp of last rendered frame ==========================================================

for /f "delims=" %%a in ('dir "%renderpath%" /od /b') do set newestfile=%%a

for /f "tokens=1" %%a in ('dir "%renderpath%\%newestfile%" /t:c') do (echo %%~a>>"%renderpath%\tmp.txt")
for /f "tokens=2" %%a in ('dir "%renderpath%\%newestfile%" /t:c') do (echo %%~a>>"%renderpath%\tmp.txt")
for /f "skip=3" %%a in ('type %renderpath%\tmp.txt') do (echo %%~a>>%renderpath%\tmp2.txt)
set /p newestDate=< %renderpath%\tmp2.txt
del %renderpath%\tmp2.txt
for /f "skip=9" %%a in ('type %renderpath%\tmp.txt') do (echo %%~a>>%renderpath%\tmp2.txt)
set /p newestTime=< %renderpath%\tmp2.txt
set "newestTimeReal=%NewestTime%"

del %renderpath%\tmp.txt
del %renderpath%\tmp2.txt

REM ==== Calculating time passed =============================================================================

REM === Accommodating for newestTime hour being smaller than oldesttime hour ===========

Set "Start=%oldestTime%"
Set "End=%newestTime%"
For /F "usebackqdelims=" %%A in (`
powershell -NoP -C "$TS=New-TimeSpan -Start ([datetime]'%Start%') -End ([datetime]'%End%');'{0}:{1:00}:{2:00}' -f [math]::Floor($TS.TotalHours),$TS.Minutes,$TS.Seconds"
`) Do Set "TimePassed=%%A" >nul 2>&1

set "timepassed=%timepassed:~0,-3%"

set "newMinReal=%newesttimereal:~2,3%"
set "newMinReal=%newMinReal::=%"%
set "oldMinReal=%oldesttimereal:~2,3%"
set "oldMinReal=%oldMinReal::=%"%

REM echo CHECKPOINT 1

IF %newestDate:~0,2%==%oldestDate:~0,2% (set "dPassed=0"
) ELSE (
	IF %newesttimeREAL:~0,2% LEQ %oldesttimeREAL:~0,2% (
 			IF %newMinReal% LSS %oldMinReal% (set /a "dPassed=%newestDate:~0,2%-%oldestDate:~0,2%-1"
 			) ELSE (set /a "dPassed=%newestDate:~0,2%-%oldestDate:~0,2%"
 			)
 	) ELSE (set /a "dPassed=%newestDate:~0,2%-%oldestDate:~0,2%"
	)
)

REM === End of accommodation =============================================================

REM echo CHECKPOINT 2

set "hPassed=%TimePassed:~0,2%"
set "hPassed=%hPassed::=%"%
set "mPassed=%TimePassed:~2,3%"
set "mPassed=%mPassed::=%"

if %hPassed% LSS 0 (
	set /a "hPassed=24+%hPassed%"
	if %mPassed% LSS 0 (
		set /a "mPassed=60+%mPassed%"
		)
	goto continue3)
if %mPassed% LSS 0 (
	set /a "mPassed=60+%mPassed%"
	goto continue3)

set "hPassed=%TimePassed:~0,2%"
set "mPassed=%TimePassed:~2,3%"
set "hPassed=%hPassed::=%"%
set "mPassed=%mPassed::=%"%

REM echo CHECKPOINT 3

set /a "minPassedtotal=%dPassed%*1440+%hPassed%*60+%mPassed%"

:continue3

REM echo CHECKPOINT 4

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

REM =================================================
REM NOTES============================================
REM =================================================
REM fix numbering of continues when everything works
