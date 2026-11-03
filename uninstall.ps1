# author: Taehong Kim
# email: peppy0510@hotmail.com
#
# irm https://raw.githubusercontent.com/peppy0510/pwsh-venv-auto/master/uninstall.ps1 | iex
#
# Takes out what install.ps1 added and what the manual installation asks for: the profile block,
# an Import-Module pwsh-venv-auto line in any PowerShell 7 profile, and every installed version
# of the module. Profiles are backed up first. Works from Windows PowerShell too.

& {
    $ErrorActionPreference = 'Stop'
    $name = 'pwsh-venv-auto'
    $begin = "# >>> $name >>>"
    $end = "# <<< $name <<<"
    # Windows PowerShell has no $IsWindows, and is Windows only
    $windows = $IsWindows -or $PSVersionTable.PSEdition -eq 'Desktop'

    if (Get-Module $name) {
        # its OnRemove puts the previous LocationChangedAction back
        Remove-Module $name
        if ($env:VIRTUAL_ENV -and (Get-Command deactivate -ErrorAction SilentlyContinue)) { deactivate }
    }

    if ($windows) {
        $home7 = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell'
        $moduleRoots = @(Join-Path $home7 'Modules')
    } else {
        $home7 = Join-Path $HOME '.config/powershell'
        $moduleRoots = @(Join-Path $HOME '.local/share/powershell/Modules')
    }
    $separator = [System.IO.Path]::PathSeparator
    $moduleRoots += $env:PSModulePath -split $separator |
        Where-Object { $_ -and $_.StartsWith($HOME, [StringComparison]::OrdinalIgnoreCase) }

    $profiles = 'profile.ps1', 'Microsoft.PowerShell_profile.ps1', 'Microsoft.VSCode_profile.ps1' |
        ForEach-Object { Join-Path $home7 $_ }
    foreach ($profilePath in $profiles) {
        if (-not (Test-Path $profilePath)) { continue }
        $lines = @()
        $skip = $false
        foreach ($line in Get-Content $profilePath) {
            if ($line -eq $begin) { $skip = $true; continue }
            if ($line -eq $end) { $skip = $false; continue }
            if ($skip -or $line -match "^\s*Import-Module\s+$([regex]::Escape($name))\s*$") { continue }
            $lines += $line
        }
        $before = @(Get-Content $profilePath)
        if ($lines.Count -eq $before.Count) { continue }
        # the blank line install.ps1 put above its block
        if ($lines.Count -and $lines[-1] -eq '' -and $before[-1] -ne '') {
            $lines = if ($lines.Count -gt 1) { $lines[0..($lines.Count - 2)] } else { @() }
        }
        $backup = "$profilePath.bak-$name-$(Get-Date -Format yyyyMMddHHmmss)"
        Copy-Item $profilePath $backup
        Set-Content -Path $profilePath -Value $lines -Encoding utf8
        Write-Host "Removed $name from $profilePath (the previous one is $backup)"
    }

    foreach ($root in $moduleRoots | Select-Object -Unique) {
        $folder = Join-Path $root $name
        if (Test-Path $folder) {
            Remove-Item $folder -Recurse -Force
            Write-Host "Removed $folder"
        }
    }
    Write-Host 'Done. New sessions start without it.'
}
