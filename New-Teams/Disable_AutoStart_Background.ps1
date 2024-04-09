$Pkg =  Get-AppxPackage -Name "MSTeams" -ErrorAction SilentlyContinue
$RegKey = "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\$($Pkg.PackageFamilyName)\TeamsTfwStartupTask"

if ($null -ne $Pkg -and (Test-Path -Path $RegKey)) {
    Write-Host "Success - $($Pkg.PackageFamilyName) v$($Pkg.version) is installed and $RegKey exists"

    try {
	#Set parameter Value 0 not enable autostart - Value 1 not enable autostart and block check - Value 2 check autostart
        Set-ItemProperty -Path $RegKey -Name "State" -Value 1 -Force    
    }  catch {
        Write-Host "Setting State failed with error: $_"
    }

    try {
        #Set parameter Value 0 not enable UserEnabledStartupOnce - Value 1 not enable UserEnabledStartupOnce
        Set-ItemProperty -Path $RegKey -Name "UserEnabledStartupOnce" -Value 0 -Force
    }  catch {
        Write-Host "Setting UserEnabledStartupOnce failed with error: $_"
    }

    try{
    	#Modify "open_app_in_background":true to "open_app_in_background":false for disable Start on background and "open_app_in_background":false to "open_app_in_background":true for enable Start on Background
    	(Get-Content "$($ENV:LOCALAPPDATA)\Packages\$($Pkg.PackageFamilyName)\LocalCache\Microsoft\MSTeams\app_settings.json").replace('"open_app_in_background":true', '"open_app_in_background":false') | Set-Content "$($ENV:LOCALAPPDATA)\Packages\$($Pkg.PackageFamilyName)\LocalCache\Microsoft\MSTeams\app_settings.json"
    }
    catch{
	Write-Host "Setting open_app_in_background failed with error: $_"
    }          
        
} else { 

    Write-Host "Teams not installed or $RegKey does not exist"
    Exit 1

}