
$global:PSActivatedVenvPath = $null

function AutoActivate-Venv {
    $startPath = (Get-Location).Path    
    $venvNames = @("venv", "env", ".venv", ".env")
    $suffixName = "bin"
    if ($IsWindows) { $suffixName = "Scripts" }
    for ($i=0; $i -lt $venvNames.Length; $i++) {
        $venvNames[$i] = Join-Path -Path $venvNames[$i] -ChildPath $suffixName
    }
    $path = $startPath
    $venvFound = $null
    $rootPath = [System.IO.Path]::GetPathRoot($path)
    while ($path -ne $rootPath) {
        foreach ($name in $venvNames) {
            $candidate = Join-Path -Path $path -ChildPath $name
            $activateScript = Join-Path -Path $candidate -ChildPath "Activate.ps1"
            if (Test-Path $activateScript) {
                $venvFound = $activateScript
                break
            }
            $activateScript = Join-Path -Path $candidate -ChildPath "activate.ps1"
            if (Test-Path $activateScript) {
                $venvFound = $activateScript
                break
            }
        }
        if ($venvFound) { break }
        $path = Split-Path $path -Parent
        if (-not $path) { $path = $rootPath }
    }
    if ($venvFound) {
        if ($global:PSActivatedVenvPath -ne $venvFound) {
            if ($global:PSActivatedVenvPath) {
                try {
                    deactivate
                } catch {}
            }
            . $venvFound
            $global:PSActivatedVenvPath = $venvFound
        }
    } else {
        if ($global:PSActivatedVenvPath) {
            try {
                deactivate
            } catch {}
            $global:PSActivatedVenvPath = $null
        }
    }
}

function global:Set-Location {
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Path
    )
    Microsoft.PowerShell.Management\Set-Location -Path $Path
    AutoActivate-Venv
}

AutoActivate-Venv
