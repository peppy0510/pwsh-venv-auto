@{

# Script module or binary module file associated with this manifest.
RootModule = 'pwsh-venv-auto.psm1'

# Version number of this module.
ModuleVersion = '1.0.0'

# ID used to uniquely identify this module
GUID = 'ae38bedf-c2b6-4d18-a9ed-888f0446f90a'

# Author of this module
Author = 'Taehong Kim'

# Copyright statement for this module
Copyright = '(c) 2025 Taehong Kim'

# Description of the functionality provided by this module
Description = 'Automaticall activate and deactivate Python Virtual Environment when you change directory.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '5.0'

# Functions to export from this module
FunctionsToExport = @(
)

# Cmdlets to export from this module
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module
AliasesToExport = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess.
# This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{
    PSData = @{
        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @()

        # A URL to the license for this module.
        LicenseUri = ''

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/peppy0510/pwsh-venv-auto'

        # ReleaseNotes of this module
        ReleaseNotes = ''
    }
}
}
