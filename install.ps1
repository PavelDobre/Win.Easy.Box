$ErrorActionPreference = "Stop"

$ServiceName = "easybox"
$DisplayName = "EasyBox service"

$SourcePath = Split-Path -Parent $MyInvocation.MyCommand.Path

$AppDataPath = Join-Path $env:ProgramData "easybox"
$InstallPath = Join-Path $env:ProgramFiles "easybox"

New-Item -ItemType Directory -Force $AppDataPath | Out-Null
New-Item -ItemType Directory -Force $InstallPath | Out-Null

$SourceSingBox = Join-Path $SourcePath "sing-box.exe"
$SourceWintun = Join-Path $SourcePath "wintun.dll"
$SourceConfig = Join-Path $SourcePath "config.json"

$TargetSingBox = Join-Path $InstallPath "sing-box.exe"
$TargetWintun = Join-Path $InstallPath "wintun.dll"
$TargetConfig = Join-Path $AppDataPath "config.json"

Copy-Item $SourceSingBox $TargetSingBox -Force
Copy-Item $SourceWintun  $TargetWintun -Force
Copy-Item $SourceConfig  $TargetConfig -Force

$existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($existingService)
{
	
	if ($existingService.Status -ne "Stopped")
	{
		Stop-Service $ServiceName -Force
		Start-Sleep -Seconds 2
	}
	
	sc.exe delete $ServiceName | Out-Null
	Start-Sleep -Seconds 2
}

$BinPath = "`"$TargetSingBox`" run -c `"$TargetConfig`""


sc.exe create $ServiceName binPath= $BinPath start= demand DisplayName= $DisplayName # | Out-Null

sc.exe description $ServiceName "EasyBox backend service based on sing-box" | Out-Null

Write-Host ""
Write-Host "Service created successfully."
Write-Host ""