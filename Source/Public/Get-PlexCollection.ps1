function Get-PlexCollection
{
	<#
		.SYNOPSIS
			Gets collections.
		.DESCRIPTION
			Gets collections.
		.PARAMETER Id
			The id of the collection to get.
		.PARAMETER LibraryId
			The id of the library to get collections from.
		.PARAMETER IncludeItems
			If specified, the items in the collection are returned.
		.EXAMPLE
			Get-PlexCollection -LibraryId 1
		.EXAMPLE
			Get-PlexCollection -Id 723 -IncludeItems
		.EXAMPLE
			# Get all collections from library 1 with the name, id (ratingkey) and number of items in the collection:
			Get-PlexCollection -LibraryId 1 | Select-Object title,ratingkey,childcount
	#>

	[CmdletBinding()]
	param(
		[Parameter(Mandatory = $true, ParameterSetName = "CollectionId")]
		[PSObject]
		$Id,

		[Parameter(Mandatory = $true, ParameterSetName = "LibraryId")]
		[PSObject]
		$LibraryId,

		[Parameter(Mandatory = $false)]
		[Switch]
		$IncludeItems
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
		$RestEndpoint = "library/collections/$($Id)"
	}

	if($LibraryId)
	{
		$RestEndpoint = "library/sections/$($LibraryId)/collections"
		#?includeCollections=1&includeExternalMedia=1&includeAdvanced=1&includeMeta=1"
		$Params = [Ordered]@{
			"includeCollections"   = 1
			"includeExternalMedia" = 0
			"includeAdvanced"      = 1
			"includeMeta"          = 1
		}
	}

	$DataUri = Get-PlexAPIUri -RestEndpoint $RestEndpoint -Params $Params
	#EndRegion

	#############################################################################
	#Region Get data
	try
	{
		$Data = Invoke-RestMethod -Uri $DataUri -Method GET
		if($Data.MediaContainer.metadata.count -eq 0)
		{
			return
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Get items
	if($IncludeItems)
	{
		if($Id)
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Appending collection item(s) for collection $($Data.MediaContainer.metadata.Title)"
			try
			{
				$Params = [Ordered]@{
					excludeAllLeaves = 1
				}
				$ItemsUri = Get-PlexAPIUri -RestEndpoint "library/collections/$($Id)/children" -Params $Params
				$Items = Invoke-RestMethod -Uri $ItemsUri -Method GET
				$Data.MediaContainer.metadata | Add-Member -NotePropertyName 'Items' -NotePropertyValue $Items.MediaContainer.metadata
			}
			catch
			{
				throw $_
			}
		}
		else
		{
			# Iterate over each collection, make a lookup for the items and append them:
			foreach($Collection in $Data.MediaContainer.Metadata)
			{
				Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Appending collection item(s) for collection $($Collection.title)"
				try
				{
					$Params = [Ordered]@{
						excludeAllLeaves = 1
					}
					$ItemsUri = Get-PlexAPIUri -RestEndpoint "library/collections/$($Collection.RatingKey)/children" -Params $Params
					$Items = Invoke-RestMethod -Uri $ItemsUri -Method GET
					$Collection | Add-Member -NotePropertyName 'Items' -NotePropertyValue $Items.MediaContainer.Metadata
				}
				catch
				{
					throw $_
				}
			}
		}
	}
	#EndRegion

	return $Data.MediaContainer.Metadata
}