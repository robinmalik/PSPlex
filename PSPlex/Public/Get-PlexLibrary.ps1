function Get-PlexLibrary
{
	<#
		.SYNOPSIS
			By default, returns a list of libraries on a Plex server.
		.DESCRIPTION
			By default, returns a list of libraries on a Plex server.
			If -Id is specified, a single library is returned with
		.PARAMETER PlexServerHostname
			Fully qualified hostname for the Plex server (e.g. myserver.mydomain.com)
		.PARAMETER Protocol
			http or https
		.PARAMETER Port
			Parameter description
		.PARAMETER Id
			If specified, returns a specific library.
		.EXAMPLE
			Get-PlexLibrary
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $false)]
		[String]
		$Id
	)

	#############################################################################
	#Region Import Plex Configuration
	if(!$script:PlexConfigData)
	{
		try
		{
			Import-PlexConfiguration
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion

	#############################################################################
	#Region Get data
	try
	{
		$DataUri = Get-PlexAPIUri -RestEndpoint "library/sections/$Id"
		[array]$Data = Invoke-RestMethod -Uri $DataUri -Method GET
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
	#EndRegion

	return $Results
}