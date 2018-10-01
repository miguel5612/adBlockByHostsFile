@echo off
    
Title Hosts File Automatic Update 
setlocal enableextensions disabledelayedexpansion
setlocal EnableExtensions EnableDelayedExpansion
setlocal enabledelayedexpansion
set num1=15
set num2=3
set /a sum1=%num1%    /    %num2%
echo num1=%num1%
echo num2=%num2%
echo sum1=%sum1%
echo %num1%/%num2%=%sum1%

set numP=50
set "cmd=findstr /R /N "^^" hostList.csv | find /C ":""
for /f %%a in ('!cmd!') do set number=%%a
::num to progress bar
set /a progress = 0 
set /a numberToProgress=%number%    /    %numP%
::muestre los datos
echo number: %number%
echo numberDiv: %numberToProgress%
echo progress: %progress%

set x=100
set result=0

for /L %%i in (1,1,5) do (

  set /A result=!x! + %%i

  echo !result!
)
echo sum: %result%

@echo off
SetLocal EnableDelayedExpansion

set n=11
set m=12
set /a nme=3
set /a mdiff=nme-1
pause
if %n% NEQ %m% (
    if %mdiff% LEQ 3 (
        for /l %%C in (1,1,3) do (
            if %%C EQU 1 (
                set mon=Apr
                set num=1!mon!
            )
        )
    )
)
echo %num%


pause
@echo off
setlocal enableDelayedExpansion
for %%A in (100 200 300 400 500) do (
  set n=%%A

  REM a FOR variable must be expanded
  set /a x=%%A/25

  REM an environment variable need not be expanded
  set /a y=n/25

  REM variables that were set within a block must be expanded using delayed expansion
  echo x=!x!, y=!y!

  REM another technique is to use CALL with doubled percents, but it is slower and less reliable
  call echo x=%%x%%, y=%%y%%
)
pause
    setlocal enableextensions disabledelayedexpansion

    for /l %%f in (0 1 100) do (
        call :drawProgressBar %%f "up test with a long text that will not fit on screen unless you have a lot of space"
    )
   

    endlocal
    exit /b


:drawProgressBar value [text]
    if "%~1"=="" goto :eof
    if not defined pb.barArea call :initProgressBar
    setlocal enableextensions enabledelayedexpansion
    set /a "pb.value=%~1 %% 101", "pb.filled=pb.value*pb.barArea/100", "pb.dotted=pb.barArea-pb.filled", "pb.pct=1000+pb.value"
    set "pb.pct=%pb.pct:~-3%"
    if "%~2"=="" ( set "pb.text=" ) else ( 
        set "pb.text=%~2%pb.back%" 
        set "pb.text=!pb.text:~0,%pb.textArea%!"
    )
    <nul set /p "pb.prompt=[!pb.fill:~0,%pb.filled%!!pb.dots:~0,%pb.dotted%!][ %pb.pct% ] %pb.text%!pb.cr!"
    endlocal
    goto :eof

:initProgressBar [fillChar] [dotChar]
    if defined pb.cr call :finalizeProgressBar
    for /f %%a in ('copy "%~f0" nul /z') do set "pb.cr=%%a"
    if "%~1"=="" ( set "pb.fillChar=#" ) else ( set "pb.fillChar=%~1" )
    if "%~2"=="" ( set "pb.dotChar=." ) else ( set "pb.dotChar=%~2" )
    set "pb.console.columns="
    for /f "tokens=2 skip=4" %%f in ('mode con') do if not defined pb.console.columns set "pb.console.columns=%%f"
    set /a "pb.barArea=pb.console.columns/2-2", "pb.textArea=pb.barArea-9"
    set "pb.fill="
    setlocal enableextensions enabledelayedexpansion
    for /l %%p in (1 1 %pb.barArea%) do set "pb.fill=!pb.fill!%pb.fillChar%"
    set "pb.fill=!pb.fill:~0,%pb.barArea%!"
    set "pb.dots=!pb.fill:%pb.fillChar%=%pb.dotChar%!"
    set "pb.back=!pb.fill:~0,%pb.textArea%!
    set "pb.back=!pb.back:%pb.fillChar%= !"
    endlocal & set "pb.fill=%pb.fill%" & set "pb.dots=%pb.dots%" & set "pb.back=%pb.back%"
    goto :eof

:finalizeProgressBar [erase]
    if defined pb.cr (
        if not "%~1"=="" (
            setlocal enabledelayedexpansion
            set "pb.back="
            for /l %%p in (1 1 %pb.console.columns%) do set "pb.back=!pb.back! "
            <nul set /p "pb.prompt=!pb.cr!!pb.back:~1!!pb.cr!"
            endlocal
        )
    )
    for /f "tokens=1 delims==" %%v in ('set pb.') do set "%%v="
    goto :eof