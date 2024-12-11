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

# Run configuration script
Set-Location $extractedDir.FullName
.\Configure-Windows.ps1

# Cleanup
Set-Location $env:USERPROFILE
Remove-Item -Path $setupDir -Recurse -Force 