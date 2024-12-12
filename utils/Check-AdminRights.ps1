function Test-AdminRights {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Check if running with admin rights
$isAdmin = Test-AdminRights

if ($isAdmin) {
    Write-Log "Script is running with administrative privileges." -Level Success
    exit 0
} else {
    Write-Log "Script is NOT running with administrative privileges!" -Level Error
    Write-Log "Please run this script as Administrator." -Level Warning
    exit 1
}
