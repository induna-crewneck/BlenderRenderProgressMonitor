@echo off
mode con: cols=0 lines=0
mode con: cols=50 lines=18
REM not sure why, but it needs two mode con lines to work, but the first one does nothing.
setlocal

title BRPM 3.3 beta
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
set telegrambottoken=123456789:ABCDefgh12I34Jk
set mytelegramid=123456789
REM =========================================================================================================

:waitfor1
echo =============================================
echo ====== Blender Render Progress Monitor ======
echo ======== github.com/induna-crewneck =========
echo =============================================
REM ==== Waiting for first frame ============================================================================
if exist %renderpath%\*.%extension% (
    echo File detected in target folder.
    echo Starting script...
) else (
    echo No file detected in target folder.
    echo Waiting 10s and re-checking...
    timeout 10 2>nul
    cls
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
IF "%hh:~1%" == "00" (set hh=0) else (IF %hh:~1% EQU 0 (set hh=0) else (set hh=%hh:~1%))
REM echo Time elapsed: %days%d %hh:~1%h %mm:~1%min %ss:~1%s
set /a "mm=%mm:~1%/1"
REM =========================================================================================================

REM ==== Count rendered frames ==============================================================================
set renderedframes=0
for %%a in (%renderpath%\*.%extension%) do set /a renderedframes+=1
set /a "percentagedone=%renderedFrames%*100/%totalframes%"
REM echo %renderedframes%/%totalframes% frames rendered
REM =========================================================================================================

REM ==== Math time ==========================================================================================
set /a "elapsedseconds=%hh%*3600"+%mm%*60+%ss:~1%
set /a "avgrendersecs=%elapsedseconds%/%renderedframes%
set /a "avgrendermins=%avgrendersecs%/60"
REM CHECKPOINT_No Errors until here. Some errors sometimes in the following line(s)?

set /a "avgrendersecs=%avgrendersecs%-(%avgrendermins%*60)"
set /a "totalsecs=%elapsedseconds%/%renderedframes%*%totalframes%
set /a "remainingsecstotal=%totalsecs%-%elapsedseconds%
set /a "remainingminstotal=%remainingsecstotal%/60"
set /a "remainingdays=%remainingminstotal%/60/24"
set /a "remaininghours=%remainingminstotal%/60-(%remainingdays%*24)
set /a "remainingmins=%remainingminstotal%-(%remaininghours%*60)-(%remainingdays%*24*60)"
set /a "remainingsecs=%remainingsecstotal%-%remainingmins%*60-%remaininghours%*3600-%remainingdays%*24*60*60"
if "%NewestTime:~0,2%" == "%OldestTime:~0,2%" (set days=0)
REM =========================================================================================================

REM === Estimated finish =====================================================================================
for /F "tokens=1-4" %%a in ('date /t') do set "datenow=%%a"
if %datenow:~8,2% LSS 10 (set daynow=%datenow:~9,1%) else (set daynow=%datenow:~8,2%)
if %datenow:~5,2% LSS 10 (set monthnow=%datenow:~6,1%) else (set monthnow=%datenow:~5,2%)
set /a ETAd=%remainingdays%+%daynow%
REM add leading zero in day
if %ETAd% LSS 10 (set ETAd=0%ETAd% 2> nul)
set /a "ETAh=%remaininghours%+%NewestTime:~11,2%"
set /a "ETAm=%remainingmins%+%NewestTime:~14,2%"
set /a "ETAs=%remainingsecs%+%NewestTime:~17,2%"
set ETAmonth=%NewestTime:~3,2%
set ETAyear=%NewestTime:~6,4%

rem date rollover fixes
rem if minute>60, add 1 to hour
if %ETAm% GTR 60 set /a "ETAm=%ETAm%-60, ETAh=%ETAh%+1"
rem if hour>24, add 1 to date
if %ETAh% GEQ 24 set /a "ETAh=%ETAh%-24, ETAd=%ETAd%+1"
rem fix month
if %ETAd% GTR 31 set /a "ETAd=%ETAd%-31, ETAmonth=%ETAmonth%+1"
if %ETAd% GTR 30 (
    if %ETAmonth% EQU 4 (set /a "ETAd=%ETAd%-30, ETAmonth=%ETAmonth%+1") else (
    if %ETAmonth% EQU 6 (set /a "ETAd=%ETAd%-30, ETAmonth=%ETAmonth%+1") else (
    if %ETAmonth% EQU 9 (set /a "ETAd=%ETAd%-30, ETAmonth=%ETAmonth%+1") else (
    if %ETAmonth% EQU 11 (set /a "ETAd=%ETAd%-30, ETAmonth=%ETAmonth%+1")))))
rem check if Year is divisible by 4 (leap year)
set /a "leap=%ETAyear% %% 4"
rem if %leap% is 0, it's a leap year
if %leap% EQU 0 (if %ETAd% GTR 29 (if %ETAmonth% EQU 2 (set /a "ETAd=%ETAd%-29, ETAmonth=%ETAmonth%+1")))
if %ETAd% GTR 28 (if %ETAmonth% EQU 2 (set /a "ETAd=%ETAd%-28, ETAmonth=%ETAmonth%+1"))

rem cosmetics
if %ETAs% LSS 10 set ETAs=0%ETAs%
if %ETAm% LSS 10 set ETAm=0%ETAm%
if %ETAh% LSS 10 set ETAh=0%ETAh%
if %ETAd% LSS 10 set ETAd=0%ETAd%
if %ETAmonth% LSS 10 set ETAmonth=0%ETAmonth%
REM ==========================================================================================================

REM === Total render time ====================================================================================
set /a "totalRenderDays=%days%+%remainingdays%"
REM set /a "totalRenderHours=%hh%+%remaininghours%"
REM strings with leading zeroes throw errors (interpreted as oktal, not numerical ffs)
IF %remaininghours% EQU 0 (IF %hh% EQU 0 (set totalRenderHours=0) else (set totalRenderHours=%hh%)) else (IF %hh% EQU 0 (set totalRenderHours=%remaininghours%) else (set /a "totalRenderHours=%hh%+%remaininghours%"))
set /a "totalRenderMins=%remainingmins%+%mm%"
set /a "totalRenderSecs=%remainingsecs%+%ss:~1%"
if %totalRenderSecs% geq 60 (set /a "totalRenderSecs=%totalRenderSecs%-60")
rem echo %totalRenderDays%d, %totalRenderHours%h, %totalRenderMins%min, %totalRenderSecs%sec
REM ==========================================================================================================

REM === cosmetic fixes =======================================================================================
REM removing leading zero in values <10
IF %hh% LSS 10 (set /a "hh=%hh%*1")
IF %totalRenderHours% LSS 10 (set /a "totalRenderHours=%totalRenderHours%*1")
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

REM echo Avg frame render time:	%avgrendermins%min %avgrendersecs%s
IF %avgrendermins% EQU 0 (echo Avg frame render time:	%avgrendersecs%s) else (echo Avg frame render time:	%avgrendermins%min %avgrendersecs%s)

REM echo Time elapsed:		%days%d %hh:~1%h %mm%min %ss:~1%s
IF %days% EQU 0 (IF %hh% EQU 0 (echo Time elapsed:		%mm%min %ss:~1%s) else (echo Time elapsed:		%hh%h %mm%min %ss:~1%s)) else (echo Time elapsed:		%days%d %hh%h %mm%min %ss:~1%s)

REM echo Total render time:	%totalRenderDays%d %totalRenderHours%h %totalRenderMins%min %totalRenderSecs%s
IF %totalRenderDays% EQU 0 (IF %totalRenderHours% EQU 0 (echo Total render time:	%totalRenderMins%min %totalRenderSecs%s) else (echo Total render time:	%totalRenderHours%h %totalRenderMins%min %totalRenderSecs%s)) else (echo Total render time:	%totalRenderDays%d %totalRenderHours%h %totalRenderMins%min %totalRenderSecs%s)

REM echo Remaining time:		%remainingdays%d %remaininghours%h %remainingmins%min %remainingsecs%s
IF %remainingdays% EQU 0 (IF %remaininghours% EQU 0 (echo Remaining time:		%remainingmins%min %remainingsecs%s) else (echo Remaining time:		%remaininghours%h %remainingmins%min %remainingsecs%s)) else (echo Remaining time:		%remainingdays%d %remaininghours%h %remainingmins%min %remainingsecs%s)

echo Estimated completion:	%ETAyear%-%ETAmonth%-%ETAd%  %ETAh%:%ETAm%:%ETAs%

echo Rendered frames:	%renderedframes% / %totalframes% frames

if %percentagedone% gtr 98 (echo  ######################################## %percentagedone%%%) else (
if %percentagedone% gtr 95 (echo  #######################################_ %percentagedone%%%) else (
if %percentagedone% gtr 93 (echo  ######################################__ %percentagedone%%%) else (
if %percentagedone% gtr 90 (echo  #####################################___ %percentagedone%%%) else (
if %percentagedone% gtr 88 (echo  ####################################____ %percentagedone%%%) else (
if %percentagedone% gtr 85 (echo  ###################################_____ %percentagedone%%%) else (
if %percentagedone% gtr 83 (echo  ##################################______ %percentagedone%%%) else (
if %percentagedone% gtr 80 (echo  #################################_______ %percentagedone%%%) else (
if %percentagedone% gtr 78 (echo  ################################________ %percentagedone%%%) else (
if %percentagedone% gtr 75 (echo  ###############################_________ %percentagedone%%%) else (
if %percentagedone% gtr 73 (echo  ##############################__________ %percentagedone%%%) else (
if %percentagedone% gtr 70 (echo  #############################___________ %percentagedone%%%) else (
if %percentagedone% gtr 68 (echo  ############################____________ %percentagedone%%%) else (
if %percentagedone% gtr 65 (echo  ###########################_____________ %percentagedone%%%) else (
if %percentagedone% gtr 63 (echo  ##########################______________ %percentagedone%%%) else (
if %percentagedone% gtr 60 (echo  #########################_______________ %percentagedone%%%) else (
if %percentagedone% gtr 58 (echo  ########################________________ %percentagedone%%%) else (
if %percentagedone% gtr 55 (echo  #######################_________________ %percentagedone%%%) else (
if %percentagedone% gtr 53 (echo  ######################__________________ %percentagedone%%%) else (
if %percentagedone% gtr 50 (echo  #####################___________________ %percentagedone%%%) else (
if %percentagedone% gtr 48 (echo  ####################____________________ %percentagedone%%%) else (
if %percentagedone% gtr 45 (echo  ###################_____________________ %percentagedone%%%) else (
if %percentagedone% gtr 43 (echo  ##################______________________ %percentagedone%%%) else (
if %percentagedone% gtr 40 (echo  #################_______________________ %percentagedone%%%) else (
if %percentagedone% gtr 38 (echo  ################________________________ %percentagedone%%%) else (
if %percentagedone% gtr 35 (echo  ###############_________________________ %percentagedone%%%) else (
if %percentagedone% gtr 33 (echo  ##############__________________________ %percentagedone%%%) else (
if %percentagedone% gtr 30 (echo  #############___________________________ %percentagedone%%%) else (
if %percentagedone% gtr 28 (echo  ############____________________________ %percentagedone%%%) else (
if %percentagedone% gtr 25 (echo  ###########_____________________________ %percentagedone%%%) else (
if %percentagedone% gtr 23 (echo  ##########______________________________ %percentagedone%%%) else (
if %percentagedone% gtr 20 (echo  #########_______________________________ %percentagedone%%%) else (
if %percentagedone% gtr 18 (echo  ########________________________________ %percentagedone%%%) else (
if %percentagedone% gtr 15 (echo  #######_________________________________ %percentagedone%%%) else (
if %percentagedone% gtr 13 (echo  ######__________________________________ %percentagedone%%%) else (
if %percentagedone% geq 10 (echo  #####___________________________________ %percentagedone%%%) else (
if %percentagedone% gtr 8 (echo  ####____________________________________  %percentagedone%%%) else (
if %percentagedone% gtr 5 (echo  ###_____________________________________  %percentagedone%%%) else (
if %percentagedone% gtr 3 (echo  ##______________________________________  %percentagedone%%%) else (
if %percentagedone% gtr 0 (echo  #_______________________________________  %percentagedone%%%) else (
echo ________________________________________  %percentagedone%%%))))))))))))))))))))))))))))))))))))))))
echo =============================================
echo.
echo Refreshing after %waittime% seconds or on keypress...

REM ==========================================================================================================
REM Check if done, otherwise wait
IF %renderedFrames% GEQ %totalframes% (goto done) else (
timeout %waittime% > nul
goto loop)

:done
mode con: cols=50 lines=12
echo =============================================
echo ====== Blender Render Progress Monitor ======
echo =============================================
echo.
echo                RENDER COMPLETE
echo.
echo Rendered frames:	%renderedframes% / %totalframes% frames
echo Time elapsed:		%days%d %hh%h %mm%min %ss:~1%s
echo Completed:		%NewestTime:~6,4%-%NewestTime:~3,2%-%NewestTime:~0,2%   %NewestTime:~11,8%
REM Sending Telegram message
set telegrammsg=Blender%%20render%%20has%%20finished%%20rendering%%20%renderedframes%%%20frames
curl "https://api.telegram.org/bot%telegrambottoken%/sendMessage?chat_id=%mytelegramid%&text=%telegrammsg%" > nul
echo.
:question
set /P c=Save log? [Y/N]?
if /I "%c%" EQU "Y" (goto log)
if /I "%c%" EQU "N" (goto end)
goto question

:log
for /F "tokens=1-4" %%a in ('time /t') do set "timenow=%%a"
echo %datenow%_%timenow% =========================>>%renderpath%\log.txt
echo First render:		%oldestfile%>>%renderpath%\log.txt
echo				%OldestTime:~6,4%-%OldestTime:~3,2%-%OldestTime:~0,2%   %OldestTime:~11,8%>>%renderpath%\log.txt
echo Newest render:		%newestfile%>>%renderpath%\log.txt
echo				%NewestTime:~6,4%-%NewestTime:~3,2%-%NewestTime:~0,2%   %NewestTime:~11,8%>>%renderpath%\log.txt
echo Avg frame render time:	%avgrendermins%min %avgrendersecs%s>>%renderpath%\log.txt
echo Time elapsed:		%days%d %hh%h %mm%min %ss:~1%s>>%renderpath%\log.txt
echo Total render time:	%totalRenderDays%d %totalRenderHours%h %totalRenderMins%min %totalRenderSecs%s>>%renderpath%\log.txt
echo Remaining time:		%remainingdays%d %remaininghours%h %remainingmins%min %remainingsecs%s>>%renderpath%\log.txt
echo Estimated completion:	%ETAyear%-%ETAmonth%-%ETAd%  %ETAh%:%ETAm%:%ETAs%>>%renderpath%\log.txt
echo Rendered frames:	%renderedframes% / %totalframes% frames>>%renderpath%\log.txt
echo Output path:	%renderpath%>>%renderpath%\log.txt
echo Log saved in render path.

:end
REM echo Press any key to exit...
REM pause > nul
exit
