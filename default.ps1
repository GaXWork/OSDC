<#PSScriptInfo
.VERSION 22.9.13.1
.GUID 9670c013-d1b1-4f5d-9bd0-0fa185b9f203
.AUTHOR David Segura @SeguraOSD
.COMPANYNAME osdcloud.com
.COPYRIGHT (c) 2022 David Segura osdcloud.com. All rights reserved.
.TAGS OSDeploy OSDCloud WinPE OOBE Windows AutoPilot
.LICENSEURI 
.PROJECTURI https://github.com/OSDeploy/OSD
.ICONURI 
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
Script should be executed in a Command Prompt using the following command
powershell Invoke-Expression -Command (Invoke-RestMethod -Uri sandbox.osdcloud.com)
This is abbreviated as
powershell iex (irm sandbox.osdcloud.com)
#>
<#
.SYNOPSIS
    PSCloudScript at sandbox.osdcloud.com
.DESCRIPTION
    PSCloudScript at sandbox.osdcloud.com
.NOTES
    Version 22.9.13.1
.LINK
    https://raw.githubusercontent.com/OSDeploy/OSD/master/cloud/sandbox.osdcloud.com.ps1
.EXAMPLE
    powershell iex (irm cmsaas.itrelation.dk/OSD.ps1)
#>
[CmdletBinding()]
param()
#=================================================
#Script Information
$ScriptName = 'enroll.itm8.com'
$ScriptVersion = '22.9.13.1'
#=================================================
#region Initialize

#Start the Transcript
$Transcript = "$((Get-Date).ToString('yyyy-MM-dd-HHmmss'))-OSDCloud.log"
$null = Start-Transcript -Path (Join-Path "$env:SystemRoot\Temp" $Transcript) -ErrorAction Ignore

#Determine the proper Windows environment
if ($env:SystemDrive -eq 'X:') {$WindowsPhase = 'WinPE'}
else {
    $ImageState = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Setup\State' -ErrorAction Ignore).ImageState
    if ($env:UserName -eq 'defaultuser0') {$WindowsPhase = 'OOBE'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_OOBE') {$WindowsPhase = 'Specialize'}
    elseif ($ImageState -eq 'IMAGE_STATE_SPECIALIZE_RESEAL_TO_AUDIT') {$WindowsPhase = 'AuditMode'}
    else {$WindowsPhase = 'Windows'}
}

function Show-Menu {
    Write-Host "Pick the customer:"
    foreach ($key in $menuOptions.Keys) {
        Write-Host "$key) $($menuOptions[$key])"
    }
}

#Finish initialization
Write-Host -ForegroundColor DarkGray "$ScriptName $ScriptVersion $WindowsPhase"

#Load OSDCloud Functions
Invoke-Expression -Command (Invoke-RestMethod -Uri functions.osdcloud.com)


# Get the Win32_ComputerSystem WMI class
#$computerSystem = Get-WmiObject -Class Win32_ComputerSystem
#If ($computerSystem.Model.ToLower() -like "*virtual*"){
#    Write-Host -ForegroundColor Red  "Virtual host dected, setting resolution."
#    Set-DisRes 1400
#}

#endregion
#=================================================
#region WinPE
if ($WindowsPhase -eq 'WinPE') {

# Check if Secure Boot is enabled
$secureBoot = Confirm-SecureBootUEFI

if (!$secureBoot) {
    Write-Host -ForegroundColor Red  "Secure Boot is disabled on this system. Go to the System BIOS to enable Secure Boot before installing."
    Write-Host -ForegroundColor Red  "If Secure Boot is already enabled in BIOS, try restoring factory keys, and try again"
        # Get the manufacturer of the system
        #$manufacturer = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty Manufacturer

        # Check if the manufacturer is Lenovo
        #if ($manufacturer -eq "LENOVO") {
        #    Write-Host "The manufacturer of this system is Lenovo"
        #    (gwmi -class Lenovo_SetBiosSetting –namespace root\wmi).SetBiosSetting("SecureBoot,Enable")
        #    (gwmi -class Lenovo_SaveBiosSettings -namespace root\wmi).SaveBiosSettings()            
        #}
        
    Start-Sleep -Seconds 300
    Exit
}

$disks = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType =3"
If (-not $Disks){
    Write-Host -ForegroundColor Red  "No disk detected, either the boot image is missing neccesary drivers, or the harddrive needs to be replaced."
    Start-Sleep -Seconds 300
    #ToDo - Send warning with model and serial number to teams.
    Exit       
}

$BrandName = 'ITM8'
$BrandColor = '#5A179B'
$OSLanguage = 'da-dk'
$OSName = 'Windows 11 23H2 x64'
$OSEdition = 'Pro'
$OSActivation = 'Retail'

$Global:MyOSDCloud = [ordered]@{
    Restart = [bool]$True
    RecoveryPartition = [bool]$true
    OEMActivation = [bool]$True
    WindowsUpdate = [bool]$true
    WindowsUpdateDrivers = [bool]$true
    WindowsDefenderUpdate = [bool]$true
    SetTimeZone = [bool]$true
    ClearDiskConfirm = [bool]$true
    ShutdownSetupComplete = [bool]$false
    SyncMSUpCatDriverUSB = [bool]$true
    CheckSHA1 = [bool]$true
}


$menuOptions = [ordered]@{
    "1" = "Default OSDCloud";
    "2" = "Arbejdermuseet";
    "3" = "Bactoforce International";
    "4" = "BlueFox";
    "5" = "Brødrene Kier A/S";
    "6" = "Center for Selvmordsforskning";
    "7" = "Charles Christensen A/S";
    "8" = "DANVA";
    "9" = "Deichmann Planter ApS";
    "10" = "Den Jyske Sangskole";
    "11" = "Danmarks Jægerforbund";
    "12" = "E. Michaelis & Co.";
    "13" = "Elka Rainwear A/S";
    "14" = "FM Bygningsdrift ApS";
    "15" = "Folkeferie.dk";
    "16" = "Forsikringsforbundet ";
    "17" = "Get Visual A/S";
    "18" = "Getama";
    "19" = "Hadsten Varmeværk A M B A";
    "20" = "Hedensted Gruppen A/S";
    "21" = "Jørgensen & Utoft A/S";
    "22" = "Kjøbenhavns Boldklub";
    "23" = "LINDLARSEN a/s";
    "24" = "Mette Munk A/S";
    "25" = "Uno-X Smøreolie A/S";
    "26" = "Palcut A/S";
    "27" = "Patentgruppen A/S";
    "28" = "Plushusene Management ApS";
    "29" = "Randstad";
    "30" = "RIB A/S";
    "31" = "Stenhøj Hydraulik A/S";
    "32" = "System Cleaners A/S";
    "33" = "System Standex A/S ";
    "34" = "Yab Yum Clothing co ApS";
    "35" = "Aarstiderne.com";
    

}

# Main script
do {
    Show-Menu
    $selection = Read-Host "Select the correct customer"
    
    switch ($selection) {
        "1" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])
        }
        "2" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])
            $OSName = 'Windows 11 24H2 x64'
        }
        "3" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "4" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "5" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "6" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "7" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "8" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "9" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "10" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "11" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "12" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "13" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "14" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "15" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "16" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "17" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "18" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "19" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "20" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "21" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "22" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "23" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "24" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "25" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "26" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "27" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "28" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "29" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "30" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "31" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "32" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "33" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "34" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        "35" {
            Write-Host "You selected: $($menuOptions[$selection])"
            $BrandName2 = $($menuOptions[$selection])            
        }
        
        default {
            Write-Host "Invalid selection. Please try again."
             $selection = $null
        }
    }


} while (-not $selection)


    Write-Host -ForegroundColor Green "Starting ITM8 OSDCloud "
    If ($selection -eq '1') {
        Start-OSDCloudGUI -BrandColor $Brandcolor -BrandName $BrandName
    }
    Else{
        Start-OSDCloud -OSName $OSName -OSEdition $OSEdition -OSActivation $OSActivation -OSLanguage $OSLanguage 
    }
    
    

    Write-Host -ForegroundColor Green "Downloading Tools..."    
    Write-Host -ForegroundColor Green "Downloading Process Explorer"   
    Invoke-WebRequest -URI 'https://live.sysinternals.com/procexp.exe' -OutFile 'C:\Windows\procexp.exe'
    Write-Host -ForegroundColor Green "Downloading cmtrace"   
    Invoke-WebRequest -URI 'https://cmsaas.itrelation.dk/cmtrace.exe' -OutFile 'C:\Windows\cmtrace.exe'

    start-sleep -seconds 60
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
#=================================================
#region Specialize
if ($WindowsPhase -eq 'Specialize') {
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
#=================================================
#region AuditMode
if ($WindowsPhase -eq 'AuditMode') {
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
#=================================================
#region OOBE
if ($WindowsPhase -eq 'OOBE') {


powershell iex (irm cmsaas.itrelation.dk/OSD.ps1)
Set-ExecutionPolicy RemoteSigned -Force
Install-Module AutopilotOOBE -Force -verbose
Import-Module AutopilotOOBE -Force -verbose
Start-AutopilotOOBE

    #Load everything needed to run AutoPilot and Azure KeyVault
    #osdcloud-StartOOBE -Display -Language -DateTime -Autopilot -KeyVault
    #osdcloud-StartOOBE -DateTime
    #Start-Process "C:\Windows\System32\oobe\windeploy.exe" -NoNewWindow -Wait
    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
#=================================================
#region Windows
if ($WindowsPhase -eq 'Windows') {

    #Load OSD and Azure stuff

    $null = Stop-Transcript -ErrorAction Ignore
}
#endregion
#=================================================
