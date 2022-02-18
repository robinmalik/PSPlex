function Add-PlexItemToPlaylist
{
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$PlaylistID,

		[Parameter(Mandatory = $true)]
		[String]
		$ItemID,

		[Parameter(Mandatory = $true)]
		[String]
		$machineIdentifier
	)

	if($Null -eq $PlexConfigData.PlexServer)
	{
		throw "No saved configuration. Please run Get-PlexAuthenticationToken, then Save-PlexConfiguration first."
	}

	$RestEndpoint = "playlists/$PlaylistID/items?uri=server://$machineIdentifier/com.plexapp.plugins.library/library/metadata/$ItemID"


	#############################################################################
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Adding item to playlist."
	try
	{
		Invoke-RestMethod -Uri "$($PlexConfigData.Protocol)`://$($PlexConfigData.PlexServerHostname)`:$($PlexConfigData.Port)/$RestEndpoint`?&X-Plex-Token=$($PlexConfigData.Token)" -Method PUT -ErrorAction Stop | Out-Null
	}
	catch
	{
		throw $_
	}
}