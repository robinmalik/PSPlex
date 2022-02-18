function Remove-PlexPlaylist
{
	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id,

		[Parameter(Mandatory = $false)]
		[String]
		$AlternativeToken
	)

	#############################################################################
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

	$RestEndpoint = "playlists/$Id"

	#############################################################################
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Removing playlist"
	try
	{
		if($AlternativeToken)
		{
			$Token = $AlternativeToken
		}
		else
		{
			$Token = $DefaultPlexServer.Token
		}

		Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?`X-Plex-Token=$Token" -Method DELETE -ErrorAction Stop | Out-Null
	}
	catch
	{
		throw $_
	}
}