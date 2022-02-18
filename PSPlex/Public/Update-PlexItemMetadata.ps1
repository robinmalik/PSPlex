function Update-PlexItemMetadata
{
	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id
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

	$RestEndpoint = "library/metadata/$Id/refresh"

	Write-Verbose -Message "Initiating metadata refresh for item Id $Id"
	try
	{
		Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?`X-Plex-Token=$($DefaultPlexServer.Token)" -Method PUT -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
}