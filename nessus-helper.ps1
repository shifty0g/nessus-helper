$VERSION="1.0"
$DATE="06-04-21"
# simple script to enabled/disable the changes needed to get a nessus scan to work 

#############
# To Do
#############


function Run-Enable {
# this function enables all the required b

Write-Host "[->] Backing up Registry - HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System`n" -ForegroundColor Green -BackgroundColor Black
reg export "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" C:\system.reg
Write-Host # new line

Write-Host "[->] Setting LocalAccountTokenFilterPolicy = 1 in the Registry`n" -ForegroundColor Green -BackgroundColor Black
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'LocalAccountTokenFilterPolicy' -Value 1 -PropertyType DWORD -Force | Out-Null
Write-Host # new line

Write-Host "[->] Starting WMI Service`n" -ForegroundColor Green -BackgroundColor Black
(gwmi win32_service -filter "name='Winmgmt'").startservice()
Write-Host # new line

Write-Host "[->] Starting RemoteRegistry Service`n" -ForegroundColor Green -BackgroundColor Black
(gwmi win32_service -filter "name='RemoteRegistry'").startservice()
Write-Host # new line

Write-Host "[->] Setting RemoteRegistry StartMode to Manual`n" -ForegroundColor Green -BackgroundColor Black
(gwmi win32_service -filter "name='RemoteRegistry'").ChangeStartMode("Manual")
Write-Host # new line

Write-Host "[->] Windows Firewall - Backing up Policy C:\advfirewallpolicy.wfw`n" -ForegroundColor Green -BackgroundColor Black
netsh advfirewall export C:\advfirewallpolicy.wfw
Write-Host # new line

Write-Host "[->] Windows Firewall - Enabling File and Printer Sharing group`n" -ForegroundColor Green -BackgroundColor Black
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes
Write-Host # new line


$choice = ""
while ($choice -notmatch "[y|n]"){
    $choice = read-host "Do you want to create the 'pentest' admin account? (Y/N)"
	Write-Host # new line
    }

if ($choice -eq "y"){
	Write-Host "[->] Creating 'pentest' user` and adding to local administrators group `n" -ForegroundColor Green -BackgroundColor Black
	$Expire = (get-date).AddDays(+7).ToString("dd/MM/yyy")
	net user pentest 5f4fH56vD43vh6 /add
	net user pentest /active:yes /comment:"TEMP account for pentest - expires on $Expire" /expires:$Expire
	net localgroup administrators pentest /add
	net user pentest
    }
Write-Host
Write-Host "FINISHED" -ForegroundColor Yellow 
Write-Host "Make sure you run the DISABLE script after testing!" -ForegroundColor Yellow 



}
function Run-Disable {
Write-Host "[->] Importing backed up Registy - C:\system.reg`n" -ForegroundColor Magenta -BackgroundColor Black
reg import C:\system.reg
Write-Host # new line

Write-Host "[->] Deleting C:\system.reg`n" -ForegroundColor Magenta -BackgroundColor Black
Remove-Item C:\system.reg
Write-Host # new line

Write-Host "[->] Stopping RemoteRegistry Service`n" -ForegroundColor Magenta -BackgroundColor Black
(gwmi win32_service -filter "name='RemoteRegistry'").stopservice()
Write-Host # new line

Write-Host "[->] Setting RemoteRegistry StartMode to Disabled`n" -ForegroundColor Magenta -BackgroundColor Black
(gwmi win32_service -filter "name='RemoteRegistry'").ChangeStartMode("Disabled")
Write-Host # new line

Write-Host "[->] Windows Firewall - Importing Policy C:\advfirewallpolicy.wfw`n" -ForegroundColor Magenta -BackgroundColor Black
netsh advfirewall import C:\advfirewallpolicy.wfw
Write-Host # new line

Write-Host "[->] Deleting C:\advfirewallpolicy.wfw`n" -ForegroundColor Magenta -BackgroundColor Black
Remove-Item C:\advfirewallpolicy.wfw
Write-Host # new line

Write-Host "[->] Removing 'pentest' user`n" -ForegroundColor Magenta -BackgroundColor Black
net user pentest /active:no
net user pentest /delete
Write-Host # new line

# show pentest user to check
net user 
Write-Host # new line

# add a search for the downloaded CE files to delete
# not yet done

Write-Host "-> Restoring Powershell Execution Policy - Restricted`n" -ForegroundColor Magenta -BackgroundColor Black
Set-ExecutionPolicy -ExecutionPolicy Restricted

Write-Host "FINISHED" -ForegroundColor Yellow 
}

function Help {
Write-Host "Nessus-Helper - "$VERSION -ForegroundColor Black -BackgroundColor Green
    Write-Output "--------------------------------"
    Write-Output "USE: "
    Write-Output ""
    Write-Output "./nessus-helper.ps1 [OPTIONS]"
    Write-Output ""
    Write-Output "OPTIONS:"
    Write-Output ""
    Write-Output "     enable         run ALL enable changes (FW, LocalTokenPolicy, Creates Admin user" 
    Write-Output "     disable        restores changed made from enable script"
	Write-Output ""
	Write-Output ""
}



######
# MAIN
######
clear

# check if running as admin
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
	Write-Host -ForegroundColor Red -BackgroundColor Black "######## ########  ########   #######  ########                     "
	Write-Host -ForegroundColor Red -BackgroundColor Black "##       ##     ## ##     ## ##     ## ##     ##                    "
	Write-Host -ForegroundColor Red -BackgroundColor Black "##       ##     ## ##     ## ##     ## ##     ##                    "
	Write-Host -ForegroundColor Red -BackgroundColor Black "######   ########  ########  ##     ## ########                     "
	Write-Host -ForegroundColor Red -BackgroundColor Black "##       ##   ##   ##   ##   ##     ## ##   ##                      "
	Write-Host -ForegroundColor Red -BackgroundColor Black "##       ##    ##  ##    ##  ##     ## ##    ##                     "
	Write-Host -ForegroundColor Red -BackgroundColor Black "######## ##     ## ##     ##  #######  ##     ##                    "
	Write-Host -ForegroundColor Red -BackgroundColor Black "                                                                    "
	Write-Host -ForegroundColor Red -BackgroundColor Black "                                                                    "
	Write-Host -ForegroundColor Red -BackgroundColor Black "############ ERROR: ADMINISTRATOR PRIVILEGES REQUIRED ##############"
	Write-Host -ForegroundColor Red -BackgroundColor Black "This script must be run as administrator to work properly!          "
	Write-Host -ForegroundColor Red -BackgroundColor Black "If you're seeing this after clicking on a start menu icon,          "
	Write-Host -ForegroundColor Red -BackgroundColor Black "then right click on the shortcut and select 'Run As Administrator'. "
	Write-Host -ForegroundColor Red -BackgroundColor Black "####################################################################"
    Break
}

# check the switches and run 
switch ($args[0]) {
   "enable" {Run-Enable; break}
   "disable"  {Run-Disable; break}
   default {Help; break}
}
