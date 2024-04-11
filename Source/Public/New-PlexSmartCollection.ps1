function New-PlexSmartCollection
{
	<#
		.SYNOPSIS
			Creates a new smart collection.
		.DESCRIPTION
			Creates a new smart collection.
		.PARAMETER Name
			Name of the smart collection.
		.PARAMETER LibraryId
			ID of the library to create the smart collection in.
		.PARAMETER Filter
			Specifies the query string that retrieves the items in the smart collection. The syntax matches the Plex Web GUI as closely as possible. Clauses are separated by a semi-colon ( ; ).

			Syntax:

			- <Atttribute> <Operator> <Value>
			- <Atttribute> <Operator> <Value>;<Atttribute> <Operator> <Value>

			- Attributes:
				- String
					- Title
					- Studio
					- Edition
				- Numeric
					- Rating
					- Year
					- Decade
					- Plays
				- Exact
					- ContentRating
					- Genre
					- Collection
					- Actor
					- Country
					- SubtitleLanguage
					- AudioLanguage
					- Label
				- Boolean
					- Unmatched
					- Duplicate
					- Unplayed
					- HDR
					- InProgress
					- Trash
				- Semi-Boolean
					- Resolution
				- Date
					- ReleaseDate
					- DateAdded
					- LastPlayed

				- Operators:
				- String
					- Contains
					- DoesNotContain
					- Is
					- IsNot
					- BeginsWith
					- EndsWith
				- Numeric
					- Is
					- IsNot
					- IsGreaterThan
					- IsLessThan
				- Exact
					- Is
					- IsNot
				- Boolean
					- IsTrue
					- IsFalse
				- Semi-Boolean
					- Is
				- Date
					- IsBefore (Value format: yyyy-mm-dd)
					- IsAfter (Value format: yyyy-mm-dd)
					- IsInTheLast
					- IsNotInTheLast

			- Examples:
				- "DateAdded IsNotInTheLast 2y; Unplayed IsTrue"
				- "Title BeginsWith Star Trek; Unplayed IsTrue"
				- "Actor Is Jim Carrey; Genre Is Comedy"

		.PARAMETER MatchType
			Specifies how filter clauses are matched.

			- MatchAll: Matches all clauses.
			- MatchAny: Matches any cluase.
		.EXAMPLE
			New-PlexSmartCollection -Name "Star Trek" -LibraryId 1 -Filter "Title Contains Star Trek"
		.EXAMPLE
			New-PlexSmartCollection -Name "80's" -LibraryId 1 -Filter "Decade Is 1980"
		.EXAMPLE
			New-PlexSmartCollection -Name "Old Favorites" -LibraryId 1 -Filter "Plays IsGreaterThan 2; LastPlayed IsNotInTheLast 1y"
		.EXAMPLE
			New-PlexSmartCollection -Name "Trek Wars" -LibraryId 1 -MatchType MatchAny -Filter "title contains star trek; title contains star wars"
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory)]
		[string]
		$Name,

		[Parameter(Mandatory)]
		[string]
		$LibraryId,

		[Parameter(Mandatory)]
		[string]
		$Filter,

		[Parameter()]
		[ValidateSet("MatchAll", "MatchAny")]
		[string]
		$MatchType = "MatchAll"
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
	#Region Check if collection already exists
	try
	{
		$Collections = Get-PlexCollection -LibraryId $LibraryId
		if ($Collections.title -contains $Name)
		{
			throw "Collection '$Name' already exits"
		}
	}
	catch
	{
		$PSCmdlet.ThrowTerminatingError($_)
	}
	#EndRegion

	#############################################################################
	#Region Get machine identifier
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting list of Plex servers (to get machine identifier)"
	try
	{
		$CurrentPlexServer = Get-PlexServer -Name $DefaultPlexServer.PlexServer -ErrorAction Stop
		if(!$CurrentPlexServer)
		{
			throw "Could not find $CurrentPlexServer in $($Servers -join ', ')"
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Region Construct Uri
	try
	{
		$Items = Resolve-PlexFilter -MatchType $MatchType -LibraryId $LibraryId -Filter $Filter
		$Params = [ordered]@{
			type      = '1'
			title     = [System.Uri]::EscapeDataString($Name)
			smart     = '1'
			sectionId = $LibraryId
			uri       = [System.Uri]::EscapeDataString("server://$($CurrentPlexServer.machineIdentifier)/com.plexapp.plugins.library/library/sections/$LibraryId/all?type=1&sort=titleSort&$Items")
		}

		$DataUri = (Get-PlexAPIUri -RestEndpoint "library/collections" -Params $Params)
	}
	catch
	{
		$PSCmdlet.ThrowTerminatingError($_)
	}
	#EndRegion

	#############################################################################
	#Region Make request
	if($PSCmdlet.ShouldProcess("Library $LibraryId", "Create Smart Collection '$Name'"))
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Creating Smart Collection $Name in Libary '$LibraryId'"
		try
		{
			$Data = Invoke-RestMethod -Uri $DataUri -Method POST
			return $Data.mediacontainer.metadata
		}
		catch
		{
			throw $_
		}
	}
	#EndRegion
}