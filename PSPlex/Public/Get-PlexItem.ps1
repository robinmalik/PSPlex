function Get-PlexItem
{
	<#
		.SYNOPSIS
			Get a specific item.
		.DESCRIPTION
			Get a specific item.
		.PARAMETER Id
			The id of the item.
		.PARAMETER IncludeTracks
			Only valid for albums. If specified, the tracks in the album are returned.
		.PARAMETER LibraryTitle
			Gets all items from a library with the specified title.
		.EXAMPLE
			# Get a single item by Id:
			Get-PlexItem -Id 204
		.EXAMPLE
			# Get all items from the library called 'Films'.
			# NOTE: Not all data for an item is returned this way.
			$Items = Get-PlexItem -LibraryTitle Films

			# Get all data for the above items:
			$AllData = $Items | % { Get-PlexItem -Id $_.ratingKey }
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = 'Id')]
		[String]
		$Id,

		[Parameter(Mandatory = $false, ParameterSetName = 'Id')]
		[Switch]
		$IncludeTracks,

		[Parameter(Mandatory = $true, ParameterSetName = 'Library')]
		[String]
		$LibraryTitle
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
	if($Id)
	{
		$DataUri = Get-PlexAPIUri -RestEndpoint "library/metadata/$Id"
	}
	elseif($LibraryTitle)
	{
		# Get the library to determine what type it is:
		$Library = Get-PlexLibrary | Where-Object { $_.title -eq $LibraryTitle }

		# If we were to support lookup of a library by Id we have to consider
		# that it returns with no TYPE attribute, so we couldn't construct params correctly.
		# or KEY (presented as librarySectionID).

		if(!$Library)
		{
			throw "No such library. Run Get-PlexLibrary to see a list."
		}
		else
		{
			if($Library.key)
			{
				$Key = $Library.key
			}
			elseif($Library.librarySectionID)
			{
				$Key = $Library.librarySectionID
			}
			else
			{
				throw "Unable to determine library key/id/sectionId"
			}

			$Params = [Ordered]@{
				sort         = 'titleSort'
				#includeCollections = 1
				#includeExternalMedia = 0
				includeGuids = 1
			}
			$DataUri = Get-PlexAPIUri -RestEndpoint "library/sections/$Key/all" -Params $Params
		}
	}
	else {}
	#EndRegion

	#############################################################################
	#Region Get data
	try
	{
		$Data = Invoke-RestMethod -Uri $DataUri -Method GET

		# The metadata returned from Plex often contains duplicate values which breaks the (inherent) conversion into JSON, ending up as a string. Known cases:
		# guid and Guid
		# rating and Rating
		# The uppercase versions seem to be arrays of richer data, e.g. Guid contains IDs from various other metadata sources, as does Rating.

		# This isn't always the case however, so we need to check the object type:
		if($Data.gettype().Name -eq 'String')
		{
			# Let's go with renaming the lowercase keys. Using .Replace rather than -replace as it should be faster.
			$Data = $Data.toString().Replace('"guid"', '"_guid"').Replace('"rating"', '"_rating"')
			# Convert back into JSON:
			$Data = $Data | ConvertFrom-Json
		}
		else
		{
			# $Data should be JSON already.
		}

		# If this is an album, respect -IncludeTracks and get track data:
		if($Data.MediaContainer.Metadata.type -eq 'album' -and $IncludeTracks)
		{
			Write-Verbose -Message "Making additional lookup for album tracks"
			# $Data returned above has a key property on albums which equals: /library/metadata/{ratingKey}/children
			$TrackURi = Get-PlexAPIUri -RestEndpoint $Data.MediaContainer.Metadata.key
			$ChildData = Invoke-RestMethod -Uri $TrackURi -Method GET
			# Append:
			$Data.MediaContainer.Metadata | Add-Member -MemberType NoteProperty -Name 'Tracks' -Value $ChildData.MediaContainer.Metadata
		}

		# Return the required subproperty:
		return $Data.MediaContainer.Metadata
	}
	catch
	{
		throw $_
	}
	#EndRegion
}