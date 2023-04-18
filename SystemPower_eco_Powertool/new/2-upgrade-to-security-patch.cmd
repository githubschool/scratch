@ECHO OFF

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%ERRORLEVEL%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------
CLS
:MENU
ECHO *************************************************************
ECHO ****** Upgrade to Security patch for Windows 10 and 11 ******
ECHO *************************************************************
ECHO.
ECHO 1 - Update security for platforms below Windows 10 - 20H2
ECHO 2 - Upgrade Windows 11 21H2 to the build 613.
ECHO q - QUIT
ECHO.
\\10.0.56.14\images\tools\findstr\CHOICE /n /c:12q /M "Choose an option (1-6) or Q to Exit: "
rem for debug use below 2 commented rows
 echo You choose: %ERRORLEVEL% .
rem pause
GOTO LABEL-%ERRORLEVEL%


:LABEL-1
CLS
ECHO Upgrade and update the platform till build 1708 Win10 OS
powershell.exe -ExecutionPolicy ByPass -File \\10.0.56.14\images\Users\Nik\powershell\wu\wu.ps1

:LABEL-2
CLS
ECHO Upgrade Windows 11 21H2 to the build 613.
start /wait \\10.0.56.14\images\Microsoft_Images\21H2\MSUs\OS Build 22000.613\x64\windows10.0-kb5012592-x64_ea2cbcc90d772b5c41410e88f96e6cad1608f45b.msu /quiet /norestart
ECHO The platform is going to restart and update the build till build 613.
shutdown -r -t 10
GOTO EOF



:LABEL-0
:EOF

EXIT