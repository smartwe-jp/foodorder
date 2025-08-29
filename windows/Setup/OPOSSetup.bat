@echo off

cd /d %~dp0

TITLE OPOSSetup
 
set A="C:\OPOS\GLORY\RT300"
set B="C:\OPOS"
set C= OPOSSetup

set DN=""
set DES=""
set FN=""

set G_XCOPY=.\xcopyXp.exe

TITLE %C%

if exist %A%\install.log del %A%\install.log

:PATHCHK
	if exist "%A%" goto DEVCHK
	
:DEVCHK
goto DEVSET1
@REM echo +-----------------------------------------------------------+
@REM echo   ISP-902E06 OPOS CashChanger SetUp
@REM echo.
@REM echo   Copyright (C) 2016 Glory Ltd. All rights reserved. 
@REM echo. 
@REM echo +-----------------------------------------------------------+

@REM echo 各機種毎のセットアップを行います。

@REM echo **************     Selecting Value     *********************
@REM echo   [1]   : RAD-300/RT-300(+ WD-300)
@REM echo   [2]   : RT-300
@REM echo   [q/Q] : Quit Setup
@REM echo ************************************************************
@REM echo.
@REM echo "上記値を指定してください。以下に例を示します。"
@REM echo "EX):Please Select >2 【RT-300のセットアップを行います】"
@REM echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@REM set /p NUM="Please Select >"

@REM 	if  "%NUM%" == "1"	goto DEVSET1
@REM 	if  "%NUM%" == "2"	goto DEVSET2
@REM 	if  "%NUM%" == "q" 	goto ENDBAT
@REM 	if  "%NUM%" == "Q" 	goto ENDBAT
	
@REM echo. 画面の更新を行います
@REM 	cls	
@REM 	goto DEVCHK	
	
:DEVSET1
	set DN=RAD/RT-300
	set DES="Glory RAD/RT-300 CashChanger"
	set FN=RAD300RT300
	echo %NUM% Selected.
	goto MAKEDIR

:DEVSET2
	set DN=RT-300
	set DES="Glory RT-300 CashChanger"
	set FN=RT300
	echo %NUM% Selected.
	goto MAKEDIR

:MAKEDIR
	echo Make a directory...
    echo. 
	mkdir %A%
	if exist "%A%""\LOG" goto COPYING
	mkdir %A%"\LOG"
	if not %errorlevel% == 0 goto MAKEDIRERR

	goto COPYING

:MAKEDIRERR
	echo Can not make a directory.
	goto ENDBAT

:COPYING
	echo Copy files...
    echo. 
	copy .\OPOSCashChanger.ocx %A%
	if not %errorlevel% == 0 goto COPYINGERR

	copy .\64OPOSCashChanger.ocx %A%
	if not %errorlevel% == 0 goto COPYINGERR

	copy .\OposCashChanger_CCO.dll	%A%
	if not %errorlevel% == 0 goto COPYINGERR

	copy .\ChangerSO.dll	%A%
	if not %errorlevel% == 0 goto COPYINGERR

	copy .\reg.exe			%A%
	if not %errorlevel% == 0 goto COPYINGERR

	copy .\OPOSSetup.exe	%A%
	if not %errorlevel% == 0 goto COPYINGERR

	copy .\Cleanup.bat %A%
	if not %errorlevel% == 0 goto COPYINGERR
	
	copy .\GLORY_Cleanupdir.bat %A%
	if not %errorlevel% == 0 goto COPYINGERR

	for %%I in (xcopy.exe) do if exist %%~$path:I set G_XCOPY=%%~$path:I

	%G_XCOPY% .\err "%A%""\ERR" /s /v /k /y /q /i /r
	if not %errorlevel% == 0 goto COPYINGERR

        goto REGSVR

:COPYINGERR
	echo Can not copy files.
	goto	ENDBAT

:REGSVR
	echo Entrying DllServer...
    echo. 
	regsvr32 %A%\64OPOSCashChanger.ocx /S
	if not %errorlevel% == 0 goto REGSVRERR

	regsvr32 %A%\ChangerSO.dll /S
	if not %errorlevel% == 0 goto REGSVRERR

	goto REGENT

:REGSVRERR
	echo Can not Entrying DLLServer.
	goto ENDBAT


:REGENT
	echo Entrying Registry...
	call .\Regent.bat	%A% %DN% %DES% %FN%
    	echo. 
	echo ************************************************************
	echo Setup completed successfully.

	echo Setup completed successfully. >> C:\OPOS\GLORY\RT300\install.log
	goto ENDBAT_OK

:ENDBAT
	pause

:ENDBAT_OK
