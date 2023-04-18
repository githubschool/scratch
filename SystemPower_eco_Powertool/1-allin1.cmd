@echo off

rem ports for share in FW
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

rem Autologin
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v AutoAdminLogon /t REG_SZ /d 1 /f
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultUserName /t REG_SZ /d QA /f
REG ADD "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v DefaultPassword /t REG_SZ /d 12 /f

rem psexec policy
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\system /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f

rem Activation script
powershell -executionpolicy bypass -file .\activate_Winodws_Refresh_Key.ps1

rem Rename script
powershell -executionpolicy bypass -file .\renameplatform4power.ps1

