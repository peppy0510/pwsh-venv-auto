# author: Taehong Kim
# email: peppy0510@hotmail.com
#
# irm https://raw.githubusercontent.com/peppy0510/pwsh-venv-auto/master/install.ps1 | iex
#
# Downloads the module into the user's module folder and appends a block to the end of the
# profile: the first activation has to come after every PATH change there, as deactivate restores
# the PATH it saw. Running it again updates the module and moves the block back to the end.

& {
    $ErrorActionPreference = 'Stop'
    $name = 'pwsh-venv-auto'
    $branch = if ($env:PWSH_VENV_AUTO_BRANCH) { $env:PWSH_VENV_AUTO_BRANCH } else { 'master' }
    $base = "https://raw.githubusercontent.com/peppy0510/$name/$branch"
    $begin = "# >>> $name >>>"
    $end = "# <<< $name <<<"

    if ($PSVersionTable.PSVersion -lt [version]'6.2') {
        Write-Host "$name needs PowerShell 7 (pwsh); this is Windows PowerShell $($PSVersionTable.PSVersion)." -ForegroundColor Yellow
        Write-Host 'Install PowerShell 7 from https://aka.ms/powershell, then run this command again in pwsh.' -ForegroundColor Yellow
        return
    }

    $separator = [System.IO.Path]::PathSeparator
    $modules = $env:PSModulePath -split $separator |
        Where-Object { $_ -and $_.StartsWith($HOME, [StringComparison]::OrdinalIgnoreCase) } |
        Select-Object -First 1
    if (-not $modules) {
        $modules = if ($IsWindows) { Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell\Modules' }
                   else { Join-Path $HOME '.local/share/powershell/Modules' }
    }

    $manifest = (Invoke-WebRequest "$base/$name.psd1" -UseBasicParsing).Content
    $version = [regex]::Match($manifest, "ModuleVersion\s*=\s*'([^']+)'").Groups[1].Value
    if (-not $version) { throw "could not read the module version from $base/$name.psd1" }
    $target = Join-Path (Join-Path $modules $name) $version
    New-Item -ItemType Directory -Path $target -Force | Out-Null
    foreach ($file in "$name.psd1", "$name.psm1") {
        Invoke-WebRequest "$base/$file" -OutFile (Join-Path $target $file) -UseBasicParsing
    }
    # downloaded files would be refused under the RemoteSigned policy
    if ($IsWindows) { Get-ChildItem $target | Unblock-File }

    $profilePath = $PROFILE.CurrentUserAllHosts
    $backup = $null
    $lines = @()
    if (Test-Path $profilePath) {
        $backup = "$profilePath.bak-$name-$(Get-Date -Format yyyyMMddHHmmss)"
        Copy-Item $profilePath $backup
        # an earlier block goes, so the new one lands below whatever was added since
        $skip = $false
        foreach ($line in Get-Content $profilePath) {
            if ($line -eq $begin) { $skip = $true; continue }
            if ($line -eq $end) { $skip = $false; continue }
            if (-not $skip) { $lines += $line }
        }
    } else {
        New-Item -ItemType Directory -Path (Split-Path $profilePath) -Force | Out-Null
    }
    $lines += '', $begin, "Import-Module $name", $end
    Set-Content -Path $profilePath -Value $lines -Encoding utf8

    Import-Module $name -Force -Global
    Write-Host "Installed $name $version to $target"
    if ($backup) {
        Write-Host "Added it to the end of $profilePath (the previous one is $backup)"
    } else {
        Write-Host "Created $profilePath"
    }
    Write-Host 'It is active in this session already; new sessions load it from the profile.'
}
