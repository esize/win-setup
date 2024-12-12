# Check and set execution policy
$currentPolicy = Get-ExecutionPolicy
if ($currentPolicy -ne "RemoteSigned" -and $currentPolicy -ne "Unrestricted") {
    try {
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Write-Host "Execution policy has been set to RemoteSigned for current user." -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to set execution policy. Please run PowerShell as Administrator and run: Set-ExecutionPolicy RemoteSigned" -ForegroundColor Red
        exit 1
    }
}

# Download and execute script
$repo = "esize/win-setup"
$branch = "main"
$setupDir = "$env:USERPROFILE\win-setup"

# Create temporary directory
New-Item -ItemType Directory -Force -Path $setupDir | Out-Null

# Download repository as ZIP
$zipUrl = "https://github.com/$repo/archive/refs/heads/$branch.zip"
$zipFile = "$setupDir\repo.zip"
Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

# Extract ZIP
Expand-Archive -Path $zipFile -DestinationPath $setupDir -Force
$extractedDir = Get-ChildItem -Path $setupDir -Filter "win-setup-*" | Select-Object -First 1

# Get command line arguments for passing through to Configure-Windows.ps1
$scriptArgs = $MyInvocation.BoundParameters.Keys | ForEach-Object {
    "-$_ `"$($MyInvocation.BoundParameters[$_])`""
}

# Run configuration script
Set-Location $extractedDir.FullName
& .\Configure-Windows.ps1 $scriptArgs

# Cleanup
Start-Sleep -Seconds 2  # Give processes time to release handles
Set-Location $env:USERPROFILE
Remove-Item -Path $setupDir -Recurse -Force -ErrorAction SilentlyContinue