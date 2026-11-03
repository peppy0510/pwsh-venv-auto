## pwsh-venv-auto

* PowerShell module, PowerShell 6.2 or later on Windows and Linux
* Automatically activates the Python virtual environment of the project you change location into, and deactivates it when you leave
* Looks in the current location and each parent for `venv`, `env`, `.venv` or `.env` with `Scripts\Activate.ps1` on Windows or `bin/Activate.ps1` elsewhere; the nearest one wins
* Runs on every location change, whatever command makes it, through `LocationChangedAction`; drives that are not the file system, such as `Env:` or `HKCU:`, and `\\wsl.localhost` or `\\wsl$` paths are left alone
* On the next location change, a venv inherited from a parent shell is taken off `PATH`, and one activated by hand is closed with its own `deactivate`
* For zsh, use [zsh-venv-auto](https://github.com/peppy0510/zsh-venv-auto)

### Installation

```powershell
irm https://raw.githubusercontent.com/peppy0510/pwsh-venv-auto/master/install.ps1 | iex
```

* Run it in PowerShell 7 (`pwsh`); Windows PowerShell 5.1 only gets a message pointing to [PowerShell 7](https://aka.ms/powershell)
* Downloads the module into your user module folder and appends a marked block to the end of your profile (`$PROFILE.CurrentUserAllHosts`), after a backup; the first activation has to come after every `PATH` change, as `deactivate` restores the `PATH` it saw
* Active in the current session right away

#### Manually

```powershell
Install-Module InstallModuleFromGit -Scope CurrentUser
Install-GitModule https://github.com/peppy0510/pwsh-venv-auto -Force
```

* Add following command to the end of your PowerShell profile

```powershell
Import-Module pwsh-venv-auto
```

### Update

* Run the installation command again, which also moves the block back to the end of the profile, or:

```powershell
Install-GitModule https://github.com/peppy0510/pwsh-venv-auto -Force
```

### Uninstall

```powershell
irm https://raw.githubusercontent.com/peppy0510/pwsh-venv-auto/master/uninstall.ps1 | iex
```

* Removes the block and any `Import-Module pwsh-venv-auto` line from your PowerShell 7 profiles, after backing them up, and every installed version of the module; also works from Windows PowerShell
