$Service = Get-Service -Name WinRM

Write-Host "Service Name :" $Service.Name
Write-Host "Status       :" $Service.Status