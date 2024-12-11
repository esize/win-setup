function Test-AdminRights {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if running with admin rights
$isAdmin = Test-AdminRights

if ($isAdmin) {
    Write-Host "Script is running with administrative privileges." -ForegroundColor Green
    exit 0
} else {
    Write-Host "Script is NOT running with administrative privileges!" -ForegroundColor Red
    Write-Host "Please run this script as Administrator." -ForegroundColor Yellow
    exit 1
}
