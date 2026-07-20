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

	[CmdletBinding()]
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
			Import-PlexConfiguration
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
		$RestEndpoint = "library/metadata/$Id"
		$Params = $Null
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
				sort                        = 'titleSort'
				includeGuids                = 1
				includeConcerts             = 0
				includeExtras               = 0
				includeOnDeck               = 0
				includePopularLeaves        = 0
				includePreferences          = 0
				includeReviews              = 0
				includeChapters             = 0
				includeStations             = 0
				includeExternalMedia        = 0
				asyncAugmentMetadata        = 0
				asyncCheckFiles             = 0
				asyncRefreshAnalysis        = 0
				asyncRefreshLocalMediaAgent = 0
			}
			$RestEndpoint = "library/sections/$Key/all"
		}
	}
	else {}
	#EndRegion

	#############################################################################
	#Region Get data
	try
	{
		$Data = Invoke-PlexRequest -RestEndpoint $RestEndpoint -Params $Params -Method GET

		# If this is an album, respect -IncludeTracks and get track data:
		if($Data.MediaContainer.Metadata.type -eq 'album' -and $IncludeTracks)
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Making additional lookup for album tracks"
			# $Data returned above has a key property on albums which equals: /library/metadata/{ratingKey}/children
			$ChildData = Invoke-PlexRequest -RestEndpoint $Data.MediaContainer.Metadata.key -Method GET
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