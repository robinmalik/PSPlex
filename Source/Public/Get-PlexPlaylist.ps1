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

	[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = "All")]
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
			Import-PlexConfiguration -WhatIf:$False
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
		# Plex decided to automatically create Playlists with heart emojis in for music playlists.
		# When calling Invoke-RestMethod, PowerShell ends up converting these to squiggly a characters.
		# To work around this, we have to use Invoke-WebRequest and take the RawContentStream property
		# and use that.
		if($AlternativeToken)
		{
			$Params = @{'X-Plex-Token' = $AlternativeToken }
		}

		# If called with -Id, use the $Id, otherwise it'll return all playlists (and we can refine by name if specified)
		$DataUri = Get-PlexAPIUri -RestEndpoint "playlists/$Id" -Params $Params
		$Data = Invoke-WebRequest -Uri $DataUri -ErrorAction Stop

		if($Data)
		{
			$UTF8String = [system.Text.Encoding]::UTF8.GetString($Data.RawContentStream.ToArray())
			[array]$Results = ($UTF8String | ConvertFrom-Json).MediaContainer.Metadata
			if($Name)
			{
				Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Filtering for name '$Name'"
				$Results = $Results | Where-Object { $_.title -eq $Name }
			}
		}
		else
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
				continue
			}

			# We don't need -AlternativeToken here as the playlists have unique IDs
			$ItemsUri = Get-PlexAPIUri -RestEndpoint "playlists/$($Playlist.ratingKey)/items"
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting and appending playlist item(s) for playlist $($playlist.title)"
			try
			{
				[array]$Items = Invoke-RestMethod -Uri $ItemsUri -ErrorAction Stop
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