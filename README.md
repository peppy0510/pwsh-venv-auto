## pwsh-venv-auto

* PowerShell module, PowerShell 6.2 or later on Windows and Linux
* Automatically activates the Python virtual environment of the project you change location into, and deactivates it when you leave
* Looks in the current location and each parent for `venv`, `env`, `.venv` or `.env` with `Scripts\Activate.ps1` on Windows or `bin/Activate.ps1` elsewhere; the nearest one wins
* Runs on every location change, whatever command makes it, through `LocationChangedAction`; drives that are not the file system, such as `Env:` or `HKCU:`, and `\\wsl.localhost` or `\\wsl$` paths are left alone
* On the next location change, a venv inherited from a parent shell is taken off `PATH`, and one activated by hand is closed with its own `deactivate`
* For zsh, use [zsh-venv-auto](https://github.com/peppy0510/zsh-venv-auto)

### Installation

```powershell
Install-Module InstallModuleFromGit -Scope CurrentUser
Install-GitModule https://github.com/peppy0510/pwsh-venv-auto -Force
```

* Add following command to your PowerShell profile

```powershell
Import-Module pwsh-venv-auto
```

### Update

```powershell
Install-GitModule https://github.com/peppy0510/pwsh-venv-auto -Force
```
