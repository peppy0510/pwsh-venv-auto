## pwsh-venv-auto

* PowerShell Module
* Automatically activate and deactivate Python Virtual Environment when you change directory
* Installed Virtual Environment directory name must be one of `venv`, `env`, `.venv`, `.env`

### Installation

```bash
Install-Module InstallModuleFromGit -Scope CurrentUser
Install-GitModule https://github.com/peppy0510/pwsh-venv-auto -Force
```

* Add following command to your PowerShell profile

```bash
Import-Module pwsh-venv-auto
```
