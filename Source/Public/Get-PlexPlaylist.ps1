function Get-PlexPlaylist
{
	<#
		.SYNOPSIS
			Gets playlists.
		.DESCRIPTION
			Gets playlists.
		.PARAMETER Id
			The id of the playlist to get.
		.PARAMETER IncludeItems
			If specified, the items in the playlist are returned.
		.PARAMETER AlternativeToken
			Alternative token to use for authentication. For example,
			when querying for playlists for a different user.
		.EXAMPLE
			Get-PlexPlaylist -Id 723 -IncludeItems
		.EXAMPLE
			$User = Get-PlexUser -Username "friendsusername"
			Get-PlexPlaylist -AlternativeToken $User.Token
	#>

	[CmdletBinding(DefaultParameterSetName = "All")]
	param(
		[Parameter(Mandatory = $false, ParameterSetName = "Id")]
		[String]
		$Id,

		[Parameter(Mandatory = $false, ParameterSetName = "Name")]
		[String]
		$Name,

		[Parameter(Mandatory = $false)]
		[Switch]
		$IncludeItems,

		[Parameter(Mandatory = $false)]
		[ValidateNotNullOrEmpty()]
		[String]
		$AlternativeToken
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
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting playlist(s)"
	try
	{
		# If called with -Id, use the $Id, otherwise it'll return all playlists (and we can refine by name if specified)
		$Data = Invoke-PlexRequest -RestEndpoint "playlists/$Id" -Method GET -Token $AlternativeToken

		[array]$Results = $Data.MediaContainer.Metadata
		if($Name)
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Filtering for name '$Name'"
			$Results = $Results | Where-Object { $_.title -eq $Name }
		}
		if(!$Results)
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
		foreach($Playlist in $Results)
		{
			# If the playlist is smart skip it, as it doesn't have a static item list:
			if($Playlist.smart)
			{
				Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Item query for smart playlist not required. Skipping playlist $($Playlist.title)"
				continue
			}

			# We don't need -AlternativeToken here as the playlists have unique IDs
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting and appending playlist item(s) for playlist $($Playlist.title)"
			try
			{
				[array]$Items = Invoke-PlexRequest -RestEndpoint "playlists/$($Playlist.ratingKey)/items" -Method GET
				$Playlist | Add-Member -NotePropertyName 'Items' -NotePropertyValue $Items.MediaContainer.Metadata
			}
			catch
			{
				throw $_
			}
		}
	}
	#EndRegion

	#############################################################################
	# Append type and return results
	if($Results)
	{
		$Results | ForEach-Object { $_.psobject.TypeNames.Insert(0, "PSPlex.Playlist") }
		return $Results
	}
}
