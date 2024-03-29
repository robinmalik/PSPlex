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

	[CmdletBinding(DefaultParameterSetName = "All")]
	param(
		[Parameter(Mandatory = $false, ParameterSetName = "Id")]
		[String]
		$Id,

		[Parameter(Mandatory = $false, ParameterSetName = "Name")]
		[String]
		$Name
	)

	#############################################################################
	#Region Import Plex Configuration
	if(!$script:PlexConfigData)
	{
		try
		{
			Import-PlexConfiguration -WhatIf:$False
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion

	#############################################################################
	#Region Make request
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
			if($Name)
			{
				$Data.MediaContainer.Directory | Where-Object -FilterScript { $_.title -eq $Name }
			}
			else
			{
				[array]$Results = $Data.MediaContainer.Directory
			}
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

	return $Results
}