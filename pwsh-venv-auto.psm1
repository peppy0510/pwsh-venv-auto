$global:PSActivatedVenvPath = $null

function AutoActivate-Venv {
    $startPath = (Get-Location).Path
    if ($startPath -like "*\\wsl.localhost\*") { return }
    $venvNames = @("venv", "env", ".venv", ".env")
    $suffixName = "bin"
    if ($IsWindows) { $suffixName = "Scripts" }
    if ($env:VIRTUAL_ENV -and -not $global:PSActivatedVenvPath) {
        $separator = [System.IO.Path]::PathSeparator
        $inherited = @("bin", "Scripts") | ForEach-Object { Join-Path -Path $env:VIRTUAL_ENV -ChildPath $_ }
        $env:PATH = (($env:PATH -split $separator) | Where-Object { $inherited -notcontains $_ }) -join $separator
        Remove-Item Env:VIRTUAL_ENV, Env:VIRTUAL_ENV_PROMPT, Env:_OLD_VIRTUAL_PATH -ErrorAction SilentlyContinue
    }
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

$previousLocationChangedAction = $ExecutionContext.SessionState.InvokeCommand.LocationChangedAction
$ExecutionContext.SessionState.InvokeCommand.LocationChangedAction = {
    param($source, $eventArgs)
    if ($previousLocationChangedAction) { $previousLocationChangedAction.Invoke($source, $eventArgs) }
    AutoActivate-Venv
}
AutoActivate-Venv
