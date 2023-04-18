#Created by Nikolay Boltyanski
#Based on the article: https://answers.microsoft.com/en-us/windows/forum/windows_10-windows_install/how-to-troubleshoot-product-activation-in-windows/33f31475-93b3-4d1c-812f-4b21fbd807a7
#Release date: 5-24-21

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}


function activate {
    Set-DnsClientServerAddress -InterfaceAlias ((Get-NetIPAddress | where {$_.PrefixOrigin -match "DHCP"}).InterfaceAlias) -ServerAddresses "10.86.1.1"
    $key=(Get-WmiObject SoftwareLicensingService | select OA3xOriginalProductKey).OA3xOriginalProductKey
    slmgr //B -ipk $key
    Timeout /T 10
    slmgr //B -ato
    Timeout /T 10 
    Set-DnsClientServerAddress -InterfaceAlias ((Get-NetIPAddress | where {$_.PrefixOrigin -match "DHCP"}).InterfaceAlias) -ResetServerAddresses
}


$str=(cscript //nologo "$env:systemroot\system32\slmgr.vbs" /dli | ? {$_ -match "License Status:"}).Replace("License Status:","").Trim() 
if ($str -ne "Licensed") {activate}
$str=(cscript //nologo "$env:systemroot\system32\slmgr.vbs" /dli | ? {$_ -match "License Status:"}).Replace("License Status:","").Trim() 
$curOSname = (Get-CimInstance -ClassName Win32_OperatingSystem -Namespace root/cimv2).Caption.trim()
$str=(cscript //nologo "$env:systemroot\system32\slmgr.vbs" /dli | ? {$_ -match "License Status:"}).Replace("License Status:","").Trim() 
if ($str -ne "Licensed") {
    $UserResponse2= [System.Windows.Forms.MessageBox]::Show("Your Windows is not ACTIVATED yet, but it should changed after restart. Do you want to restart?" , "Status" , 4)
    if ($UserResponse2 -eq "YES") {shutdown -r -t 0} else {exit}
}