#
# Module manifest for module 'PSPlex'
#
# Generated by: bifa2
#
# Generated on: 05/07/2019
#

@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'PSPlex.psm1'

    # Version number of this module.
    ModuleVersion        = '1.0.15'

    # Supported PSEditions
    CompatiblePSEditions = 'Core', 'Desktop'

    # ID used to uniquely identify this module
    GUID                 = 'dcd8706d-00be-49ee-a942-505c06471bec'

    # Author of this module
    Author               = 'Robin Malik'

    # Company or vendor of this module
    CompanyName          = 'N/A'

    # Copyright statement for this module
    Copyright            = '(c) Robin Malik. All rights reserved.'

    # Description of the functionality provided by this module
    Description          = 'A PowerShell module to aid Plex server management.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion    = '5.1'

    # Name of the Windows PowerShell host required by this module
    # PowerShellHostName = ''

    # Minimum version of the Windows PowerShell host required by this module
    # PowerShellHostVersion = ''

    # Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # DotNetFrameworkVersion = ''

    # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    # CLRVersion = ''

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    # RequiredModules = @()

    # Assemblies that must be loaded prior to importing this module
    # RequiredAssemblies = @()

    # Script files (.ps1) that are run in the caller's environment prior to importing this module.
    # ScriptsToProcess = @()

    # Type files (.ps1xml) to be loaded when importing this module
    # TypesToProcess = @()

    # Format files (.ps1xml) to be loaded when importing this module
    FormatsToProcess     = @('PSPlex.format.ps1xml')

    # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
    # NestedModules = @()

    # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
    FunctionsToExport    = @(
        'Add-PlexItemToPlaylist'
        'Add-PlexLabel'
        'Copy-PlexPlaylist'
        'Find-PlexItem'
        'Get-PlexCollection'
        'Get-PlexItem'
        'Get-PlexLibrary'
        'Get-PlexPlaylist'
        'Get-PlexServer'
        'Get-PlexSession'
        'Get-PlexShare'
        'Get-PlexUser'
        'Get-PlexWatchHistory'
        'New-PlexPlaylist'
        'Remove-PlexCollection'
        'Remove-PlexPlaylist'
        'Remove-PlexLabel'
        'Remove-PlexShare'
        'Set-PlexConfiguration'
        'Set-PlexDefaultServer'
        'Set-PlexItemEdition'
        'Set-PlexItemRating'
        'Set-PlexItemWatchStatus'
        'Set-PlexWebhook'
        'Stop-PlexSession'
        'Update-PlexItemMetadata'
        'Update-PlexLibrary'
    )

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
    CmdletsToExport      = @()

    # Variables to export from this module
    VariablesToExport    = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
    AliasesToExport      = @()

    # DSC resources to export from this module
    # DscResourcesToExport = @()

    # List of all modules packaged with this module
    # ModuleList = @()

    # List of all files packaged with this module
    # FileList = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData          = @{

        PSData = @{

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags       = @('Plex')

            # A URL to the license for this module.
            # LicenseUri = ''

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/robinmalik/PSPlex'

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            # ReleaseNotes = ''

        } # End of PSData hashtable

    } # End of PrivateData hashtable

    # HelpInfo URI of this module
    # HelpInfoURI = ''

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''

}

