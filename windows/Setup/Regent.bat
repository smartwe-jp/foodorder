
REM %1 is InstallDirectory.	ex) "C:\OPOS\GLORY"
REM %2 is DeviceName.		ex) "RAD-300/RT-300"
REM %3 is Description.		ex) "Glory RAD-300/RT-300 CashChanger"


set A="HKLM\SOFTWARE\OLEforRetail\ServiceInfo\GLORY\CashChanger"
set B="HKLM\SOFTWARE\OLEforRetail\ServiceOPOS\CashChanger"
set C=HKLM\SOFTWARE\OLEforRetail\ServiceOPOS\CashChanger\Glory%2


.\reg.exe add %A% /f /v "Device"     /t REG_SZ /d %2
.\reg.exe add %A% /f /v "InstallDir" /t REG_SZ /d %1
.\reg.exe add %A% /f /v "LogDevName" /t REG_SZ /d "CashChanger"


.\reg.exe add %B% /f /v "CashChanger" /t REG_SZ /d Glory%2


.\reg.exe add %C% /f /v ""		      					/t REG_SZ /d "CHANGERSO.CASHCHANGER"
.\reg.exe add %C% /f /v "BaudRate"	      				/t REG_SZ /d "9600"
.\reg.exe add %C% /f /v "BeginDepositPreCheck"			/t REG_SZ /d "FALSE"
.\reg.exe add %C% /f /v "Compatibility"					/t REG_SZ /d "00"
.\reg.exe add %C% /f /v "DataEventTiming"	          	/t REG_SZ /d "Once"
.\reg.exe add %C% /f /v "DepositErrorEvent"         	/t REG_SZ /d "DIEVT"
.\reg.exe add %C% /f /v "Description"         			/t REG_SZ /d %3
.\reg.exe add %C% /f /v "DeviceName"	      			/t REG_SZ /d Glory%2
.\reg.exe add %C% /f /v "DirectIOEventTiming"          	/t REG_SZ /d "RealTime"
.\reg.exe add %C% /f /v "EnabledMode"					/t REG_SZ /d "None"
.\reg.exe add %C% /f /v "FixDepositReturnTiming"       	/t REG_SZ /d "Sync"
.\reg.exe add %C% /f /v "LogSaveCount"        			/t REG_SZ /d "30000"
.\reg.exe add %C% /f /v "LogSaveDate"         			/t REG_SZ /d "14"
.\reg.exe add %C% /f /v "LogSaveDir"          			/t REG_SZ /d %1\LOG
.\reg.exe add %C% /f /v "MaintenanceLogRead"     		/t REG_SZ /d "FALSE"
.\reg.exe add %C% /f /v "PauseDepositReturnTiming"     	/t REG_SZ /d "Sync"
.\reg.exe add %C% /f /v "PORT"                			/t REG_SZ /d "COM1"
.\reg.exe add %C% /f /v "ReadCashCounts"      			/t REG_SZ /d "TRUE"
.\reg.exe add %C% /f /v "ReadCashCountsStyle" 			/t REG_SZ /d "1"
.\reg.exe add %C% /f /v "RealRead"            			/t REG_SZ /d "FALSE"
.\reg.exe add %C% /f /v "RepayType"           			/t REG_SZ /d "Amount"
.\reg.exe add %C% /f /v "Service"             			/t REG_SZ /d "ChangerSO.dll"
.\reg.exe add %C% /f /v "SupplyCountMode"     			/t REG_SZ /d "1"
.\reg.exe add %C% /f /v "WriteLog"            			/t REG_SZ /d "TRUE"
.\reg.exe add %C% /f /v "HardLogSaveDir"       			/t REG_SZ /d %1\HARDLOG

.\reg.exe add %C% /f /v "BeginDepositWorking"			/t REG_SZ /d "Pause"

.\reg.exe add %C% /f /v "DataEventEnabled"			/t REG_SZ /d "All"
.\reg.exe add %C% /f /v "AutoNego"				/t REG_SZ /d "TRUE"
.\reg.exe add %C% /f /v "DataEventLog"			/t REG_SZ /d "TRUE"
.\reg.exe add %C% /f /v "Bill_FullStatusEvent"		/t REG_SZ /d "STORE"
.\reg.exe add %C% /f /v "SEISA_CommandPreCheck"		/t REG_SZ /d "TRUE"
.\reg.exe add %C% /f /v "STATUSREAD_CommandPreCheck"	/t REG_SZ /d "TRUE"
if "%2"=="RT-300" (.\reg.exe add %C% /f /v "DeviceExitValue" 	/t REG_SZ /d "1")
