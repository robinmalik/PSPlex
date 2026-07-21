function Get-PlexLibrary
{
	<#
		.SYNOPSIS
			By default, returns a list of libraries on a Plex server.
		.DESCRIPTION
			By default, returns a list of libraries on a Plex server.
			If -Id is specified, a single library is returned with
		.PARAMETER Id
			If specified, returns a specific library.
		.PARAMETER Name
			If specified, returns a specific library by name.
		.EXAMPLE
			# Returns all libraries on the default Plex server.
			Get-PlexLibrary
		.EXAMPLE
			# Returns the library with Id 1 on the default Plex server.
			Get-PlexLibrary -Id 1
		.EXAMPLE
			# Returns the library with name "Movies" on the default Plex server.
			Get-PlexLibrary -Name "Movies"
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
			Import-PlexConfiguration
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
		<#
			When querying /sections Plex returns a MediaContainer object with a Directory property that contains the list of libraries.
			Querying /sections/{id} Plex returns a MediaContainer object with a Directory property that contains a different set of properties
			like 'title1' instead of 'title', which then breaks output formatting with the default view.
			Fall back to in-line filtering.
		#>
		[array]$global:Data = Invoke-PlexRequest -RestEndpoint "library/sections" -Method GET
		if($Id)
		{
			[array]$Results = $Data.MediaContainer.Directory | Where-Object -FilterScript { $_.key -eq $Id }
		}
		elseif($Name)
		{
			[array]$Results = $Data.MediaContainer.Directory | Where-Object -FilterScript { $_.title -eq $Name }
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

	#############################################################################
	# Append type and return results
	$Results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.Library") }
	return $Results
}