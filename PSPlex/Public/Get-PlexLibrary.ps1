function Get-PlexLibrary
{
	<#
		.SYNOPSIS
		By default, returns a list of libraries on a Plex server.

		.DESCRIPTION
		By default, returns a list of libraries on a Plex server.
		If -ID is specified, a single library is returned with

		.PARAMETER PlexServerHostname
		Fully qualified hostname for the Plex server (e.g. myserver.mydomain.com)

		.PARAMETER Protocol
		http or https

		.PARAMETER Port
		Parameter description

		.PARAMETER ID
		If specified, returns a specific library.

		.EXAMPLE
		Get-PlexLibrary
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $false)]
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


	#############################################################################
	$RestEndpoint = "library/sections/$Id"


	#############################################################################
	try
	{
		[array]$Data = Invoke-RestMethod -Uri "$($DefaultPlexServer.Protocol)`://$($DefaultPlexServer.PlexServerHostname)`:$($DefaultPlexServer.Port)/$RestEndpoint`?`X-Plex-Token=$($DefaultPlexServer.Token)" -Method GET
		if($Id)
		{
			[array]$Results = $Data.MediaContainer
		}
		else
		{
			[array]$Results = $Data.MediaContainer.Directory
		}
	}
	catch
	{
		throw $_
	}

	return $Results
}