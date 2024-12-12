# Check and set execution policy
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -ne "RemoteSigned" -and $currentPolicy -ne "Unrestricted") {
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "✓ Execution policy set to RemoteSigned" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Failed to set execution policy" -ForegroundColor Red
        Write-Host "  Please run as Administrator: Set-ExecutionPolicy RemoteSigned" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "`n📦 Setting up Windows configuration..." -ForegroundColor Cyan

# Check for debug configuration
$debugConfigPath = "$env:USERPROFILE\win-setup-debug.json"
$debugMode = $false

if (Test-Path $debugConfigPath) {
    try {
        $debugConfig = Get-Content $debugConfigPath | ConvertFrom-Json
        $debugMode = $true
        Write-Host "🔧 Debug configuration found!" -ForegroundColor Yellow
    }
    catch {
        Write-Host "⚠️ Invalid debug configuration file, proceeding with normal installation" -ForegroundColor Yellow
    }
}

# Initialize variables
$repo = "esize/win-setup"
$branch = "main"
$setupDir = "$env:USERPROFILE\win-setup"
$steps = @(
    @{ Name = "Creating temporary directory"; Action = { 
        New-Item -ItemType Directory -Force -Path $setupDir | Out-Null 
    }}
    @{ Name = "Downloading setup files"; Action = {
        $zipUrl = "https://github.com/$repo/archive/refs/heads/$branch.zip"
        $zipFile = "$setupDir\repo.zip"
        $ProgressPreference = 'SilentlyContinue'
        $null = Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -UseBasicParsing
        $ProgressPreference = 'Continue'
    }}
    @{ Name = "Extracting files"; Action = {
        $ProgressPreference = 'SilentlyContinue'
        Expand-Archive -Path "$setupDir\repo.zip" -DestinationPath $setupDir -Force
        $ProgressPreference = 'Continue'
    }}
    @{ Name = "Preparing configuration"; Action = {
        $extractedDir = Get-ChildItem -Path $setupDir -Filter "win-setup-*" | Select-Object -First 1
        
        # If debug mode is enabled, copy debug configuration
        if ($debugMode) {
            $configDir = Join-Path $extractedDir.FullName "config"
            if (-not (Test-Path $configDir)) {
                New-Item -ItemType Directory -Force -Path $configDir | Out-Null
            }
            Copy-Item -Path $debugConfigPath -Destination (Join-Path $configDir "debug.json") -Force
        }
        
        Set-Location $extractedDir.FullName
    }}
)

# Execute steps with progress
$totalSteps = $steps.Count
$currentStep = 0

foreach ($step in $steps) {
    $currentStep++
    $percentComplete = [math]::Round(($currentStep / $totalSteps) * 100)
    
    Write-Host "  → $($step.Name)..." -NoNewline
    
    try {
        & $step.Action
        Write-Host "`r  ✓ $($step.Name)   " -ForegroundColor Green
    }
    catch {
        Write-Host "`r  ✗ $($step.Name)   " -ForegroundColor Red
        Write-Host "    Error: $_" -ForegroundColor Red
        
        # Cleanup on failure
        if (Test-Path $setupDir) {
            Remove-Item -Path $setupDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        exit 1
    }
}

Write-Host "`n🚀 Running configuration script..." -ForegroundColor Cyan
.\Configure-Windows.ps1

# Cleanup
Write-Host "`n🧹 Cleaning up..." -ForegroundColor Cyan
Start-Sleep -Seconds 2
Set-Location $env:USERPROFILE
Remove-Item -Path $setupDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  ✓ Cleanup complete" -ForegroundColor Green