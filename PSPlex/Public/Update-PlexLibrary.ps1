function Update-PlexLibrary
{
	<#
		.SYNOPSIS
			Initiates an update on a library.
		.DESCRIPTION
			Initiates an update on a library.
		.PARAMETER Id
			The Id of the library to update.
		.EXAMPLE
			Update-PlexLibrary -Id 123
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id
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
	#Region Update
	Write-Verbose -Message "Initiating library update for library Id $Id"
	try
	{
		$Uri = Get-PlexAPIUri -RestEndpoint "library/sections/$Id/refresh" -Token $AlternativeToken
		Invoke-RestMethod -Uri $Uri -Method GET -ErrorAction Stop
	}
	catch
	{
		throw $_
	}
	#EndRegion
}