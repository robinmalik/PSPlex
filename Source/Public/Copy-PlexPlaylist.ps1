function Copy-PlexPlaylist
{
	<#
		.SYNOPSIS
			This function will copy a playlist from your account to another user account on your server.
			Note: If the destination user already has a playlist with this name, a second one will be created.
			To overwrite, use the -Force switch.
		.DESCRIPTION
			This function will copy a playlist from your account to another user account on your server.
			Note: If the destination user already has a playlist with this name, a second one will be created.
			To overwrite, use the -Force switch.
		.PARAMETER Id
			Id of the playlist you wish to copy. To get this, use 'Get-PlexPlaylist'.
		.PARAMETER NewPlaylistName
			Create the playlist with a different name.
		.PARAMETER Username
			The username for the account you wish to copy the playlist to.
		.PARAMETER Force
			Overwrite the contents of an existing playlist.
		.EXAMPLE
			Copy-PlexPlaylist -Id 12345 -User 'user@domain.com'
	#>

	[CmdletBinding(SupportsShouldProcess)]
	param(
		[Parameter(Mandatory = $true)]
		[String]
		$Id,

		[Parameter(Mandatory = $false)]
		[String]
		$NewPlaylistName,

		[Parameter(Mandatory = $true)]
		[String]
		$Username,

		[Parameter(Mandatory = $false)]
		[Switch]
		$Force
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
	#Region Get the Playlist we want to copy
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting playlist $Id, including playlist items"
	try
	{
		$Playlist = Get-PlexPlaylist -Id $Id -IncludeItems -ErrorAction Stop
		if(!$Playlist)
		{
			throw "Could not find playlist with id $Id."
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	#############################################################################
	#Region Get the target user along with user token for our server
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Getting user."
	try
	{
		$User = Get-PlexUser -User $Username -IncludeToken -ErrorAction Stop
		if(($Null -eq $User) -or ($User.count -eq 0))
		{
			throw "Could not get user: $Username"
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion


	#############################################################################
	#Region Create a new variable to store the destination playlist name
	if($NewPlaylistName)
	{
		$PlaylistTitle = $NewPlaylistName
	}
	else
	{
		$PlaylistTitle = $Playlist.title
	}
	#EndRegion

	#############################################################################
	#Region Check whether the user already has a playlist by this name.
	# It's worth noting that you can have multiple playlists with the same name (sigh).
	Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Checking $Username account for existing playlist"
	try
	{
		[Array]$ExistingPlaylistsWithSameName = Get-PlexPlaylist -AlternativeToken $User.token -ErrorAction Stop | Where-Object { $_.title -eq $PlaylistTitle }
		if($ExistingPlaylistsWithSameName.Count -gt 1)
		{
			# If there is more than 1 playlist with the same name in the destination account, we
			# 1) wouldn't know which we wanted to overwrite and
			# 2) wouldn't want to remove them automatically when -Force is used, so warn and exit.
			Write-Warning -Message "Multiple playlists with the name '$PlaylistTitle' exist under the destination account $Username. You can review these with 'Get-PlexPlaylist' and remove with 'Remove-PlexPlaylist' (after obtaining a user token for $Username with 'Get-PlexUser -Username $Username -IncludeToken')."
			return
		}
		elseif($ExistingPlaylistsWithSameName.Count -eq 1)
		{
			if($Force)
			{
				Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Playlist already exists in destination account. Removing."
				foreach($PL in $ExistingPlaylistsWithSameName)
				{
					try
					{
						Remove-PlexPlaylist -Id $PL.ratingKey -AlternativeToken $User.token -ErrorAction Stop | Out-Null
					}
					catch
					{
						Write-Warning -Message "Could not delete existing playlist."
						throw $_
					}
				}
			}
			else
			{
				Write-Warning -Message "The destination account already has a Playlist with the name '$PlaylistTitle'. To overwrite it, call this function with the -Force parameter."
				return
			}
		}
		else
		{
		}
	}
	catch
	{
		throw $_
	}
	#EndRegion

	#############################################################################
	#Establish whether the playlist is smart or not; this will determine how we create it:

	# Determine playlist type and build URI accordingly
	if($Playlist.smart -eq 0)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Original playlist is NOT smart."
		$ItemsToAdd = $Playlist.Items.ratingKey -join ','
		$PlaylistUri = "server://$($DefaultPlexServer.ClientIdentifier)/com.plexapp.plugins.library/library/metadata/$ItemsToAdd"
	}
	elseif($Playlist.smart -eq 1)
	{
		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Original playlist is smart."

		# Smart playlists return a .content property which we need to parse to get the smart playlist parameters, and source library id.

		# Get the smart playlist parameters:
		$SmartPlaylistParams = ($Playlist.content -split 'all%3F')[1]

		# Uri decode and extract the library section ID:
		$Playlist.content = [System.Web.HttpUtility]::UrlDecode($Playlist.content)

		Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Extracting library section ID from playlist content: $($Playlist.content)"
		if($Playlist.content -match 'sections/(\d+)/all')
		{
			$LibrarySectionId = $matches[1]
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Extracted library section ID: $LibrarySectionId"
		}
		else
		{
			throw "Could not extract library section ID from playlist content: $($Playlist.content)."
		}

		$PlaylistUri = "server://$($DefaultPlexServer.ClientIdentifier)/com.plexapp.plugins.library/library/sections/$LibrarySectionId/all?$($SmartPlaylistParams)"
	}
	else
	{
		Write-Warning -Message "Function: $($MyInvocation.MyCommand): No work done."
		return
	}

	# Create the playlist on the server
	if($PSCmdlet.ShouldProcess("Playlist: $PlaylistTitle", "Create playlist on server $($DefaultPlexServer.PlexServer) under user $Username"))
	{
		try
		{
			Write-Verbose -Message "Function: $($MyInvocation.MyCommand): Creating playlist"
			$Params = [Ordered]@{
				type           = $Playlist.playlistType
				title          = $PlaylistTitle
				smart          = $Playlist.smart
				uri            = $PlaylistUri
				'X-Plex-Token' = $User.token
			}
			$DataUri = Get-PlexAPIUri -RestEndpoint "playlists" -Params $Params
			$Data = Invoke-RestMethod -Uri $DataUri -Method POST
			return $Data.MediaContainer.Playlist
		}
		catch
		{
			throw $_
		}
	}
}