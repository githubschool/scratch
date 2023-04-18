## Created by Nikolay Boltyanski 2022-08
##
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}

if (!(Test-Path $env:userprofile\desktop\tools\systempower\wdckit.exe)) {
    Write-Host "The systempower folder doesn't exist" -ForegroundColor Red
    }
if (!(Test-Path .\wdckit.exe)) {
    Write-Host "wdckit.exe cannot be found!" -ForegroundColor Red
} 
if (Test-Path .\wdckit.exe) {
    Write-Host "wdckit.exe exists!" -ForegroundColor Green
    if (!(Test-Path $env:userprofile\desktop\tools\SystemPower)) {
        New-Item "$env:userprofile\desktop\tools\SystemPower" -ItemType Directory 
        Copy-Item "*.*" "$env:userprofile\desktop\tools\SystemPower" -Recurse
    }
} 
if (!(Test-Path \\10.0.56.14\images\Tools\batchfiles\SystemPower\wdckit.exe)) {
    Write-Host "The network path \\10.0.56.14\images\Tools\batchfiles\SystemPower doesn't exist!" -ForegroundColor Red
}
if (Test-Path \\10.0.56.14\images\Tools\batchfiles\SystemPower\wdckit.exe) {
    Write-Host "wdckit.exe exists!" -ForegroundColor Green
    if (!(Test-Path $env:userprofile\desktop\tools\SystemPower)) {
        New-Item "$env:userprofile\desktop\tools\SystemPower" -ItemType Directory
        Copy-Item "\\10.0.56.14\images\Tools\batchfiles\SystemPower\*" "$env:userprofile\desktop\tools\SystemPower" -Recurse    
    }
}
$OEM = ((Get-WmiObject -Class Win32_ComputerSystem).Manufacturer -split "\s+")[0]

if ($OEM -eq "Lenovo") {
    $model = (Get-WmiObject Win32_ComputerSystemProduct).version.trim()
    $model = $model.Replace("Lenovo", "").trim()
} else {
    #$Model = ((Get-Content .\systeminfo.txt | Select-String -pattern "System Model") -split ":")[1].trim()
    $Model = (Get-WmiObject -Class Win32_ComputerSystem).Model.trim()
}

$tModel = $Model

If ($Model -eq "All Series" -or $Model -eq "To be filled by O.E.M." -or $Model -eq "System Product Name") {
    $Model = "Non brand PC" + $PCtype + " no SERIAL NUMBER!!!"
    $tModel = 'Non_Brand_PC'
}

If ($OEM -eq "HP" -or $OEM -eq "Alienware") {
    $Platform = $Model
} Else {
    $Platform = $OEM + " " + $Model
}

$cputemp = (Get-WmiObject -Class Win32_Processor).name
if (($cputemp -split "\s+")[1] -eq "Gen") {
    
    $intelgen = ($cputemp -split "\s+")[0].Substring(0,2)
    $CPUBrand = ($cputemp -split "\s+")[2]
    $CPUType = ($cputemp -split "\s+")[3]
    $CPUName = ($cputemp -split "\s+")[4]
    $CPUFreq = ($cputemp -split "\s+")[5]
    $CPUVer = ($cputemp -split "\s+")[6]
    $NewCPUType=$true

} else {

    $CPUBrand = ($cputemp -split "\s+")[0]
    $CPUType = ($cputemp -split "\s+")[1]
    $CPUName = ($cputemp -split "\s+")[2]
    $CPUFreq = ($cputemp -split "\s+")[3]
    $CPUVer = ($cputemp -split "\s+")[4]
}


$DUTSN = @()
$DUTname = @()
$DUTVendorID = @()
$DUTFW = @()
$DUTCapacity = @()
$SSDType = @()
$LinkSpeed = @()

if (!(Test-Path $env:userprofile\desktop\tools\SystemPower\wdckit.exe)) {
    Write-Host "wdckit cannot be found. Please check!" -ForegroundColor Red
    Start-Sleep 10
    exit 
    } else {
    & "$env:userprofile\desktop\tools\SystemPower\wdckit.exe" show all --capacity-no-decimal --nobanner --output json 2>&1 | Tee-Object -Variable showalloutput | Out-Null
    $disksdata = $showalloutput | ConvertFrom-Json
    $disksdata.wdckit.results | Sort-Object DUT | % { $DUTSN += $_.'Serial Number'; $DUTCapacity += $_.Capacity.replace(' ', ''); $DUTName += $_.'Model Number'; $DUTFW += $_.Firmware; $DUTVendorID += $_.'Model Number'.Split(' ')[0].Trim(); $LinkSpeed += $_.'Lnk Spd Cap/Cur';$SSDType += $_.Port }
}

switch ($DUTCapacity) {
"256GB"     {   $DutCapacity=$DUTCapacity.Replace("GB","") }
"512GB"     {   $DutCapacity=$DUTCapacity.Replace("GB","") }
"1024GB"    {   $DutCapacity="1TB" }
"2048GB"    {   $DutCapacity="2TB" }
Default     {   $DutCapacity       }
}


switch ($OEM) {

"ASUSTeK"   {   $OEM="ASUS"
                $Name=$OEM+"-"+$DUTCapacity
            }
"Acer"      {   
                $Name=$OEM+"-"+$DUTCapacity
            }
"Dell"      {   
                $Name=$OEM+"-"+$DUTCapacity
            }
"LENOVO"    {   $OEM="Len"
                $Platform=$Platform.Replace("LENOVO","").Replace("ThinkPad X1","").Replace("Gen 1","").Replace("Gen 9","").Replace("  ","").Trim()
                $Name=$OEM+"-"+$Platform+$DUTCapacity
            }
"HP"        {   
                $Name=$OEM+"-"+$DUTCapacity
            }
"Microsoft" {
                $OEM="MSFT"
                #if ($LinkSpeed -like "*Gen3x4*") {$Gen="Gen3"}
                #if ($LinkSpeed -like "*Gen4x4*") {$Gen="Gen4"}
                switch ($LinkSpeed) {
                 "Gen3x4/Gen4x4"{$Gen="Gen4"}
                 "Gen4x4/Gen3x4"{$Gen="Gen3"}
                 "Gen3x4/Gen3x4"{$Gen="Gen3"}
                 "Gen4x4/Gen4x4"{$Gen="Gen4"}
                }
                if ($CPUBrand -eq "AMD") {
                    $Name=$OEM+"-"+$DUTCapacity+$CPUBrand
                } else {$Name=$OEM+"-"+$DUTCapacity+$Gen}
            }

}

Rename-Computer -NewName $Name -Restart -Confirm:$false -Force