#Requires -RunAsAdministrator

<#
.SYNOPSIS
    Windows 11 Debloat Script for Clean Dev/Corporate Templates
.DESCRIPTION
    Removes bloatware, OneDrive, telemetry, and consumer features.
    Prepares Windows 11 for development use or sysprep templates.

    What it removes:
    - Bloatware apps (Bing, Xbox, Solitaire, Teams, Clipchamp, etc.)
    - OneDrive (complete removal including Explorer integration)
    - Telemetry and data collection
    - Consumer features (auto app installs, suggestions, tips)
    - Cortana and web search in Start Menu
    - Unnecessary services (Xbox, retail demo, telemetry)

    Settings applied to default user profile for sysprep compatibility.
.EXAMPLE
    .\Debloat-Windows.ps1
.NOTES
    Run as Administrator
    Reboot after running, then run Windows Update before sysprep

    Remote execution:
    irm https://raw.githubusercontent.com/kelomai/kelomai/main/win11-setup/Debloat-Windows.ps1 | iex
#>

# Clear error variable to track errors during execution
$Error.Clear()
$script:ScriptErrors = @()

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  🧹 Windows 11 Complete Debloat Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# ============================================================================
# SECTION 1: Remove Bloatware Apps
# ============================================================================
Write-Host "🗑️  [1/9] Removing bloatware apps..." -ForegroundColor Yellow

$bloatware = @(
	"Microsoft.BingNews"
	"Microsoft.BingWeather"
	"Microsoft.BingFinance"
	"Microsoft.BingSports"
	"Microsoft.GetHelp"
	"Microsoft.Getstarted"
	"Microsoft.Messaging"
	"Microsoft.Microsoft3DViewer"
	"Microsoft.MicrosoftOfficeHub"
	"Microsoft.MicrosoftSolitaireCollection"
	"Microsoft.MicrosoftStickyNotes"
	"Microsoft.MixedReality.Portal"
	"Microsoft.Office.OneNote"
	"Microsoft.Office.Sway"
	"Microsoft.OneConnect"
	"Microsoft.People"
	"Microsoft.Print3D"
	"Microsoft.SkypeApp"
	"Microsoft.StorePurchaseApp"
	"Microsoft.Todos"
	"Microsoft.Wallet"
	"Microsoft.Whiteboard"
	"Microsoft.WindowsAlarms"
	"Microsoft.WindowsCamera"
	"microsoft.windowscommunicationsapps"
	"Microsoft.WindowsFeedbackHub"
	"Microsoft.WindowsMaps"
	"Microsoft.WindowsSoundRecorder"
	"Microsoft.Xbox.TCUI"
	"Microsoft.XboxApp"
	"Microsoft.XboxGameOverlay"
	"Microsoft.XboxGamingOverlay"
	"Microsoft.XboxIdentityProvider"
	"Microsoft.XboxSpeechToTextOverlay"
	"Microsoft.YourPhone"
	"Microsoft.ZuneMusic"
	"Microsoft.ZuneVideo"
	"MicrosoftTeams"
	"Microsoft.Teams"
	"Clipchamp.Clipchamp"
	"*ActiproSoftwareLLC*"
	"*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
	"*Duolingo-LearnLanguagesforFree*"
	"*EclipseManager*"
	"*Facebook*"
	"*Instagram*"
	"*king.com.CandyCrushSaga*"
	"*king.com.CandyCrushSodaSaga*"
	"*PandoraMediaInc*"
	"*SpotifyAB.SpotifyMusic*"
	"*TikTok*"
	"*Twitter*"
	"*Wunderlist*"
	"*Flipboard*"
	"*Disney*"
	"*Netflix*"
	"*MinecraftUWP*"
	"*CyberLink*"
	"*Dolby*"
	"*DrawboardPDF*"
	"*March-of-Empires*"
	"*Plex*"
	"*Solitaire*"
	"*BubbleWitch*"
	"*Phototastic*"
	"*Shazam*"
)

foreach ($app in $bloatware) {
	Write-Host "  Removing: $app" -ForegroundColor Gray
	Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
	Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object DisplayName -like $app | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Host "  ✓ Bloatware removed" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 2: Remove OneDrive Completely
# ============================================================================
Write-Host "☁️  [2/9] Removing OneDrive..." -ForegroundColor Yellow

# Kill OneDrive process
Write-Host "  Stopping OneDrive process..." -ForegroundColor Gray
taskkill.exe /F /IM "OneDrive.exe" 2>$null
Start-Sleep -Seconds 2

# Uninstall OneDrive
Write-Host "  Uninstalling OneDrive..." -ForegroundColor Gray
if (Test-Path "$env:SystemRoot\System32\OneDriveSetup.exe") {
	Start-Process "$env:SystemRoot\System32\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -NoNewWindow
}
if (Test-Path "$env:SystemRoot\SysWOW64\OneDriveSetup.exe") {
	Start-Process "$env:SystemRoot\SysWOW64\OneDriveSetup.exe" -ArgumentList "/uninstall" -Wait -NoNewWindow
}
Start-Sleep -Seconds 2

# Remove OneDrive leftovers
Write-Host "  Removing OneDrive leftovers..." -ForegroundColor Gray
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:LOCALAPPDATA\Microsoft\OneDrive"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:PROGRAMDATA\Microsoft OneDrive"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "$env:USERPROFILE\OneDrive"
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue "C:\OneDriveTemp"

# Remove OneDrive from Explorer sidebar
Write-Host "  Removing OneDrive from Explorer..." -ForegroundColor Gray
New-PSDrive -PSProvider "Registry" -Root "HKEY_CLASSES_ROOT" -Name "HKCR" -ErrorAction SilentlyContinue | Out-Null
Remove-Item -Path "HKCR:\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue
Remove-Item -Path "HKCR:\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Recurse -ErrorAction SilentlyContinue

# Disable OneDrive via Group Policy
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Type DWord -Value 1

Write-Host "  ✓ OneDrive removed" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 3: Disable Telemetry and Data Collection
# ============================================================================
Write-Host "🔒 [3/9] Disabling telemetry and data collection..." -ForegroundColor Yellow

# Disable telemetry
Write-Host "  Disabling telemetry..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Type DWord -Value 0 -ErrorAction SilentlyContinue

# Disable activity history
Write-Host "  Disabling activity history..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Type DWord -Value 0

# Disable app diagnostics
Write-Host "  Disabling app diagnostics..." -ForegroundColor Gray
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack")) {
	New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtLevel" -Type DWord -Value 1

# Disable feedback
Write-Host "  Disabling feedback..." -ForegroundColor Gray
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {
	New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Type DWord -Value 1 -ErrorAction SilentlyContinue

# Disable advertising ID
Write-Host "  Disabling advertising ID..." -ForegroundColor Gray
if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
	New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0

# Disable location tracking
Write-Host "  Disabling location tracking..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {
	New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Type String -Value "Deny"

Write-Host "  ✓ Telemetry disabled" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 4: Disable Windows Consumer Features
# ============================================================================
Write-Host "🛒 [4/9] Disabling consumer features..." -ForegroundColor Yellow

# Disable consumer features (prevents automatic app installs)
Write-Host "  Disabling automatic app installs..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableSoftLanding" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsSpotlightFeatures" -Type DWord -Value 1

# Disable suggestions and tips
Write-Host "  Disabling suggestions and tips..." -ForegroundColor Gray
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "ContentDeliveryAllowed" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue

# Disable Start Menu suggestions
Write-Host "  Disabling Start Menu suggestions..." -ForegroundColor Gray
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_IrisRecommendations" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_AccountNotifications" -Type DWord -Value 0 -ErrorAction SilentlyContinue

Write-Host "  ✓ Consumer features disabled" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 5: Disable Cortana and Web Search
# ============================================================================
Write-Host "🔍 [5/9] Disabling Cortana and web search..." -ForegroundColor Yellow

# Disable Cortana
Write-Host "  Disabling Cortana..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWord -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Type DWord -Value 0

# Disable web search in Start Menu
Write-Host "  Disabling web search in Start Menu..." -ForegroundColor Gray
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWord -Value 0 -ErrorAction SilentlyContinue

Write-Host "  ✓ Cortana and web search disabled" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 6: Disable Unnecessary Services
# ============================================================================
Write-Host "⚙️  [6/9] Disabling unnecessary services..." -ForegroundColor Yellow

$services = @(
	"DiagTrack"                 # Connected User Experiences and Telemetry
	"dmwappushservice"          # WAP Push Message Routing Service
	"RetailDemo"                # Retail Demo Service
	"XblAuthManager"            # Xbox Live Auth Manager
	"XblGameSave"               # Xbox Live Game Save
	"XboxGipSvc"                # Xbox Accessory Management Service
	"XboxNetApiSvc"             # Xbox Live Networking Service
)

foreach ($service in $services) {
	Write-Host "  Disabling: $service" -ForegroundColor Gray
	Stop-Service $service -Force -ErrorAction SilentlyContinue
	Set-Service $service -StartupType Disabled -ErrorAction SilentlyContinue
}

Write-Host "  ✓ Services disabled" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 7: Additional Privacy and Performance Tweaks
# ============================================================================
Write-Host "🔧 [7/9] Applying additional tweaks..." -ForegroundColor Yellow

# Disable GameDVR
Write-Host "  Disabling Game DVR..." -ForegroundColor Gray
if (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Type DWord -Value 0

# Disable HomeGroup
Write-Host "  Disabling HomeGroup..." -ForegroundColor Gray
Stop-Service "HomeGroupListener" -Force -ErrorAction SilentlyContinue
Set-Service "HomeGroupListener" -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service "HomeGroupProvider" -Force -ErrorAction SilentlyContinue
Set-Service "HomeGroupProvider" -StartupType Disabled -ErrorAction SilentlyContinue

# Disable unnecessary scheduled tasks
Write-Host "  Disabling unnecessary scheduled tasks..." -ForegroundColor Gray
$tasks = @(
	"\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
	"\Microsoft\Windows\Application Experience\ProgramDataUpdater"
	"\Microsoft\Windows\Autochk\Proxy"
	"\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
	"\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
	"\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"
	"\Microsoft\Windows\Feedback\Siuf\DmClient"
	"\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload"
	"\Microsoft\Windows\Windows Error Reporting\QueueReporting"
)

foreach ($task in $tasks) {
	Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
}

# Disable Windows Spotlight
Write-Host "  Disabling Windows Spotlight..." -ForegroundColor Gray
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue

Write-Host "  ✓ Additional tweaks applied" -ForegroundColor Green
Write-Host ""

# ============================================================================
# SECTION 8: Apply Settings to Default User Profile (for Sysprep)
# ============================================================================
Write-Host "👥 [8/9] Applying settings to default user profile..." -ForegroundColor Yellow

# Load the default user registry hive
$defaultUserHive = "C:\Users\Default\NTUSER.DAT"
$tempKey = "HKU\DefaultUser"

Write-Host "  Loading default user hive..." -ForegroundColor Gray
reg load $tempKey $defaultUserHive 2>$null

if ($?) {
	# Apply all HKCU settings to the default user profile
	Write-Host "  Applying privacy settings to default profile..." -ForegroundColor Gray

	# Diagnostics
	if (!(Test-Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack")) {
		New-Item -Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Force | Out-Null
	}
	Set-ItemProperty -Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" -Name "ShowedToastAtLevel" -Type DWord -Value 1 -ErrorAction SilentlyContinue

	# Feedback
	if (!(Test-Path "Registry::$tempKey\SOFTWARE\Microsoft\Siuf\Rules")) {
		New-Item -Path "Registry::$tempKey\SOFTWARE\Microsoft\Siuf\Rules" -Force | Out-Null
	}
	Set-ItemProperty -Path "Registry::$tempKey\SOFTWARE\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Type DWord -Value 0 -ErrorAction SilentlyContinue

	# Advertising ID
	if (!(Test-Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {
		New-Item -Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
	}
	Set-ItemProperty -Path "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue

	# Content Delivery Manager (suggestions, tips, auto-installs)
	Write-Host "  Applying content delivery settings to default profile..." -ForegroundColor Gray
	$cdmPath = "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
	if (!(Test-Path $cdmPath)) {
		New-Item -Path $cdmPath -Force | Out-Null
	}
	Set-ItemProperty -Path $cdmPath -Name "ContentDeliveryAllowed" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "OemPreInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "PreInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "PreInstalledAppsEverEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SilentInstalledAppsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338387Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338388Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-338389Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SubscribedContent-353698Enabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "SystemPaneSuggestionsEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "RotatingLockScreenEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $cdmPath -Name "RotatingLockScreenOverlayEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue

	# Start Menu suggestions
	Write-Host "  Applying Start Menu settings to default profile..." -ForegroundColor Gray
	$explorerPath = "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
	if (!(Test-Path $explorerPath)) {
		New-Item -Path $explorerPath -Force | Out-Null
	}
	Set-ItemProperty -Path $explorerPath -Name "Start_IrisRecommendations" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $explorerPath -Name "Start_AccountNotifications" -Type DWord -Value 0 -ErrorAction SilentlyContinue

	# Search settings
	Write-Host "  Applying search settings to default profile..." -ForegroundColor Gray
	$searchPath = "Registry::$tempKey\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
	if (!(Test-Path $searchPath)) {
		New-Item -Path $searchPath -Force | Out-Null
	}
	Set-ItemProperty -Path $searchPath -Name "BingSearchEnabled" -Type DWord -Value 0 -ErrorAction SilentlyContinue
	Set-ItemProperty -Path $searchPath -Name "CortanaConsent" -Type DWord -Value 0 -ErrorAction SilentlyContinue

	# Unload the hive
	Write-Host "  Unloading default user hive..." -ForegroundColor Gray
	[gc]::Collect()
	Start-Sleep -Seconds 2
	reg unload $tempKey 2>$null

	Write-Host "  ✓ Default user profile configured" -ForegroundColor Green
} else {
	Write-Host "  ⚠ Could not load default user hive - skipping" -ForegroundColor Yellow
}
Write-Host ""

# ============================================================================
# SECTION 9: Clean Up
# ============================================================================
Write-Host "🧽 [9/9] Cleaning up..." -ForegroundColor Yellow

# Clear temporary files
Write-Host "  Clearing temporary files..." -ForegroundColor Gray
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

# Clear Windows Update cache
Write-Host "  Clearing Windows Update cache..." -ForegroundColor Gray
Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
Start-Service wuauserv -ErrorAction SilentlyContinue

Write-Host "  ✓ Cleanup complete" -ForegroundColor Green
Write-Host ""

# ============================================================================
# Complete
# ============================================================================
Write-Host "========================================" -ForegroundColor Green
Write-Host "  🎉 Debloat Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "  1. 🔄 Reboot Windows" -ForegroundColor White
Write-Host "  2. 📥 Run Windows Update one more time" -ForegroundColor White
Write-Host "  3. 💾 Run Sysprep: C:\Windows\System32\Sysprep\sysprep.exe /oobe /generalize /shutdown /mode:vm" -ForegroundColor White
Write-Host "  4. 📦 After shutdown, convert VM to template in Proxmox" -ForegroundColor White
Write-Host ""

# ============================================================================
# Error Summary
# ============================================================================
if ($Error.Count -gt 0) {
	Write-Host "========================================" -ForegroundColor Red
	Write-Host "  ⚠️  Errors Encountered: $($Error.Count)" -ForegroundColor Red
	Write-Host "========================================" -ForegroundColor Red
	Write-Host ""

	$errorIndex = 1
	foreach ($err in $Error) {
		Write-Host "[$errorIndex] $($err.CategoryInfo.Category): $($err.Exception.Message)" -ForegroundColor Yellow
		if ($err.InvocationInfo.ScriptLineNumber) {
			Write-Host "    Line $($err.InvocationInfo.ScriptLineNumber): $($err.InvocationInfo.Line.Trim())" -ForegroundColor Gray
		}
		Write-Host ""
		$errorIndex++
	}

	Write-Host "💡 Note: Most errors above are expected (e.g., apps not found, services not present)." -ForegroundColor Cyan
	Write-Host "   Review the errors to ensure no critical failures occurred." -ForegroundColor Cyan
	Write-Host ""
} else {
	Write-Host "========================================" -ForegroundColor Green
	Write-Host "  ✅ No errors encountered!" -ForegroundColor Green
	Write-Host "========================================" -ForegroundColor Green
	Write-Host ""
}