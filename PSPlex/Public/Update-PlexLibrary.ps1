function Update-PlexLibrary
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

	$RestEndpoint = "library/sections/$Id/refresh"

	Write-Verbose -Message "Initiating library  for library Id $Id"
	try
	{
		Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?`X-Plex-Token=$($DefaultPlexServer.Token)" -Method GET -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
}