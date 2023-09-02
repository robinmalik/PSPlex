function Get-PlexItemTypeId
{
	<#
		.SYNOPSIS
			Some Plex API calls include a type key value pair. This provides the id for a 'type'.
		.DESCRIPTION
			Some Plex API calls include a type key value pair. This provides the id for a 'type'.
		.PARAMETER Type
			The type
		.EXAMPLE
			Get-PlexItemTypeId -Type 'movie'
	#>

	[CmdletBinding()]
	[OutputType([System.Int32])]
	param(
		[Parameter(Mandatory = $true)]
		[ValidateSet('album', 'movie', 'show')]
		[String]
		$Type
	)

	<#
		Unsure how Plex defines the type value (as this isn't present on the metadata returned for an item) but handle
		known types here, at least:
		Movie = 1
		Show (not season) = 2
		Album = 9
	#>

	switch ($Type)
	{
		'album' { 9 }
		'movie' { 1 }
		'show' { 2 }
		default { throw "Unknown type for item. Are you tying to add a label to the wrong type of item? (must be: album, movie, show)" }
	}
}