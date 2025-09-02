@echo off

cd /d %~dp0

set A="HKLM\SOFTWARE\OLEforRetail\ServiceInfo\GLORY\CashChanger"
set B="HKLM\SOFTWARE\OLEforRetail\ServiceOPOS\CashChanger\GloryRAD/RT-300"
set C="HKLM\SOFTWARE\OLEforRetail\ServiceOPOS\CashChanger\GloryRT-300"

echo +-----------------------------------------------------------+
echo   ISP-902E06 OPOS CashChanger CleanUp
echo.
echo   Copyright (C) 2016 Glory Ltd. All rights reserved. 
echo. 
echo +-----------------------------------------------------------+
regsvr32 /u /s 64OPOSCashChanger.ocx
if not %errorlevel% == 0 goto UNREGERR
regsvr32 /u /s ChangerSO.dll
if not %errorlevel% == 0 goto UNREGERR

goto DELREG

:UNREGERR
goto ENDBAT

:DELREG
for /f "tokens=1,2,*" %%i in ('reg query %A% /v "Device"') do set DEV=%%k

if "%DEV%" == "RAD/RT-300" (
   C:\OPOS\GLORY\RT300\reg.exe delete %B% /f
   goto DELPASS
)
	
if "%DEV%" == "RT-300" (
   C:\OPOS\GLORY\RT300\reg.exe delete %C% /f
   goto DELPASS
)

echo 指定レジストリが存在しません
goto DELPASS


:DELPASS
C:\OPOS\GLORY\RT300\reg.exe delete %A% /f
goto DELFILE

:DELFILE
copy C:\OPOS\GLORY\RT300\GLORY_Cleanupdir.bat C:\OPOS
C:\OPOS\GLORY_Cleanupdir.bat
goto ENDBAT_OK

:ENDBAT
PAUSE

:ENDBAT_OK