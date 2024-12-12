function Test-AdminRights {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if running with admin rights
$isAdmin = Test-AdminRights

if ($isAdmin) {
    Write-InfoLog "Script is running with administrative privileges."
    exit 0
} else {
    Write-ErrorLog "Script is NOT running with administrative privileges!"
    Write-WarningLog "Please run this script as Administrator."
    exit 1
}
