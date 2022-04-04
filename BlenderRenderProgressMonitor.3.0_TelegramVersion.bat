@echo off
setlocal

title Blender Render Progress Monitor v3.0 (Telegram)
REM === https://github.com/induna-crewneck

REM ==== ENTER VARIABLES HERE ===============================================================================
REM Output path specified in Blender:
set renderpath=C:\Examplepath\targetfolder
REM Number of frames to be rendered:
set totalframes=420
REM File format
set extension=PNG
REM set time between checks (should be roughly time to render 1 frame)
set waittime=30
set telegrambottoken=4334584910:AAEPmjlh84N62Lv
set mytelegramid=123456789
REM =========================================================================================================

echo =============================================
echo ====== Blender Render Progress Monitor ======
echo =============================================

REM ==== Waiting for first frame ============================================================================
:waitfor1
if exist %renderpath%\*.%extension% (
    echo File detected in target folder. Starting script...
) else (
    echo No file detected in target folder. Waiting and re-checking...
    timeout 10 2> nul
    goto waitfor1
)
REM =========================================================================================================

:loop

REM ==== Find oldest and newest files =======================================================================
for /f "delims=" %%a in ('dir "%renderpath%" /o-d /b') do set oldestfile=%%a
for /f "delims=" %%a in ('dir "%renderpath%" /od /b') do set newestfile=%%a
REM =========================================================================================================

REM ==== Getting timestamps =================================================================================
for /f "tokens=* USEBACKQ" %%F in (
    `powershell -command "Get-ChildItem -Path "%renderpath%\%oldestfile%" | select CreationTime"`
    ) do set OldestTime=%%F
for /f "tokens=* USEBACKQ" %%F in (
    `powershell -command "Get-ChildItem -Path "%renderpath%\%newestfile%" | select CreationTime"`
    ) do set NewestTime=%%F    )
REM converting "YYYY-MM-DD HH:MM:SS" to "DD/MM/YYYY HH:MM:SS"
set OldestTime=%OldestTime:~8,2%/%OldestTime:~5,2%/%OldestTime:~0,4% %OldestTime:~11,8%
set NewestTime=%NewestTime:~8,2%/%NewestTime:~5,2%/%NewestTime:~0,4% %NewestTime:~11,8%
REM echo %oldestfile%	%OldestTime%
REM echo %newestfile%	%NewestTime%
REM =========================================================================================================

REM ==== Calculate time elapsed =============================================================================
REM Source: https://stackoverflow.com/questions/51082845/calculate-a-duration-between-two-dates-dd-mm-yyyy-hhmmss-in-batch-file
set "DateToJDN(Date)=( a=1Date, y=a%%10000, a/=10000, m=a%%100, d=a/100-100, a=(m-14)/12, (1461*(y+4800+a))/4+(367*(m-2-12*a))/12-(3*((y+4900+a)/100))/4+d-32075 )"
for /F "tokens=1-4" %%a in ("%OldestTime% %NewestTime%") do set "date1=%%a" & set "time1=%%b" & set "date2=%%c" & set "time2=%%d"
set /A "days=!DateToJDN(Date):Date=%date2:/=%! - !DateToJDN(Date):Date=%date1:/=%!" 2> nul
set /A "ss=(((1%time2::=-100)*60+1%-100) - (((1%time1::=-100)*60+1%-100)"
if %ss% lss 0 set /A "ss+=60*60*24, days-=1"
set /A "hh=ss/3600+100, ss%%=3600, mm=ss/60+100, ss=ss%%60+100"
REM echo Time elapsed: %days%d %hh:~1%h %mm:~1%min %ss:~1%s
REM =========================================================================================================

REM ==== Count rendered frames ==============================================================================
set renderedframes=0
for %%a in (%renderpath%\*.%extension%) do set /a renderedframes+=1
set /a "percentagedone=%renderedFrames%*100/%totalframes%"
REM echo %renderedframes%/%totalframes% frames rendered
REM =========================================================================================================

REM ==== Math time ==========================================================================================
set /a "elapsedseconds=%hh:~1%*3600"+%mm:~1%*60+%ss:~1%
set /a "avgrendersecs=%elapsedseconds%/%renderedframes%
set /a "avgrendermins=%avgrendersecs%/60"
set /a "avgrendersecs=%avgrendersecs%-(%avgrendermins%*60)"
set /a "totalsecs=%elapsedseconds%/%renderedframes%*%totalframes%
set /a "remainingsecstotal=%totalsecs%-%elapsedseconds%
set /a "remainingminstotal=%remainingsecstotal%/60"
set /a "remainingdays=%remainingminstotal%/60/24"
set /a "remaininghours=%remainingminstotal%/60-(%remainingdays%*24)
set /a "remainingmins=%remainingminstotal%-(%remaininghours%*60)-(%remainingdays%*24*60)"
set /a "remainingsecs=%remainingsecstotal%-%remainingmins%*60-%remaininghours%*3600-%remainingdays%*24*60*60"
REM =========================================================================================================

REM === Estimated finish =====================================================================================
set /a "ETAd=%remainingdays%+%NewestTime:~0,2%"
if %ETAd% LSS 10 set ETAd=0%ETAd%
set /a "ETAh=%remaininghours%+%NewestTime:~11,2%"
set /a "ETAm=%remainingmins%+%NewestTime:~14,2%"
set /a "ETAs=%remainingsecs%+%NewestTime:~17,2%"
REM echo ETA	%ETAd%/%NewestTime:~3,7% %ETAh%:%ETAm%:%ETAs%
REM ==========================================================================================================

REM === Display info =========================================================================================
cls
echo =============================================
echo ====== Blender Render Progress Monitor ======
echo =============================================
echo First render:		%oldestfile%
echo				%OldestTime:~6,4%-%OldestTime:~3,2%-%OldestTime:~0,2%   %OldestTime:~11,8%
echo Newest render:		%newestfile%
echo				%NewestTime:~6,4%-%NewestTime:~3,2%-%NewestTime:~0,2%   %NewestTime:~11,8%
echo Avg frame render time:	%avgrendermins%min %avgrendersecs%s
echo Time elapsed:		%days%d %hh:~1%h %mm:~1%min %ss:~1%s
REM echo Total render time:	%totalRenderDays%d %totalRenderHoursleft%h %totalRenderMinsleft%min
echo Remaining time:		%remainingdays%d %remaininghours%h %remainingmins%min %remainingsecs%s
echo Estimated completion:	%NewestTime:~6,4%-%NewestTime:~3,2%-%ETAd%   %ETAh%:%ETAm%:%ETAs%
echo Rendered frames:	%renderedframes% / %totalframes% frames
if %percentagedone% gtr 97 (echo ######################################## %percentagedone%%%) else (
if %percentagedone% gtr 95 (echo ######################################__ %percentagedone%%%) else (
if %percentagedone% gtr 90 (echo ####################################____ %percentagedone%%%) else (
if %percentagedone% gtr 85 (echo ##################################______ %percentagedone%%%) else (
if %percentagedone% gtr 80 (echo ################################________ %percentagedone%%%) else (
if %percentagedone% gtr 75 (echo ##############################__________ %percentagedone%%%) else (
if %percentagedone% gtr 70 (echo ############################____________ %percentagedone%%%) else (
if %percentagedone% gtr 65 (echo ##########################______________ %percentagedone%%%) else (
if %percentagedone% gtr 60 (echo ########################________________ %percentagedone%%%) else (
if %percentagedone% gtr 55 (echo ######################__________________ %percentagedone%%%) else (
if %percentagedone% gtr 50 (echo ####################____________________ %percentagedone%%%) else (
if %percentagedone% gtr 45 (echo ##################______________________ %percentagedone%%%) else (
if %percentagedone% gtr 40 (echo ################________________________ %percentagedone%%%) else (
if %percentagedone% gtr 35 (echo ##############__________________________ %percentagedone%%%) else (
if %percentagedone% gtr 30 (echo ############____________________________ %percentagedone%%%) else (
if %percentagedone% gtr 25 (echo ##########______________________________ %percentagedone%%%) else (
if %percentagedone% gtr 20 (echo ########________________________________ %percentagedone%%%) else (
if %percentagedone% gtr 15 (echo ######__________________________________ %percentagedone%%%) else (
if %percentagedone% gtr 10 (echo ####____________________________________ %percentagedone%%%) else (
if %percentagedone% gtr 5  (echo ##______________________________________ %percentagedone%%%) else (
if %percentagedone% gtr 1  (echo #_______________________________________ %percentagedone%%%)else (
echo ________________________________________ %percentagedone%%%)))))))))))))))))))))
echo =============================================
echo.
echo Refreshing after %waittime% seconds or on keypress...
echo.


REM ==========================================================================================================
REM Check if done
IF %renderedFrames% GEQ %totalframes% (goto done)

REM Waiting before refresh
timeout %waittime% > nul
cls
goto loop

:done
echo Render should be done
REM Sending Telegram message
set telegrammsg=Blender%%20render%%20has%%20finished%%20rendering%%20%renderedframes%%%20frames
curl "https://api.telegram.org/bot%telegrambottoken%/sendMessage?chat_id=%mytelegramid%&text=%telegrammsg%" > nul
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
