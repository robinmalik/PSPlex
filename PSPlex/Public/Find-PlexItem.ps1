function Find-PlexItem
{
	<#
		.SYNOPSIS
			This function uses the search ability of Plex find items on your Plex server.
		.DESCRIPTION
			This function uses the search ability of Plex find items on your Plex server.
			As objects returned have different properties depending on the type, there is
			an option to refine this by type.
		.PARAMETER ItemName
			Name of what you wish to find.
		.PARAMETER ItemType
			Refines the output by type.
		.PARAMETER Year
			Refine by year.
		.PARAMETER ExactNameMatch
			Return only items matching exactly what is specified as ItemName.
		.EXAMPLE
			# Find only 'movies' from the Plex server that (fuzzy)match 'The Dark Knight'.
			Find-PlexItem -ItemName 'The Dark Knight' -ItemType 'movie'
		.EXAMPLE
			# Find items that match exactly 'The Dark Knight' from the library 'Films'.
			Find-PlexItem -ItemName 'The Dark Knight' -ExactNameMatch -LibraryTitle 'Films'
		.EXAMPLE
			# Find items that (fuzzy)match 'Spider' from the library 'TV'.
			Find-PlexItem -ItemName 'spider' -LibraryTitle 'TV'
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$ItemName,

		[Parameter(Mandatory = $false)]
		[ValidateSet('movie', 'episode', 'album')]
		[String]
		$ItemType,

		[Parameter(Mandatory = $false)]
		[String]
		$LibraryTitle,

		[Parameter(Mandatory = $false)]
		[Int]
		$Year,

		[Parameter(Mandatory = $false)]
		[Switch]
		$ExactNameMatch
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
	#Region Construct Uri
	try
	{
		# URLEncode the title, otherwise we'll get '400 bad request' errors when searching for things like: Bill and Ted's ...
		$ItemNameEncoded = [System.Web.HttpUtility]::UrlEncode($ItemName)
		$Params = [Ordered]@{
			'includeCollections' = 0
			'sectionId'          = ''
			'query'              = $ItemNameEncoded
			'limit'              = 50
		}

		$DataUri = Get-PlexAPIUri -RestEndpoint "hubs/search" -Params $Params
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Make request
	Write-Verbose -Message "Searching for $ItemName."
	try
	{
		[Array]$Data = Invoke-RestMethod -Uri $DataUri -Method GET
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	# Refine by type:
	if($ItemType)
	{
		$Results = ($Data.MediaContainer.Hub | Where-Object { $_.type -eq $ItemType -and $_.Size -gt 0 }).Metadata
	}
	else
	{
		$Results = ($Data.MediaContainer.Hub | Where-Object { $_.Size -gt 0 }).Metadata
	}

	if($Results.Count -gt 0)
	{
		# Refine by the ItemName to attempt an exact match:
		if($ExactNameMatch)
		{
			[Array]$Results = $Results | Where-Object { $_.title -eq $ItemName }
			# There could still be more than one result with an exact title match due to the same item being in multiple libraries
			# or even in the same library!
			if($Results.count -gt 1)
			{
				Write-Warning -Message "Exact match was specified but there was more than 1 result for $ItemName."
			}
		}

		# Refine by library name:
		if($LibraryTitle)
		{
			# Sometimes they come back with 'reasonTitle'. Makes sense, not.
			Write-Verbose "Refining multiple results by library"
			[Array]$Results = $Results | Where-Object { $_.librarySectionTitle -eq $LibraryTitle -or $_.reasonTitle -eq $LibraryTitle }
		}

		if($Year)
		{
			#[Array]$Results = $Results | Where-Object { ($_.originallyAvailableAt.split('-')[0]) -match $Year }
			Write-Verbose "Refining results by Year: $Year"
			[Array]$Results = $Results | Where-Object { $_.year -eq $Year }
		}

		# Add datetime objects so we don't have to work with unixtimes...
		$Results | ForEach-Object {
			if($Null -ne $_.lastViewedAt) { $_ | Add-Member -NotePropertyName 'lastViewedAtDateTime' -NotePropertyValue (ConvertFrom-UnixTime $_.lastViewedAt) -Force }
			if($Null -ne $_.addedAt) { $_ | Add-Member -NotePropertyName 'addedAtDateTime' -NotePropertyValue (ConvertFrom-UnixTime $_.addedAt) -Force }
			if($Null -ne $_.updatedAt) { $_ | Add-Member -NotePropertyName 'updatedAtDateTime' -NotePropertyValue (ConvertFrom-UnixTime $_.updatedAt) -Force }
		}

		return $Results
	}
	else
	{
		Write-Verbose -Message "No result found."
		return
	}
}