@echo off
Title Hosts File Automatic Update 
setlocal EnableExtensions EnableDelayedExpansion
setlocal enabledelayedexpansion
REM  BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
    IF "%PROCESSOR_ARCHITECTURE%" EQU "amd64" (
>nul 2>&1 "%SYSTEMROOT%\SysWOW64\cacls.exe" "%SYSTEMROOT%\SysWOW64\config\system"
) ELSE (
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
)

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    set params= %*
    echo UAC.ShellExecute "cmd.exe", "/c ""%~s0"" %params:"=""%", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    del "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    pushd "%CD%"
    CD /D "%~dp0"

set "hostspath=%SystemRoot%\System32\drivers\etc\hosts"

REM Get the lines in hosts.csv
set numP=85
set "cmd=findstr /R /N "^^" hostList.txt | find /C ":""
for /f %%a in ('!cmd!') do set number=%%a
REM num to progress bar
set /a progress = 0 
REM set /a numberToProgress = %number%    /   %numP%
set /a numberToProgress = %number%    /   %numP%
REM muestre los datos
REM echo number: %number%
REM echo numberDiv: %numberToProgress%
REM echo progress: %progress%

REM  load array
rem Initialize the array of our hosts to toggle
REM configuration of new file HOSTS
DEL "%hostspath%.new"
REM echo # Copyright (c) 1993-2009 Microsoft Corp  >> "%hostspath%.new"
REM echo #  >> "%hostspath%.new"
REM echo # This is a sample HOSTS file used by Microsoft TCP/IP for Windows. >> "%hostspath%.new"
REM echo #  >> "%hostspath%.new"
REM echo # This file contains the mappings of IP addresses to host names. Each  >> "%hostspath%.new"
REM echo # entry should be kept on an individual line. The IP address should  >> "%hostspath%.new"
REM echo # be placed in the first column followed by the corresponding host name.  >> "%hostspath%.new"
REM echo # The IP address and the host name should be separated by at least one  >> "%hostspath%.new"
REM echo # space.  >> "%hostspath%.new"
REM echo #  >> "%hostspath%.new"
REM echo # Additionally, comments (such as these) may be inserted on individual >> "%hostspath%.new"
REM echo # lines or following the machine name denoted by a '#' symbol.  >> "%hostspath%.new"
REM echo #  >> "%hostspath%.new"
REM echo # For example:"  >> "%hostspath%.new
REM echo #  >> "%hostspath%.new"
REM echo #      102.54.94.97     rhino.acme.com          # source server  >> "%hostspath%.new"
REM echo #       38.25.63.10     x.acme.com              # x client host  >> "%hostspath%.new"
REM echo # localhost name resolution is handled within DNS itself.  >> "%hostspath%.new"
REM echo #    127.0.0.1       localhost  >> "%hostspath%.new"
REM echo #   ::1             localhost  >> "%hostspath%.new"
REM echo 127.0.0.1  localhost  >> "%hostspath%.new"

for /f "delims=" %%a in ('Type "%hostspath%"') Do (
    echo %%a >> "%hostspath%.new"
)

for /F "tokens=*" %%a in (hostList.txt) do (
    set /a numhosts+=1
    set "host!numhosts!=%%~a"
    REM echo %%a
    set /a progress  = !numhosts!/%numberToProgress%
     REM echo numHost: !numhosts!
     REM echo number: %number%
     REM echo numberDiv: %numberToProgress%
     REM echo progress=!progress!
     call :drawProgressBar !progress! 
     find /c "%%a" "%hostspath%" >NUL || ( 
        echo %%a >> "%hostspath%.new"
        REM echo + %%a      
    ) 
)

echo numHosts: !numhosts!
move /y "%hostspath%" "%hostspath%.bak" >nul || echo Can't backup %hostspath%
move /y "%hostspath%.new" "%hostspath%" >nul || echo Can't update %hostspath%
set /a progress = 100
call :drawProgressBar !progress!
pause
endlocal



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