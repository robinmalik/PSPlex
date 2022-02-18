function Set-PlexItemWatchStatus
{
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $Id,

        [Parameter(Mandatory = $true)]
        [ValidateSet('played', 'unplayed')]
        [String]
        $Status
    )

    #Region Import Plex Configuration
    try
    {
        Import-PlexConfiguration
        $DefaultPlexServer = $PlexConfigData | Where-Object { $_.Default -eq $True }
    }
    catch
    {
        throw $_
    }
    #EndRegion


    if($Status -eq 'played')
    {
        $RestEndpoint = ":/scrobble"
    }
    else
    {
        $RestEndpoint = ":/unscrobble"
    }

    Write-Verbose -Message "Setting watch status for item Id $Id to $Status"
    try
    {
        Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?identifier=com.plexapp.plugins.library&key=$($Id)&X-Plex-Token=$($DefaultPlexServer.Token)" -Method "GET" | Out-Null
    }
    catch
    {
        throw $_
    }
}